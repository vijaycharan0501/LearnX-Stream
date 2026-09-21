import 'dart:io' show File;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

/// Representation of a chosen study file (PDF or Image)
class PickedStudyFile {
  final String name;
  final String extension;
  final int sizeInBytes;
  final Uint8List bytes;

  const PickedStudyFile({
    required this.name,
    required this.extension,
    required this.sizeInBytes,
    required this.bytes,
  });

  bool get isPdf => extension.toLowerCase() == 'pdf';
  bool get isImage => ['png', 'jpg', 'jpeg'].contains(extension.toLowerCase());

  /// Formatted human-readable file size (e.g. "1.2 MB", "450 KB")
  String get formattedSize {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1024 * 1024) {
      final kb = (sizeInBytes / 1024).toStringAsFixed(1);
      return '$kb KB';
    } else {
      final mb = (sizeInBytes / (1024 * 1024)).toStringAsFixed(1);
      return '$mb MB';
    }
  }

  /// Display label for the file type
  String get typeLabel {
    if (isPdf) return 'PDF Document';
    if (extension.toLowerCase() == 'png') return 'PNG Image';
    if (extension.toLowerCase() == 'jpg' || extension.toLowerCase() == 'jpeg') {
      return 'JPEG Image';
    }
    return '${extension.toUpperCase()} File';
  }
}

/// Service to handle selecting PDF and image study materials
class FilePickerService {
  static const int maxFileSizeBytes = 25 * 1024 * 1024; // 25 MB

  /// Opens system file picker for PDF, PNG, JPG, and JPEG files.
  Future<PickedStudyFile?> pickStudyFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        withData: true,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null; // User cancelled
      }

      final PlatformFile platformFile = result.files.first;
      Uint8List? fileBytes = platformFile.bytes;

      // On desktop platforms where withData might not load bytes automatically
      if (fileBytes == null && platformFile.path != null && !kIsWeb) {
        final File file = File(platformFile.path!);
        if (await file.exists()) {
          fileBytes = await file.readAsBytes();
        }
      }

      if (fileBytes == null || fileBytes.isEmpty) {
        throw Exception('Could not read file content from selected file.');
      }

      if (fileBytes.lengthInBytes > maxFileSizeBytes) {
        throw Exception(
          'File size exceeds the 25MB limit. Please choose a smaller file.',
        );
      }

      final extension = platformFile.extension ??
          (platformFile.name.contains('.')
              ? platformFile.name.split('.').last
              : 'bin');

      return PickedStudyFile(
        name: platformFile.name,
        extension: extension,
        sizeInBytes: fileBytes.lengthInBytes,
        bytes: fileBytes,
      );
    } catch (e) {
      debugPrint('FilePickerService error: $e');
      rethrow;
    }
  }
}
