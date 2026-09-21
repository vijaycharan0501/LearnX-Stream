import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HeroSmartExplainCard extends StatelessWidget {
  final VoidCallback? onTap;

  const HeroSmartExplainCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE6F7F5),
            Color(0xFFEFF6FF),
            Color(0xFFF9FAFC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.tealBorder.withValues(alpha: 0.7),
          width: 1.2,
        ),
        boxShadow: AppColors.heroGlow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag & Sparkle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.tealBorder,
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 13,
                            color: AppColors.tealPrimary,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Adaptive Modality Engine',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.tealPrimary,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: const Icon(
                        Icons.arrow_outward_rounded,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Title
                const Text(
                  'Smart Explain',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),

                // Description
                const Text(
                  'AI chooses the best way to help you understand a concept.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Representation Chips
                const Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _RepresentationChip(
                      icon: Icons.schema_rounded,
                      label: 'Workflow',
                      color: AppColors.orangePrimary,
                      bgColor: AppColors.orangeLight,
                      borderColor: AppColors.orangeBorder,
                    ),
                    _RepresentationChip(
                      icon: Icons.account_tree_rounded,
                      label: 'Concept Map',
                      color: AppColors.bluePrimary,
                      bgColor: AppColors.blueLight,
                      borderColor: AppColors.blueBorder,
                    ),
                    _RepresentationChip(
                      icon: Icons.science_rounded,
                      label: 'Simulation',
                      color: AppColors.tealPrimary,
                      bgColor: AppColors.tealLight,
                      borderColor: AppColors.tealBorder,
                    ),
                    _RepresentationChip(
                      icon: Icons.insights_rounded,
                      label: 'Interactive Diagram',
                      color: AppColors.purplePrimary,
                      bgColor: AppColors.purpleLight,
                      borderColor: AppColors.purpleBorder,
                    ),
                    _RepresentationChip(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Guided Chat',
                      color: AppColors.greenPrimary,
                      bgColor: AppColors.greenLight,
                      borderColor: AppColors.greenBorder,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Interactive prompt preview bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Try explaining "How does Raft Consensus work?"',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.tealPrimary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Explain',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textLight,
                          ),
                        ),
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

class _RepresentationChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final Color borderColor;

  const _RepresentationChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 0.9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
