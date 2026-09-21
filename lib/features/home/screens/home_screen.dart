import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../material_input/models/material_input_data.dart';
import '../../material_input/screens/material_input_screen.dart';
import '../widgets/action_card.dart';
import '../widgets/concept_item_card.dart';
import '../widgets/hero_smart_explain_card.dart';
import '../widgets/mastery_summary_card.dart';
import '../widgets/section_header.dart';
import '../widgets/today_revision_card.dart';

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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top App Brand Bar & Profile
                _buildTopBrandHeader(),
                const SizedBox(height: 20),

                // Greeting Section
                _buildGreetingSection(),
                const SizedBox(height: 16),

                // Universal Ask / Search Bar
                _buildSearchBar(),
                const SizedBox(height: 20),

                // Hero "Smart Explain" Card
                HeroSmartExplainCard(
                  onTap: () => _navigateToMaterialInput(
                    initialMethod: InputMethod.topic,
                    initialTopic: 'Binary Search',
                  ),
                ),
                const SizedBox(height: 28),

                // Section: Main Learning Actions
                const SectionHeader(
                  title: 'Learn New Material',
                  subtitle: 'Transform notes, documents, or topics into deep understanding',
                ),
                const SizedBox(height: 12),
                ActionCard(
                  title: 'Scan Material',
                  subtitle: 'Capture a textbook or notes',
                  icon: Icons.document_scanner_rounded,
                  accentColor: AppColors.tealPrimary,
                  lightColor: AppColors.tealLight,
                  borderColor: AppColors.tealBorder,
                  onTap: () => _navigateToMaterialInput(
                    initialMethod: InputMethod.scan,
                  ),
                ),
                const SizedBox(height: 10),
                ActionCard(
                  title: 'Upload PDF / Image',
                  subtitle: 'Learn from your study material',
                  icon: Icons.upload_file_rounded,
                  accentColor: AppColors.bluePrimary,
                  lightColor: AppColors.blueLight,
                  borderColor: AppColors.blueBorder,
                  onTap: () => _navigateToMaterialInput(
                    initialMethod: InputMethod.upload,
                  ),
                ),
                const SizedBox(height: 10),
                ActionCard(
                  title: 'Enter Topic',
                  subtitle: 'Start with any concept',
                  icon: Icons.lightbulb_outline_rounded,
                  accentColor: AppColors.orangePrimary,
                  lightColor: AppColors.orangeLight,
                  borderColor: AppColors.orangeBorder,
                  onTap: () => _navigateToMaterialInput(
                    initialMethod: InputMethod.topic,
                  ),
                ),
                const SizedBox(height: 10),
                ActionCard(
                  title: 'Voice Question',
                  subtitle: 'Speak your question or concept',
                  icon: Icons.mic_rounded,
                  accentColor: AppColors.purplePrimary,
                  lightColor: AppColors.purpleLight,
                  borderColor: AppColors.purpleBorder,
                  onTap: () => _navigateToMaterialInput(
                    initialMethod: InputMethod.voice,
                  ),
                ),
                const SizedBox(height: 28),

                // Section: Mastery Summary
                SectionHeader(
                  title: 'Mastery Summary',
                  actionText: 'View Analytics',
                  onActionPressed: widget.onNavigateToProgress,
                ),
                const SizedBox(height: 12),
                MasterySummaryCard(
                  masteryPercentage: 73,
                  masteredCount: 15,
                  totalCount: 20,
                  onTap: widget.onNavigateToProgress,
                ),
                const SizedBox(height: 28),

                // Section: Today's Revision
                SectionHeader(
                  title: "Today's Revision",
                  subtitle: 'Optimal spaced interval for long-term retention',
                  actionText: 'All Tasks',
                  onActionPressed: widget.onNavigateToPractice,
                ),
                const SizedBox(height: 12),
                TodayRevisionCard(
                  topic: 'Binary Search',
                  taskType: 'Application practice',
                  duration: '4 mins',
                  onStartPressed: widget.onNavigateToPractice,
                ),
                const SizedBox(height: 28),

                // Section: Weak Concepts
                SectionHeader(
                  title: 'Weak Concepts',
                  subtitle: 'Recommended for targeted simulation and review',
                  actionText: 'Practice All',
                  onActionPressed: widget.onNavigateToPractice,
                ),
                const SizedBox(height: 12),
                ConceptItemCard(
                  title: 'Graphs',
                  category: 'Data Structures & Algorithms',
                  statusText: '42% Mastery',
                  icon: Icons.hub_outlined,
                  type: ConceptCardType.weak,
                  onTap: () => _navigateToMaterialInput(
                    initialMethod: InputMethod.topic,
                    initialTopic: 'Graphs & BFS/DFS Algorithms',
                  ),
                ),
                const SizedBox(height: 10),
                ConceptItemCard(
                  title: 'Linked Lists',
                  category: 'Pointers & Memory Layout',
                  statusText: '55% Mastery',
                  icon: Icons.link_rounded,
                  type: ConceptCardType.weak,
                  onTap: () => _navigateToMaterialInput(
                    initialMethod: InputMethod.topic,
                    initialTopic: 'Linked Lists & Pointer Operations',
                  ),
                ),
                const SizedBox(height: 28),

                // Section: Recent Concepts
                SectionHeader(
                  title: 'Recent Concepts',
                  subtitle: 'Pick up where you left off',
                  actionText: 'Library',
                  onActionPressed: widget.onNavigateToLearn,
                ),
                const SizedBox(height: 12),
                ConceptItemCard(
                  title: 'Binary Search',
                  category: 'Algorithms • Divide and conquer',
                  statusText: 'Reviewed Today',
                  icon: Icons.search_rounded,
                  type: ConceptCardType.recent,
                  onTap: () => _navigateToMaterialInput(
                    initialMethod: InputMethod.topic,
                    initialTopic: 'Binary Search',
                  ),
                ),
                const SizedBox(height: 10),
                ConceptItemCard(
                  title: 'OOP (Object-Oriented Programming)',
                  category: 'Software Engineering • Polymorphism',
                  statusText: 'Mastered 88%',
                  icon: Icons.category_outlined,
                  type: ConceptCardType.recent,
                  onTap: () => _navigateToMaterialInput(
                    initialMethod: InputMethod.topic,
                    initialTopic: 'Object-Oriented Programming (OOP)',
                  ),
                ),
                const SizedBox(height: 10),
                ConceptItemCard(
                  title: 'TCP Three-Way Handshake',
                  category: 'Computer Networks • Protocol State',
                  statusText: 'Simulation Done',
                  icon: Icons.sync_alt_rounded,
                  type: ConceptCardType.recent,
                  onTap: () => _navigateToMaterialInput(
                    initialMethod: InputMethod.topic,
                    initialTopic: 'TCP Three-Way Handshake',
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
                      'LearnX',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'STREAM',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.tealPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Turn Information Into Understanding',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Right side badges: Streak and Profile Avatar
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.orangeLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.orangeBorder, width: 0.9),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 15,
                    color: AppColors.orangePrimary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '4d',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.orangePrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
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
        ),
      ],
    );
  }

  Widget _buildGreetingSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning 👋',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.6,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'What do you want to learn today?',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.softShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.tealPrimary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _handleSearchSubmit(),
              decoration: const InputDecoration(
                hintText: 'Ask a question or type a topic...',
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
          IconButton(
            icon: const Icon(Icons.mic_none_rounded, color: AppColors.purplePrimary, size: 20),
            tooltip: 'Voice Input',
            onPressed: () => _navigateToMaterialInput(initialMethod: InputMethod.voice),
          ),
          IconButton(
            icon: const Icon(Icons.document_scanner_outlined, color: AppColors.tealPrimary, size: 20),
            tooltip: 'Scan Study Material',
            onPressed: () => _navigateToMaterialInput(initialMethod: InputMethod.scan),
          ),
        ],
      ),
    );
  }
}
