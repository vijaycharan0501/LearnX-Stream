import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/responsive_layout.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
            tooltip: 'Search concepts',
          ),
        ],
      ),
      body: ResponsiveLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.tealLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.tealBorder),
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: AppColors.tealPrimary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Interactive Concept Studio',
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Browse deep representations, interactive diagrams, concept maps, and AI workflows for your topics.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Placeholder Concept Modules
              Text(
                'Explore Formats',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _buildFormatCard(
                context,
                icon: Icons.account_tree_outlined,
                title: 'Concept Maps',
                subtitle: 'Visual knowledge hierarchy & relations',
                color: AppColors.bluePrimary,
                bgColor: AppColors.blueLight,
                borderColor: AppColors.blueBorder,
              ),
              const SizedBox(height: 12),
              _buildFormatCard(
                context,
                icon: Icons.science_outlined,
                title: 'Interactive Simulations',
                subtitle: 'Dynamic parameter exploration and physics/logic demos',
                color: AppColors.tealPrimary,
                bgColor: AppColors.tealLight,
                borderColor: AppColors.tealBorder,
              ),
              const SizedBox(height: 12),
              _buildFormatCard(
                context,
                icon: Icons.schema_outlined,
                title: 'Workflow Diagrams',
                subtitle: 'Step-by-step algorithmic flows and protocol stages',
                color: AppColors.orangePrimary,
                bgColor: AppColors.orangeLight,
                borderColor: AppColors.orangeBorder,
              ),
            ],
          ),
        ),
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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
    );
  }
}
