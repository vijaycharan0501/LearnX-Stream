import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../material_input/models/material_input_data.dart';
import '../../material_input/screens/material_input_screen.dart';
import '../widgets/concept_item_card.dart';
import '../widgets/hero_smart_explain_card.dart';
import '../widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToLearn;
  final VoidCallback? onNavigateToPractice;
  final VoidCallback? onNavigateToProgress;

  const HomeScreen({
    super.key,
    this.onNavigateToLearn,
    this.onNavigateToPractice,
    this.onNavigateToProgress,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToMaterialInput({
    InputMethod initialMethod = InputMethod.scan,
    String? initialTopic,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MaterialInputScreen(
          initialMethod: initialMethod,
          initialTopic: initialTopic,
        ),
      ),
    );
  }

  void _handleSearchSubmit() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _navigateToMaterialInput(
        initialMethod: InputMethod.topic,
        initialTopic: query,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top App Brand Bar & Profile
                _buildTopBrandHeader(),
                const SizedBox(height: 18),

                // Large Main Question Input & Send Card
                _buildMainQuestionCard(),
                const SizedBox(height: 16),

                // Compact Quick Input Tools (Scan, Upload, Voice)
                _buildCompactInputTools(),
                const SizedBox(height: 22),

                // Hero "Smart Explain" Card (Quick Start)
                HeroSmartExplainCard(
                  onTap: () => _navigateToMaterialInput(
                    initialMethod: InputMethod.topic,
                    initialTopic: 'Binary Search',
                  ),
                ),
                const SizedBox(height: 24),

                // Section: Recent & Recommended Concepts
                const SectionHeader(
                  title: 'Recent Concepts',
                  subtitle: 'Pick up where you left off',
                ),
                const SizedBox(height: 10),
                ConceptItemCard(
                  title: 'Photosynthesis',
                  category: 'Biology • Cellular Energy & Calvin Cycle',
                  statusText: 'Visual Ready',
                  icon: Icons.eco_rounded,
                  type: ConceptCardType.recent,
                  onTap: () => _navigateToMaterialInput(
                    initialMethod: InputMethod.topic,
                    initialTopic: 'Photosynthesis',
                  ),
                ),
                const SizedBox(height: 10),
                ConceptItemCard(
                  title: 'Binary Search',
                  category: 'Algorithms • Divide and Conquer',
                  statusText: 'Interactive',
                  icon: Icons.search_rounded,
                  type: ConceptCardType.recent,
                  onTap: () => _navigateToMaterialInput(
                    initialMethod: InputMethod.topic,
                    initialTopic: 'Binary Search',
                  ),
                ),
                const SizedBox(height: 10),
                ConceptItemCard(
                  title: "Ohm's Law",
                  category: 'Physics • Circuit Simulation',
                  statusText: 'Interactive Sim',
                  icon: Icons.electric_bolt_rounded,
                  type: ConceptCardType.recent,
                  onTap: () => _navigateToMaterialInput(
                    initialMethod: InputMethod.topic,
                    initialTopic: "Ohm's Law",
                  ),
                ),
                const SizedBox(height: 10),
                ConceptItemCard(
                  title: 'OOP (Object-Oriented Programming)',
                  category: 'Software Engineering • Hierarchy',
                  statusText: 'Concept Map',
                  icon: Icons.category_outlined,
                  type: ConceptCardType.recent,
                  onTap: () => _navigateToMaterialInput(
                    initialMethod: InputMethod.topic,
                    initialTopic: 'Object-Oriented Programming (OOP)',
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBrandHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Brand Logo & Name
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.tealPrimary, Color(0xFF0F766E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.tealPrimary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.stream_rounded,
                  color: AppColors.textLight,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'LEARNX',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'STREAM',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.tealPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Turn questions into understanding.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Right side profile avatar
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.tealLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.tealBorder, width: 1.2),
          ),
          child: const Center(
            child: Text(
              'LX',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.tealPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainQuestionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What do you want to understand?',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),

          // Input Box with Send Button
          Container(
            padding: const EdgeInsets.only(left: 14, right: 6, top: 4, bottom: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.tealPrimary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _handleSearchSubmit(),
                    decoration: const InputDecoration(
                      hintText: 'Ask any question or topic...',
                      hintStyle: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                InkWell(
                  onTap: _handleSearchSubmit,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.tealPrimary, Color(0xFF0F766E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Send',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textLight,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, color: AppColors.textLight, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Example Prompts Chips
          const Text(
            'Examples:',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildExampleChip('Explain photosynthesis'),
              _buildExampleChip('How does binary search work?'),
              _buildExampleChip("Explain Ohm's Law"),
              _buildExampleChip('Explain OOP inheritance'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExampleChip(String topic) {
    return InkWell(
      onTap: () {
        _searchController.text = topic;
        _navigateToMaterialInput(
          initialMethod: InputMethod.topic,
          initialTopic: topic,
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.tealLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.tealBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt_rounded, size: 12, color: AppColors.tealPrimary),
            const SizedBox(width: 4),
            Text(
              topic,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.tealPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactInputTools() {
    return Row(
      children: [
        Expanded(
          child: _buildToolButton(
            icon: Icons.document_scanner_rounded,
            label: 'Scan Material',
            color: AppColors.tealPrimary,
            bgColor: AppColors.tealLight,
            borderColor: AppColors.tealBorder,
            onTap: () => _navigateToMaterialInput(initialMethod: InputMethod.scan),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildToolButton(
            icon: Icons.upload_file_rounded,
            label: 'Upload PDF',
            color: AppColors.bluePrimary,
            bgColor: AppColors.blueLight,
            borderColor: AppColors.blueBorder,
            onTap: () => _navigateToMaterialInput(initialMethod: InputMethod.upload),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildToolButton(
            icon: Icons.mic_rounded,
            label: 'Voice Question',
            color: AppColors.purplePrimary,
            bgColor: AppColors.purpleLight,
            borderColor: AppColors.purpleBorder,
            onTap: () => _navigateToMaterialInput(initialMethod: InputMethod.voice),
          ),
        ),
      ],
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
