import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable LearnX STREAM Right-Side Learning Panel.
///
/// Matches Screenshot 1 exact design system:
/// - QUICK ACTIONS ([✨ AI Summary], [📄 Documents], [🎯 Quick Check], [👁 Visualize] / [💬 Ask about this])
/// - RECENT LEARNING (Photosynthesis, Binary Search, Ohm's Law)
/// - LEARNING SNAPSHOT / VISUALIZATION SNAPSHOT (Contextual progress and metrics)
/// - SAVED CONCEPTS (Important starred concepts)
/// - LEARNING TIP (Helpful pedagogical suggestions)
/// - 100% theme-adaptive for Light & Dark modes.
class AppRightPanel extends StatelessWidget {
  final VoidCallback? onAISummary;
  final VoidCallback? onDocuments;
  final VoidCallback? onQuickCheck;
  final VoidCallback? onVisualize;
  final VoidCallback? onAskAboutThis;
  final ValueChanged<String>? onSelectTopic;
  final List<String> recentTopics;
  final Set<String> savedConcepts;
  final int conceptsExplored;
  final int visualExplanations;
  final int questionsPracticed;
  final String? currentVisualizationTopic;
  final String? currentVisualizationProgress;
  final String? customLearningTip;

  const AppRightPanel({
    super.key,
    this.onAISummary,
    this.onDocuments,
    this.onQuickCheck,
    this.onVisualize,
    this.onAskAboutThis,
    this.onSelectTopic,
    this.recentTopics = const ['Photosynthesis', 'Binary Search', "Ohm's Law"],
    this.savedConcepts = const {'Photosynthesis', 'Binary Search'},
    this.conceptsExplored = 12,
    this.visualExplanations = 8,
    this.questionsPracticed = 24,
    this.currentVisualizationTopic,
    this.currentVisualizationProgress,
    this.customLearningTip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. QUICK ACTIONS
        Text(
          'QUICK ACTIONS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.getTextMuted(isDark),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        _buildQuickActionTile(
          context: context,
          icon: Icons.summarize_outlined,
          color: AppColors.purplePrimary,
          bgColor: AppColors.getPurpleLight(isDark),
          title: '✨ AI Summary',
          subtitle: 'Summarize topics or notes',
          onTap: () => onAISummary?.call(),
        ),
        const SizedBox(height: 8),
        _buildQuickActionTile(
          context: context,
          icon: Icons.upload_file_rounded,
          color: AppColors.bluePrimary,
          bgColor: AppColors.getBlueLight(isDark),
          title: '📄 Documents',
          subtitle: 'Upload PDF or scan notes',
          onTap: () => onDocuments?.call(),
        ),
        const SizedBox(height: 8),
        _buildQuickActionTile(
          context: context,
          icon: Icons.quiz_outlined,
          color: AppColors.orangePrimary,
          bgColor: AppColors.getOrangeLight(isDark),
          title: '🎯 Quick Check',
          subtitle: 'Practice concept questions',
          onTap: () => onQuickCheck?.call(),
        ),
        const SizedBox(height: 8),
        if (onAskAboutThis != null)
          _buildQuickActionTile(
            context: context,
            icon: Icons.chat_bubble_outline_rounded,
            color: AppColors.tealPrimary,
            bgColor: AppColors.getTealLight(isDark),
            title: '💬 Ask About This',
            subtitle: 'Ask questions about concept',
            onTap: () => onAskAboutThis?.call(),
          )
        else
          _buildQuickActionTile(
            context: context,
            icon: Icons.visibility_outlined,
            color: AppColors.tealPrimary,
            bgColor: AppColors.getTealLight(isDark),
            title: '👁 Visualize',
            subtitle: 'Open visual explanation',
            onTap: () => onVisualize?.call(),
          ),

        const SizedBox(height: 22),

        // 2. RECENT LEARNING
        Text(
          'RECENT LEARNING',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.getTextMuted(isDark),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        ...recentTopics.map(
          (topic) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              onTap: () => onSelectTopic?.call(topic),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.getSurface(isDark),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.getCardBorder(isDark)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history_rounded, size: 14, color: AppColors.tealPrimary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        topic,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.getTextMuted(isDark)),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 22),

        // 3. LEARNING SNAPSHOT / VISUALIZATION CONTEXT
        Text(
          currentVisualizationTopic != null ? 'VISUALIZATION SNAPSHOT' : 'LEARNING SNAPSHOT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.getTextMuted(isDark),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.getSurface(isDark),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.getCardBorder(isDark)),
          ),
          child: currentVisualizationTopic != null
              ? Column(
                  children: [
                    _buildSnapshotMetricRow('Current concept', currentVisualizationTopic!, AppColors.tealPrimary, isDark),
                    const SizedBox(height: 8),
                    _buildSnapshotMetricRow('Step progress', currentVisualizationProgress ?? 'Active', AppColors.bluePrimary, isDark),
                    const SizedBox(height: 8),
                    _buildSnapshotMetricRow('Visual format', 'Interactive', AppColors.orangePrimary, isDark),
                  ],
                )
              : Column(
                  children: [
                    _buildSnapshotMetricRow('Concepts explored', '$conceptsExplored', AppColors.tealPrimary, isDark),
                    const SizedBox(height: 8),
                    _buildSnapshotMetricRow('Visual explanations', '$visualExplanations', AppColors.bluePrimary, isDark),
                    const SizedBox(height: 8),
                    _buildSnapshotMetricRow('Questions practiced', '$questionsPracticed', AppColors.orangePrimary, isDark),
                  ],
                ),
        ),

        const SizedBox(height: 22),

        // 4. SAVED CONCEPTS
        Text(
          'SAVED CONCEPTS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.getTextMuted(isDark),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        if (savedConcepts.isEmpty)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'No saved concepts yet.',
              style: TextStyle(fontSize: 12, color: AppColors.getTextMuted(isDark), fontStyle: FontStyle.italic),
            ),
          )
        else
          ...savedConcepts.map(
            (concept) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: () => onSelectTopic?.call(concept),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.getSurface(isDark),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.getCardBorder(isDark)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 15, color: AppColors.orangePrimary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          concept,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextPrimary(isDark),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.tealPrimary),
                    ],
                  ),
                ),
              ),
            ),
          ),

        const SizedBox(height: 22),

        // 5. LEARNING TIP
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.getTealLight(isDark),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.getTealBorder(isDark)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.tips_and_updates_rounded, size: 15, color: AppColors.tealPrimary),
                  SizedBox(width: 6),
                  Text(
                    'Learning Tip',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.tealPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                customLearningTip ?? 'Try visualizing difficult concepts step-by-step instead of memorizing them.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFFCCFBF1) : const Color(0xFF134E4A),
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionTile({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.getCardBorder(isDark)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.getTextMuted(isDark),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.getTextMuted(isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildSnapshotMetricRow(String label, String value, Color color, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.getTextSecondary(isDark),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
