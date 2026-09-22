import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../features/material_input/models/material_analysis_models.dart';

/// Custom exception representing API communication and analysis errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const ApiException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() => message;
}

/// Core API service for LearnX STREAM
class ApiService {
  final String baseUrl;
  final http.Client _client;
  final Duration timeout;

  static const String defaultBaseUrl = 'http://127.0.0.1:8001';

  ApiService({
    String? baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  })  : baseUrl = (baseUrl ?? defaultBaseUrl).replaceAll(RegExp(r'/+$'), ''),
        _client = client ?? http.Client();

  /// Analyzes study material using the FastAPI backend and Gemini pedagogical engine.
  ///
  /// Sends POST request to [baseUrl]/analyze-material with title and text payload.
  Future<MaterialAnalysisResponse> analyzeMaterial(String title, String text) async {
    final cleanTitle = title.trim();
    final cleanText = text.trim().isNotEmpty ? text.trim() : cleanTitle;

    if (cleanTitle.isEmpty && cleanText.isEmpty) {
      throw const ApiException('Please provide a topic / concept name for analysis.');
    }

    final effectiveTitle = cleanTitle.isNotEmpty ? cleanTitle : cleanText.split('\n').first;
    final effectiveText = cleanText.isNotEmpty ? cleanText : effectiveTitle;

    final Uri endpoint = Uri.parse('$baseUrl/analyze-material');
    final String requestBody = jsonEncode({
      'title': effectiveTitle,
      'text': effectiveText,
    });

    try {
      debugPrint('[ApiService] Requesting POST $endpoint with topic: "$effectiveTitle"');
      final response = await _client
          .post(
            endpoint,
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
            },
            body: requestBody,
          )
          .timeout(timeout);

      debugPrint('[ApiService] Received HTTP ${response.statusCode} from $endpoint');

      if (response.statusCode == 200) {
        try {
          final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
          if (decoded is Map<String, dynamic>) {
            return MaterialAnalysisResponse.fromJson(decoded);
          } else {
            debugPrint('[ApiService] Invalid response format received (not a JSON map)');
            throw const ApiException('Invalid response format received from server.');
          }
        } on FormatException catch (e) {
          debugPrint('[ApiService] JSON decode failed: $e. Body: ${response.body}');
          throw ApiException(
            'Failed to parse analysis response from server.',
            statusCode: response.statusCode,
            originalError: e,
          );
        }
      } else {
        debugPrint('[ApiService] Error HTTP ${response.statusCode}. Body: ${response.body}');
        // Attempt to extract error detail from JSON response
        String errorMessage = 'Server returned error status (${response.statusCode}).';
        try {
          final errorJson = jsonDecode(utf8.decode(response.bodyBytes));
          if (errorJson is Map && errorJson.containsKey('detail')) {
            final detail = errorJson['detail'];
            if (detail is String) {
              errorMessage = detail;
            } else if (detail is List && detail.isNotEmpty) {
              final first = detail.first;
              if (first is Map && first.containsKey('msg')) {
                errorMessage = first['msg'].toString();
              }
            }
          }
        } catch (_) {
          // Keep generic message if body is not JSON
        }

        throw ApiException(
          errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException catch (e) {
      debugPrint('[ApiService] TimeoutException for $endpoint: $e');
      throw ApiException(
        'Connection timed out. Please verify that the backend server is responsive.',
        originalError: e,
      );
    } on http.ClientException catch (e) {
      debugPrint('[ApiService] http.ClientException for $endpoint: $e');
      throw ApiException(
        'Network error: Unable to reach $baseUrl. Check your connection or CORS settings.',
        originalError: e,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('[ApiService] ${e.runtimeType} for $endpoint: $e');
      if (e.toString().contains('SocketException')) {
        throw ApiException(
          'Cannot connect to backend server at $baseUrl. Please verify the server is running.',
          originalError: e,
        );
      }
      throw ApiException(
        'An unexpected error occurred: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Check health status of backend
  Future<bool> checkHealth() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}
