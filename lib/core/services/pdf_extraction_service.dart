import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Result object of a PDF text extraction operation
class PdfExtractionResult {
  final bool success;
  final String text;
  final int pageCount;
  final String? errorMessage;

  const PdfExtractionResult({
    required this.success,
    required this.text,
    required this.pageCount,
    this.errorMessage,
  });

  /// Whether any readable text was found in the PDF
  bool get hasText => text.trim().isNotEmpty;
}

/// Service to extract text from PDF documents using pure Dart
class PdfExtractionService {
  /// Extracts all readable text from the provided PDF byte data.
  Future<PdfExtractionResult> extractText(Uint8List pdfBytes) async {
    PdfDocument? document;
    try {
      if (pdfBytes.isEmpty) {
        return const PdfExtractionResult(
          success: false,
          text: '',
          pageCount: 0,
          errorMessage: 'The selected PDF file is empty.',
        );
      }

      document = PdfDocument(inputBytes: pdfBytes);
      final int pageCount = document.pages.count;

      if (pageCount == 0) {
        return const PdfExtractionResult(
          success: false,
          text: '',
          pageCount: 0,
          errorMessage: 'The PDF document contains no pages.',
        );
      }

      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final String extractedText = extractor.extractText();

      return PdfExtractionResult(
        success: true,
        text: extractedText.trim(),
        pageCount: pageCount,
      );
    } catch (e) {
      debugPrint('PdfExtractionService error: $e');
      return PdfExtractionResult(
        success: false,
        text: '',
        pageCount: 0,
        errorMessage: 'Could not parse PDF content: ${e.toString()}',
      );
    } finally {
      document?.dispose();
    }
  }
}
