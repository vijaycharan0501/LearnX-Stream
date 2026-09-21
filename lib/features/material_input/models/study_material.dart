import 'dart:typed_data';

/// Reusable StudyMaterial model representing user-submitted study content
/// (typed notes, uploaded PDFs, or uploaded images).
class StudyMaterial {
  final String title;
  final String sourceType;
  final String rawText;
  final Uint8List? fileBytes;
  final String? fileName;
  final int? fileSizeBytes;
  final int? pageCount;
  final bool isOcrPending;
  final DateTime createdAt;

  StudyMaterial({
    required this.title,
    this.sourceType = 'Typed Text',
    required this.rawText,
    this.fileBytes,
    this.fileName,
    this.fileSizeBytes,
    this.pageCount,
    this.isOcrPending = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Character count of the study material text
  int get characterCount => rawText.length;

  /// Word count of the study material text
  int get wordCount {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  /// Estimated reading time in minutes (assuming ~200 wpm)
  int get estimatedReadingMinutes {
    final words = wordCount;
    if (words <= 200) return 1;
    return (words / 200).ceil();
  }

  /// Formatted file size string (e.g. "1.2 MB", "420 KB")
  String get formattedFileSize {
    if (fileSizeBytes == null) return '';
    final bytes = fileSizeBytes!;
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Returns a shortened preview snippet
  String get previewSnippet {
    final clean = rawText.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.length <= 160) return clean;
    return '${clean.substring(0, 160)}...';
  }
}
