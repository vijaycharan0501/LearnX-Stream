import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum ConceptCardType { recent, weak }

class ConceptItemCard extends StatelessWidget {
  final String title;
  final String category;
  final String statusText;
  final IconData icon;
  final ConceptCardType type;
  final VoidCallback? onTap;

  const ConceptItemCard({
    super.key,
    required this.title,
    required this.category,
    required this.statusText,
    required this.icon,
    this.type = ConceptCardType.recent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWeak = type == ConceptCardType.weak;
    final primaryColor = isWeak ? AppColors.coralPrimary : AppColors.bluePrimary;
    final lightColor = isWeak ? AppColors.coralLight : AppColors.blueLight;
    final borderColor = isWeak ? AppColors.coralBorder : AppColors.blueBorder;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWeak ? borderColor.withValues(alpha: 0.8) : AppColors.cardBorder,
          width: isWeak ? 1.1 : 1,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: lightColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Icon(icon, color: primaryColor, size: 20),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Badge / Tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isWeak ? AppColors.coralLight : AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isWeak ? AppColors.coralBorder : AppColors.cardBorder,
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isWeak ? AppColors.coralPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
