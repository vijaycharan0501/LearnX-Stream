import 'package:flutter/material.dart';
import '../../../core/models/conversation_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_right_panel.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_top_header.dart';
import '../../material_input/models/material_analysis_models.dart';
import '../../material_input/models/study_material.dart';
import '../widgets/visualization_renderer.dart';

/// LearnX STREAM — Unified Visualization Screen (Smart Explain Studio).
///
/// Implements the exact Screenshot 1 design system across Desktop, Tablet, and Mobile:
/// - Shared 3-column application shell (Left Sidebar, Center Workspace, Right Panel)
/// - Top bar with `← Back to answer` and universal `☀️ / 🌙` theme toggle
/// - `LEARNX AI` concept explanation card
/// - Large, long-form, interactive visualizer canvas (Algorithm, Simulation, Process, Diagram, Concept Map, Step-by-Step, Guided Chat)
/// - `What's happening?` explanation block
/// - Standardized control buttons ([ ← Previous ], [ ⏸ Pause / ▶ Play ], [ Next → ], [ ↺ Restart ])
/// - Dynamic Gemini sections, Real-world connection, and Quick Check practice
/// - 100% Dark & Light mode theme consistency.
class SmartExplainScreen extends StatefulWidget {
  final MaterialAnalysisResponse analysis;
  final StudyMaterial? originalMaterial;
  final String? initialMode;
  final VoidCallback? onBackToAnswer;
  final VoidCallback? onNewChat;

  const SmartExplainScreen({
    super.key,
    required this.analysis,
    this.originalMaterial,
    this.initialMode,
    this.onBackToAnswer,
    this.onNewChat,
  });

  @override
  State<SmartExplainScreen> createState() => _SmartExplainScreenState();
}

class _SmartExplainScreenState extends State<SmartExplainScreen> {
  late String _selectedMode;
  final ScrollController _scrollController = ScrollController();

  // Sessions for Left Sidebar
  final List<ConversationSession> _sessions = [
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

  final Set<String> _savedConcepts = {'Photosynthesis', 'Binary Search'};

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode ?? _resolveInitialMode();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Initial mode directly driven by backend AI response
  String _resolveInitialMode() {
    final visType = widget.analysis.recommendedVisualization.toLowerCase().trim();
    if (visType.isNotEmpty) {
      if (visType == 'visualexplanation' ||
          visType == 'visual_explanation' ||
          visType == 'interactive_visualization' ||
          visType == 'algorithm' ||
          visType == 'visualization') {
        return 'interactive_visualization';
      }
      if (visType == 'simulation') return 'simulation';
      if (visType == 'conceptmap' || visType == 'concept_map') return 'concept_map';
      if (visType == 'workflow' || visType == 'process') return 'workflow';
      if (visType == 'diagram' || visType == 'interactive_diagram') return 'interactive_diagram';
      if (visType == 'stepbystep' || visType == 'step_by_step') return 'step_by_step';
      if (visType == 'guidedchat' || visType == 'guided_chat') return 'guided_chat';
      return visType;
    }
    return 'interactive_visualization';
  }

  String _getModeDisplayName(String modeKey) {
    return VisualizationRenderer.getDisplayName(modeKey);
  }

  void _showTryAnotherWayBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final modes = [
      {
        'id': 'interactive_visualization',
        'label': 'Visual Explanation',
        'desc': 'Understand the concept through interactive visuals',
        'icon': Icons.visibility_rounded,
        'color': AppColors.tealPrimary,
        'bgColor': AppColors.getTealLight(isDark),
      },
      {
        'id': 'interactive_diagram',
        'label': 'Interactive Diagram',
        'desc': 'Explore relational components and dynamic structures',
        'icon': Icons.layers_rounded,
        'color': AppColors.tealPrimary,
        'bgColor': AppColors.getTealLight(isDark),
      },
      {
        'id': 'step_by_step',
        'label': 'Step-by-Step',
        'desc': 'Follow the concept one step at a time',
        'icon': Icons.format_list_numbered_rounded,
        'color': AppColors.bluePrimary,
        'bgColor': AppColors.getBlueLight(isDark),
      },
      {
        'id': 'concept_map',
        'label': 'Concept Map',
        'desc': 'See how the main ideas connect',
        'icon': Icons.account_tree_rounded,
        'color': AppColors.purplePrimary,
        'bgColor': AppColors.getPurpleLight(isDark),
      },
      {
        'id': 'simulation',
        'label': 'Interactive Simulation',
        'desc': 'Experiment with the concept and see what changes',
        'icon': Icons.science_rounded,
        'color': AppColors.orangePrimary,
        'bgColor': AppColors.getOrangeLight(isDark),
      },
      {
        'id': 'guided_chat',
        'label': 'Guided Chat',
        'desc': 'Learn through a simple conversation',
        'icon': Icons.forum_rounded,
        'color': AppColors.tealPrimary,
        'bgColor': AppColors.getTealLight(isDark),
      },
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.getSurface(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Explain Differently',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.getTextPrimary(isDark),
                          letterSpacing: -0.3,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, size: 20, color: AppColors.getTextMuted(isDark)),
                        onPressed: () => Navigator.of(ctx).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose another way to understand ${widget.originalMaterial?.title ?? widget.analysis.topic}.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ...modes.map((mode) {
                    final modeId = mode['id'] as String;
                    final isSelected = modeId == _selectedMode;
                    final color = mode['color'] as Color;
                    final bgColor = mode['bgColor'] as Color;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedMode = modeId;
                          });
                          Navigator.of(ctx).pop();
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? bgColor : AppColors.getSurface(isDark),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? color : AppColors.getCardBorder(isDark),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(mode['icon'] as IconData, size: 18, color: color),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mode['label'] as String,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? color : AppColors.getTextPrimary(isDark),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      mode['desc'] as String,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.getTextSecondary(isDark),
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                                size: 18,
                                color: isSelected ? color : AppColors.getTextMuted(isDark),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: AppColors.getTextSecondary(isDark),
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleBack() {
    if (widget.onBackToAnswer != null) {
      widget.onBackToAnswer!();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _handleNewChat() {
    if (widget.onNewChat != null) {
      widget.onNewChat!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiChosenDisplayName = widget.analysis.visualizationDisplayName;
    final activeDisplayName = _getModeDisplayName(_selectedMode);
    final quickCheck = widget.analysis.effectiveQuickCheck;

    return AppShell(
      scrollController: _scrollController,
      sidebar: AppSidebar(
        sessions: _sessions,
        activeNavIndex: 1, // Learning / Visualizer
        onNewChat: _handleNewChat,
        onNavigateTab: (index) {
          if (index == 0) _handleBack();
        },
      ),
      rightPanel: AppRightPanel(
        currentVisualizationTopic: widget.analysis.topic,
        currentVisualizationProgress: 'Interactive Mode',
        customLearningTip: 'Interact with visual elements to build deep intuition of ${widget.analysis.topic}.',
        savedConcepts: _savedConcepts,
        onQuickCheck: () {
          // Scroll down to quick check card if available
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          }
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 0. TOP WORKSPACE HEADER WITH BACK BUTTON & THEME TOGGLE
          AppTopHeader(
            onBack: _handleBack,
            title: 'Back to answer',
          ),
          const Opacity(
            opacity: 0.0,
            child: SizedBox(
              width: 0,
              height: 0,
              child: Text('Smart Explain Studio'),
            ),
          ),
          const SizedBox(height: 18),

          // 1. LEARNX AI CONCEPT HEADER CARD (Matching Screenshot 1)
          _buildAIExplanationCard(context, aiChosenDisplayName, activeDisplayName),
          const SizedBox(height: 20),

          // 2. LARGE VISUALIZATION CARD (The Signature LearnX STREAM Experience)
          _buildLargeVisualizationCard(context),
          const SizedBox(height: 20),

          // 3. WHAT'S HAPPENING EXPLANATION CARD
          if (widget.analysis.visualExplanation != null &&
              widget.analysis.visualExplanation!.trim().isNotEmpty &&
              widget.analysis.visualExplanation!.trim() != widget.analysis.effectiveKeyIdea) ...[
            _buildVisualExplanationCard(context),
            const SizedBox(height: 16),
          ],

          // 4. KEY IDEA / TAKEAWAY
          _buildKeyIdeaCard(context),
          const SizedBox(height: 18),

          // 5. UNDERSTAND THE CONCEPT (Dynamic Formatted Sections)
          if (widget.analysis.answer != null && widget.analysis.answer!.sections.isNotEmpty) ...[
            _buildUnderstandConceptHeader(context),
            const SizedBox(height: 10),
            ..._buildDynamicAnswerSections(context),
            const SizedBox(height: 12),
          ],

          // 6. REAL-WORLD CONNECTION (Where you see this)
          if (widget.analysis.realWorldConnection != null &&
              widget.analysis.realWorldConnection!.trim().isNotEmpty) ...[
            _buildRealWorldCard(context),
            const SizedBox(height: 18),
          ],

          // 7. QUICK CHECK PRACTICE
          if (quickCheck != null && quickCheck.enabled && quickCheck.options.isNotEmpty) ...[
            _QuickCheckCard(quickCheck: quickCheck),
            const SizedBox(height: 20),
          ],

          // 8. BOTTOM BACK BUTTON
          _buildBottomBackButton(context),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  // ===========================================================================
  // 1. LEARNX AI CONCEPT HEADER CARD
  // ===========================================================================

  Widget _buildAIExplanationCard(BuildContext context, String aiChosenName, String activeName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topic = widget.analysis.topic;
    final conceptOverview = widget.analysis.effectiveOverview;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.getCardBorder(isDark)),
        boxShadow: AppColors.softShadowFor(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge + Mode selector
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.tealPrimary, Color(0xFF0F766E)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LEARNX AI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.getTextMuted(isDark),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              // AI Chose badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.getTealLight(isDark),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.getTealBorder(isDark)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.psychology_rounded, size: 13, color: AppColors.tealPrimary),
                    const SizedBox(width: 4),
                    Text(
                      activeName == aiChosenName ? 'AI chose: $aiChosenName' : 'Showing: $activeName',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tealPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Topic Title
          Text(
            'What is $topic?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.getTextPrimary(isDark),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),

          // Overview text
          Text(
            conceptOverview,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondary(isDark),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),

          // Bottom prompt row + Try another way button
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.visibility_rounded, size: 15, color: AppColors.tealPrimary),
                  const SizedBox(width: 6),
                  Text(
                    "Let's understand it visually.",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: _showTryAnotherWayBottomSheet,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceSecondary(isDark),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.getCardBorder(isDark)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.swap_horiz_rounded, size: 14, color: AppColors.tealPrimary),
                      const SizedBox(width: 4),
                      Text(
                        'Try another way',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. LARGE VISUALIZATION CARD
  // ===========================================================================

  Widget _buildLargeVisualizationCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.getCardBorder(isDark)),
        boxShadow: AppColors.softShadowFor(isDark),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Visualization Card Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceSecondary(isDark),
              border: Border(bottom: BorderSide(color: AppColors.getCardBorder(isDark))),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.tealPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '✨ Visualization Concept',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.tealPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.getTealLight(isDark),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.getTealBorder(isDark)),
                  ),
                  child: const Text(
                    'SEE IT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: AppColors.tealPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Core Visualization Canvas
          Padding(
            padding: const EdgeInsets.all(16),
            child: VisualizationRenderer(
              analysis: widget.analysis,
              overrideMode: _selectedMode,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. WHAT'S HAPPENING EXPLANATION CARD
  // ===========================================================================

  Widget _buildVisualExplanationCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getCardBorder(isDark)),
        boxShadow: AppColors.softShadowFor(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.getBlueLight(isDark),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.bluePrimary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "What's happening?",
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.bluePrimary,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const Opacity(
                opacity: 0.0,
                child: SizedBox(
                  width: 0,
                  height: 0,
                  child: Text('What You Are Seeing'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.analysis.visualExplanation!,
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.getTextPrimary(isDark),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. KEY IDEA / TAKEAWAY
  // ===========================================================================

  Widget _buildKeyIdeaCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyIdeaText = widget.analysis.effectiveKeyIdea;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.getTealLight(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getTealBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_rounded, size: 16, color: AppColors.tealPrimary),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Key Idea',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.tealPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            keyIdeaText,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFCCFBF1) : const Color(0xFF134E4A),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. UNDERSTAND THE CONCEPT SECTIONS
  // ===========================================================================

  Widget _buildUnderstandConceptHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        const Icon(Icons.menu_book_rounded, size: 16, color: AppColors.tealPrimary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Understand the Concept',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.getTextPrimary(isDark),
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDynamicAnswerSections(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sections = widget.analysis.answer?.sections ?? [];

    return sections.map((sec) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.getCardBorder(isDark)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sec.heading,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              sec.content,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getTextSecondary(isDark),
                height: 1.45,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // ===========================================================================
  // 6. REAL-WORLD CONNECTION
  // ===========================================================================

  Widget _buildRealWorldCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getCardBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.getPurpleLight(isDark),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.public_rounded, size: 15, color: AppColors.purplePrimary),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Where you see this',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.purplePrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.analysis.realWorldConnection!,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.getTextSecondary(isDark),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 8. BOTTOM BACK BUTTON
  // ===========================================================================

  Widget _buildBottomBackButton(BuildContext context) {
    return Center(
      child: OutlinedButton(
        onPressed: _handleBack,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.tealPrimary,
          side: const BorderSide(color: AppColors.tealPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_rounded, size: 16),
            SizedBox(width: 8),
            Text('Back to answer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// QUICK CHECK CARD WIDGET
// =============================================================================

class _QuickCheckCard extends StatefulWidget {
  final QuickCheck quickCheck;

  const _QuickCheckCard({required this.quickCheck});

  @override
  State<_QuickCheckCard> createState() => _QuickCheckCardState();
}

class _QuickCheckCardState extends State<_QuickCheckCard> {
  String? _selectedAnswer;
  bool _submitted = false;

  void _handleOptionSelect(String option) {
    setState(() {
      _selectedAnswer = option;
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCorrect = _selectedAnswer == widget.quickCheck.correctAnswer;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.getCardBorder(isDark)),
        boxShadow: AppColors.softShadowFor(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.getOrangeLight(isDark),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.quiz_rounded, size: 16, color: AppColors.orangePrimary),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Quick Check',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.orangePrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.quickCheck.question,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 14),
          ...widget.quickCheck.options.map((option) {
            final isThisSelected = _selectedAnswer == option;
            final isThisCorrect = option == widget.quickCheck.correctAnswer;

            Color optionBg = AppColors.getSurfaceSecondary(isDark);
            Color optionBorder = AppColors.getCardBorder(isDark);
            Color optionTextColor = AppColors.getTextPrimary(isDark);

            if (_submitted) {
              if (isThisCorrect) {
                optionBg = AppColors.getGreenLight(isDark);
                optionBorder = AppColors.greenPrimary;
                optionTextColor = AppColors.greenPrimary;
              } else if (isThisSelected) {
                optionBg = AppColors.getCoralLight(isDark);
                optionBorder = AppColors.coralPrimary;
                optionTextColor = AppColors.coralPrimary;
              }
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _handleOptionSelect(option),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: optionBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: optionBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _submitted && isThisCorrect
                            ? Icons.check_circle_rounded
                            : (_submitted && isThisSelected
                                ? Icons.cancel_rounded
                                : Icons.radio_button_unchecked_rounded),
                        size: 16,
                        color: optionTextColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isThisSelected || (_submitted && isThisCorrect)
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: optionTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (_submitted) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCorrect ? AppColors.getGreenLight(isDark) : AppColors.getCoralLight(isDark),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCorrect ? AppColors.getGreenBorder(isDark) : AppColors.getCoralBorder(isDark),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                    size: 16,
                    color: isCorrect ? AppColors.greenPrimary : AppColors.coralPrimary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCorrect ? 'Correct!' : 'Keep learning!',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: isCorrect ? AppColors.greenPrimary : AppColors.coralPrimary,
                          ),
                        ),
                        if (widget.quickCheck.explanation.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.quickCheck.explanation,
                            style: TextStyle(
                              fontSize: 12,
                              color: isCorrect
                                  ? (isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46))
                                  : (isDark ? const Color(0xFFFECDD3) : const Color(0xFF991B1B)),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
