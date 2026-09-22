import 'package:flutter/material.dart';
import '../../../core/models/conversation_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_right_panel.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_top_header.dart';

class ProgressScreen extends StatelessWidget {
  final VoidCallback? onBackToHome;

  const ProgressScreen({super.key, this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sessions = [
      ConversationSession(
        id: 'session-1',
        title: 'Photosynthesis',
        isPinned: true,
        updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      ConversationSession(
        id: 'session-2',
        title: 'Binary Search',
        isPinned: true,
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      ConversationSession(
        id: 'session-3',
        title: "Ohm's Law",
        isPinned: false,
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];

    return AppShell(
      sidebar: AppSidebar(
        sessions: sessions,
        activeNavIndex: 3, // Saved / Progress
        onNewChat: () => onBackToHome?.call(),
        onNavigateTab: (index) {
          if (index == 0) onBackToHome?.call();
        },
      ),
      rightPanel: AppRightPanel(
        onSelectTopic: (topic) => onBackToHome?.call(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTopHeader(
            title: 'Learning Progress & Mastery',
            onBack: onBackToHome,
          ),
          const SizedBox(height: 18),

          // Overall Score Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.getSurface(isDark),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.getCardBorder(isDark)),
              boxShadow: AppColors.softShadowFor(isDark),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.getGreenLight(isDark),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.getGreenBorder(isDark)),
                  ),
                  child: const Icon(
                    Icons.insights_rounded,
                    color: AppColors.greenPrimary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Mastery Score',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.getTextSecondary(isDark),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '88%',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.greenPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+6% this week',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.tealPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Mastery Breakdown
          Text(
            'Concept Mastery Breakdown',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 12),
          _buildMasteryItem('Photosynthesis', 0.95, AppColors.tealPrimary, isDark),
          const SizedBox(height: 8),
          _buildMasteryItem('Binary Search', 0.85, AppColors.bluePrimary, isDark),
          const SizedBox(height: 8),
          _buildMasteryItem("Ohm's Law", 0.80, AppColors.orangePrimary, isDark),
        ],
      ),
    );
  }

  Widget _buildMasteryItem(String topic, double score, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.getCardBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                topic,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              Text(
                '${(score * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score,
              backgroundColor: AppColors.getSurfaceSecondary(isDark),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
