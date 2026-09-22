import 'package:flutter/material.dart';
import '../../../core/models/conversation_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_right_panel.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_top_header.dart';

class LearnScreen extends StatelessWidget {
  final VoidCallback? onBackToHome;

  const LearnScreen({super.key, this.onBackToHome});

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
        activeNavIndex: 1,
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
            title: 'Interactive Learning Studio',
            onBack: onBackToHome,
          ),
          const SizedBox(height: 18),

          // Header Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.getSurface(isDark),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.getCardBorder(isDark)),
              boxShadow: AppColors.softShadowFor(isDark),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.getTealLight(isDark),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.getTealBorder(isDark)),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: AppColors.tealPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Interactive Concept Studio',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Browse deep representations, interactive diagrams, concept maps, and AI workflows for your topics.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Explore Formats
          Text(
            'Explore Formats',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 12),
          _buildFormatCard(
            context,
            icon: Icons.account_tree_outlined,
            title: 'Concept Maps',
            subtitle: 'Visual knowledge hierarchy & relations',
            color: AppColors.purplePrimary,
            bgColor: AppColors.getPurpleLight(isDark),
            borderColor: AppColors.getPurpleBorder(isDark),
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildFormatCard(
            context,
            icon: Icons.science_outlined,
            title: 'Interactive Simulations',
            subtitle: 'Dynamic parameter exploration and physics/logic demos',
            color: AppColors.orangePrimary,
            bgColor: AppColors.getOrangeLight(isDark),
            borderColor: AppColors.getOrangeBorder(isDark),
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildFormatCard(
            context,
            icon: Icons.schema_outlined,
            title: 'Workflow Diagrams',
            subtitle: 'Step-by-step algorithmic flows and protocol stages',
            color: AppColors.tealPrimary,
            bgColor: AppColors.getTealLight(isDark),
            borderColor: AppColors.getTealBorder(isDark),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildFormatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getCardBorder(isDark)),
        boxShadow: AppColors.softShadowFor(isDark),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 13,
            color: AppColors.getTextMuted(isDark),
          ),
        ],
      ),
    );
  }
}
