import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum InputMethod {
  scan(
    title: 'Scan Material',
    shortLabel: 'Scan',
    icon: Icons.document_scanner_rounded,
    accentColor: AppColors.tealPrimary,
    lightColor: AppColors.tealLight,
    borderColor: AppColors.tealBorder,
  ),
  upload(
    title: 'Upload PDF / Image',
    shortLabel: 'Upload',
    icon: Icons.upload_file_rounded,
    accentColor: AppColors.bluePrimary,
    lightColor: AppColors.blueLight,
    borderColor: AppColors.blueBorder,
  ),
  topic(
    title: 'Enter Topic',
    shortLabel: 'Topic / Text',
    icon: Icons.lightbulb_outline_rounded,
    accentColor: AppColors.orangePrimary,
    lightColor: AppColors.orangeLight,
    borderColor: AppColors.orangeBorder,
  ),
  voice(
    title: 'Voice Question',
    shortLabel: 'Voice',
    icon: Icons.mic_rounded,
    accentColor: AppColors.purplePrimary,
    lightColor: AppColors.purpleLight,
    borderColor: AppColors.purpleBorder,
  );

  final String title;
  final String shortLabel;
  final IconData icon;
  final Color accentColor;
  final Color lightColor;
  final Color borderColor;

  const InputMethod({
    required this.title,
    required this.shortLabel,
    required this.icon,
    required this.accentColor,
    required this.lightColor,
    required this.borderColor,
  });
}

class MaterialPreviewData {
  final String title;
  final String contentType;
  final String previewSnippet;
  final IconData icon;
  final Color badgeColor;
  final Color badgeLightColor;

  const MaterialPreviewData({
    required this.title,
    required this.contentType,
    required this.previewSnippet,
    required this.icon,
    this.badgeColor = AppColors.tealPrimary,
    this.badgeLightColor = AppColors.tealLight,
  });

  factory MaterialPreviewData.defaultTopic(String topic) {
    return MaterialPreviewData(
      title: topic.isEmpty ? 'Binary Search' : topic,
      contentType: 'Custom Topic / Concept',
      previewSnippet:
          'Explores divide-and-conquer strategy, logarithmic time complexity O(log N), pointer arithmetic, edge cases, and interactive tree visualization.',
      icon: Icons.lightbulb_outline_rounded,
      badgeColor: AppColors.orangePrimary,
      badgeLightColor: AppColors.orangeLight,
    );
  }

  factory MaterialPreviewData.scannedSample() {
    return const MaterialPreviewData(
      title: 'Textbook: Thermodynamics & Heat Engines',
      contentType: 'Scanned Textbook Page',
      previewSnippet:
          'Contains 3 Carnot cycle equations, PV diagram representations, 2 practice review questions, and thermal efficiency formulas.',
      icon: Icons.document_scanner_rounded,
      badgeColor: AppColors.tealPrimary,
      badgeLightColor: AppColors.tealLight,
    );
  }

  factory MaterialPreviewData.uploadedSample({
    String fileName = 'Operating_Systems_Concurrency.pdf',
    String snippet =
        '14 pages covering mutex locks, semaphores, race conditions, critical section problem, and dining philosophers synchronization.',
  }) {
    return MaterialPreviewData(
      title: fileName,
      contentType: fileName.endsWith('.pdf') ? 'PDF Document' : 'Image Document',
      previewSnippet: snippet,
      icon: fileName.endsWith('.pdf') ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
      badgeColor: AppColors.bluePrimary,
      badgeLightColor: AppColors.blueLight,
    );
  }
}
