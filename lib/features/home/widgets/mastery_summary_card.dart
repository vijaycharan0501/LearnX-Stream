import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MasterySummaryCard extends StatelessWidget {
  final int masteryPercentage;
  final int masteredCount;
  final int totalCount;
  final VoidCallback? onTap;

  const MasterySummaryCard({
    super.key,
    this.masteryPercentage = 73,
    this.masteredCount = 15,
    this.totalCount = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    // Mastery Circular Ring / Indicator
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 58,
                          height: 58,
                          child: CircularProgressIndicator(
                            value: masteryPercentage / 100,
                            strokeWidth: 6,
                            backgroundColor: AppColors.surfaceSecondary,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.tealPrimary,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Text(
                          '$masteryPercentage%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // Information
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                'Concept Mastery',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: AppColors.tealPrimary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$masteredCount of $totalCount concepts retained at high confidence',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Quick stats pill row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MiniStat(
                        icon: Icons.check_circle_rounded,
                        color: AppColors.greenPrimary,
                        label: 'Mastered',
                        value: '15',
                      ),
                      _DividerLine(),
                      _MiniStat(
                        icon: Icons.timelapse_rounded,
                        color: AppColors.bluePrimary,
                        label: 'In Progress',
                        value: '3',
                      ),
                      _DividerLine(),
                      _MiniStat(
                        icon: Icons.warning_amber_rounded,
                        color: AppColors.coralPrimary,
                        label: 'Needs Focus',
                        value: '2',
                      ),
                    ],
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

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _MiniStat({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          '$value $label',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 12,
      color: AppColors.divider,
    );
  }
}
