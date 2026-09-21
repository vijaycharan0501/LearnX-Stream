import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/material_input_data.dart';

class MaterialPreviewCard extends StatelessWidget {
  final MaterialPreviewData preview;
  final VoidCallback onAnalyzePressed;

  const MaterialPreviewCard({
    super.key,
    required this.preview,
    required this.onAnalyzePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.tealBorder.withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Label & Content Type Badge
            Row(
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.preview_rounded,
                        size: 16,
                        color: AppColors.tealPrimary,
                      ),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Ready for Analysis',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.tealPrimary,
                            letterSpacing: 0.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: preview.badgeLightColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: preview.badgeColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        preview.icon,
                        size: 12,
                        color: preview.badgeColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        preview.contentType,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: preview.badgeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Material Title
            Text(
              preview.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),

            // Short Preview snippet
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Text(
                preview.previewSnippet,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // "Analyze Material" Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAnalyzePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tealPrimary,
                  foregroundColor: AppColors.textLight,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Analyze Material',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
