import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../material_input/models/material_analysis_models.dart';
import '../../material_input/models/study_material.dart';
import '../widgets/visualization_renderer.dart';

/// Smart Explain Studio Screen
///
/// Data-driven visual pedagogical studio for LearnX STREAM.
/// Automatically renders the AI-selected visual explanation method:
/// - "Explain Binary Search" -> Interactive Visualization
/// - "Explain Ohm's Law" -> Simulation
/// - "Explain OOP" -> Concept Map
/// - "Explain TCP Three-Way Handshake" -> Step-by-Step
/// - "Explain Photosynthesis" -> Step-by-Step
/// - "Explain Artificial Intelligence" -> Guided Chat
class SmartExplainScreen extends StatefulWidget {
  final MaterialAnalysisResponse analysis;
  final StudyMaterial? originalMaterial;
  final String? initialMode;

  const SmartExplainScreen({
    super.key,
    required this.analysis,
    this.originalMaterial,
    this.initialMode,
  });

  @override
  State<SmartExplainScreen> createState() => _SmartExplainScreenState();
}

class _SmartExplainScreenState extends State<SmartExplainScreen> {
  late String _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode ?? _resolveInitialMode();
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
    final modes = [
      {
        'id': 'interactive_visualization',
        'label': 'Visual Explanation',
        'desc': 'Understand the concept through interactive visuals',
        'icon': Icons.visibility_rounded,
        'color': AppColors.tealPrimary,
        'bgColor': AppColors.tealLight,
      },
      {
        'id': 'interactive_diagram',
        'label': 'Interactive Diagram',
        'desc': 'Explore relational components and dynamic structures',
        'icon': Icons.layers_rounded,
        'color': AppColors.tealPrimary,
        'bgColor': AppColors.tealLight,
      },
      {
        'id': 'step_by_step',
        'label': 'Step-by-Step',
        'desc': 'Follow the concept one step at a time',
        'icon': Icons.format_list_numbered_rounded,
        'color': AppColors.bluePrimary,
        'bgColor': AppColors.blueLight,
      },
      {
        'id': 'concept_map',
        'label': 'Concept Map',
        'desc': 'See how the main ideas connect',
        'icon': Icons.account_tree_rounded,
        'color': AppColors.purplePrimary,
        'bgColor': AppColors.purpleLight,
      },
      {
        'id': 'simulation',
        'label': 'Interactive Simulation',
        'desc': 'Experiment with the concept and see what changes',
        'icon': Icons.science_rounded,
        'color': AppColors.orangePrimary,
        'bgColor': AppColors.orangeLight,
      },
      {
        'id': 'guided_chat',
        'label': 'Guided Chat',
        'desc': 'Learn through a simple conversation',
        'icon': Icons.forum_rounded,
        'color': AppColors.tealPrimary,
        'bgColor': AppColors.tealLight,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
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
                      const Text(
                        'Explain Differently',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.of(ctx).pop(),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose another way to understand ${widget.analysis.topic}.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...modes.map((mode) {
                    final isSelected = _selectedMode == mode['id'];
                    final color = mode['color'] as Color;
                    final bgColor = mode['bgColor'] as Color;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedMode = mode['id'] as String;
                          });
                          Navigator.of(ctx).pop();
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? bgColor : AppColors.surfaceSecondary,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? color : AppColors.cardBorder,
                              width: isSelected ? 1.8 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.surface : bgColor,
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
                                        color: isSelected ? color : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      mode['desc'] as String,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.textSecondary,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                                size: 18,
                                color: isSelected ? color : AppColors.textMuted,
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
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: AppColors.textSecondary,
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

  @override
  Widget build(BuildContext context) {
    final aiChosenDisplayName = widget.analysis.visualizationDisplayName;
    final activeDisplayName = _getModeDisplayName(_selectedMode);
    final quickCheck = widget.analysis.effectiveQuickCheck;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Smart Explain Studio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back to AI Analysis',
        ),
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. CONCEPT INTRODUCTION: Title, Subtitle, "What is [topic]?" Explanation
                _buildHeaderCard(aiChosenDisplayName, activeDisplayName),
                const SizedBox(height: 18),

                // 1b. FLEXIBLE ANSWER SECTIONS (if provided dynamically by Gemini)
                if (widget.analysis.answer != null && widget.analysis.answer!.sections.isNotEmpty) ...[
                  ..._buildDynamicAnswerSections(),
                  const SizedBox(height: 4),
                ],

                // 2. VISUAL EXPLANATION: Active Interactive Visualization
                if (widget.analysis.isVisualizationEnabled) ...[
                  VisualizationRenderer(
                    analysis: widget.analysis,
                    overrideMode: _selectedMode,
                  ),
                  const SizedBox(height: 18),
                ],

                // 2b. WHAT YOU ARE SEEING: Explanation of the visual model
                if (widget.analysis.visualExplanation != null &&
                    widget.analysis.visualExplanation!.trim().isNotEmpty &&
                    widget.analysis.visualExplanation!.trim() != widget.analysis.effectiveKeyIdea) ...[
                  _buildVisualExplanationCard(),
                  const SizedBox(height: 14),
                ],

                // 3. KEY IDEA / KEY TAKEAWAY: "💡 Key Idea"
                _buildKeyIdeaCard(),
                const SizedBox(height: 14),

                // 4. REAL-WORLD CONNECTION: "🌍 Where you see this" (if available)
                if (widget.analysis.realWorldConnection != null &&
                    widget.analysis.realWorldConnection!.trim().isNotEmpty) ...[
                  _buildRealWorldCard(),
                  const SizedBox(height: 14),
                ],

                // 5. QUICK CHECK: Interactive Concept Check Question
                if (quickCheck != null && quickCheck.enabled && quickCheck.options.isNotEmpty) ...[
                  _QuickCheckCard(quickCheck: quickCheck),
                  const SizedBox(height: 18),
                ],

                // 6. Back Navigation
                _buildBackButton(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDynamicAnswerSections() {
    final sections = widget.analysis.answer?.sections ?? [];
    if (sections.isEmpty) return [];

    return sections.map((section) {
      final heading = section.heading.trim();
      final content = section.content.trim();
      if (heading.isEmpty && content.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (heading.isNotEmpty) ...[
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 15,
                      decoration: BoxDecoration(
                        color: AppColors.tealPrimary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        heading,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Text(
                content,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildHeaderCard(String aiChosenName, String activeName) {
    final isCustomMode = _selectedMode != _resolveInitialMode();
    final cleanTopic = widget.analysis.topic
        .replaceFirst(RegExp(r'^(Explain|explain|What is|what is)\s+', caseSensitive: false), '')
        .trim();
    final displayTopicName = cleanTopic.isNotEmpty ? cleanTopic : widget.analysis.topic;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges Row: "AI chose: [Method]" + "Try another way"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.tealLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.tealBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 13, color: AppColors.tealPrimary),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          isCustomMode ? 'Showing: $activeName' : 'AI chose: $aiChosenName',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.tealPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _showTryAnotherWayBottomSheet,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tune_rounded, size: 13, color: AppColors.textSecondary),
                      SizedBox(width: 5),
                      Text(
                        'Try another way',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Topic Title
          Text(
            widget.analysis.topic,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),

          // Subtitle
          const Text(
            "Let's understand it visually.",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),

          // Concept Introduction: "What is [topic]?"
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.tealPrimary),
                    const SizedBox(width: 6),
                    Text(
                      'What is $displayTopicName?',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.analysis.effectiveOverview,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualExplanationCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.tealBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.visibility_rounded, size: 18, color: AppColors.tealPrimary),
              SizedBox(width: 8),
              Text(
                'What You Are Seeing',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.analysis.visualExplanation!,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyIdeaCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.orangeLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.orangeBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('💡', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text(
                'Key Idea',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.analysis.effectiveKeyIdea,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealWorldCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🌍', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text(
                'Where you see this',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.analysis.realWorldConnection!,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: AppColors.cardBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: AppColors.surface,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.textPrimary),
            SizedBox(width: 8),
            Text(
              'Back to AI Analysis',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Interactive Quick Check Multiple-Choice Widget with instant feedback
class _QuickCheckCard extends StatefulWidget {
  final QuickCheck quickCheck;

  const _QuickCheckCard({required this.quickCheck});

  @override
  State<_QuickCheckCard> createState() => _QuickCheckCardState();
}

class _QuickCheckCardState extends State<_QuickCheckCard> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final qc = widget.quickCheck;
    final bool hasAnswered = _selectedIndex != null;
    final bool isCorrect = hasAnswered &&
        _selectedIndex! < qc.options.length &&
        qc.options[_selectedIndex!].trim().toLowerCase() ==
            qc.correctAnswer.trim().toLowerCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.purpleLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.quiz_rounded,
                  size: 16,
                  color: AppColors.purplePrimary,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Quick Check',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Question Text
          Text(
            qc.question,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),

          // Options List
          ...List.generate(qc.options.length, (index) {
            final option = qc.options[index];
            final isThisSelected = _selectedIndex == index;
            final isThisCorrectAnswer =
                option.trim().toLowerCase() == qc.correctAnswer.trim().toLowerCase();

            Color borderColor = AppColors.cardBorder;
            Color bgColor = AppColors.surfaceSecondary;
            Color textColor = AppColors.textPrimary;
            IconData? statusIcon;
            Color iconColor = AppColors.textSecondary;

            if (hasAnswered) {
              if (isThisCorrectAnswer) {
                borderColor = AppColors.greenBorder;
                bgColor = AppColors.greenLight;
                textColor = AppColors.greenPrimary;
                statusIcon = Icons.check_circle_rounded;
                iconColor = AppColors.greenPrimary;
              } else if (isThisSelected) {
                borderColor = AppColors.coralBorder;
                bgColor = AppColors.coralLight;
                textColor = AppColors.coralPrimary;
                statusIcon = Icons.cancel_rounded;
                iconColor = AppColors.coralPrimary;
              }
            } else if (isThisSelected) {
              borderColor = AppColors.tealPrimary;
              bgColor = AppColors.tealLight;
              textColor = AppColors.tealPrimary;
            }

            final optionLetter = String.fromCharCode(65 + index); // A, B, C, D

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: isThisSelected || (hasAnswered && isThisCorrectAnswer) ? 1.6 : 1.0),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isThisSelected || (hasAnswered && isThisCorrectAnswer)
                              ? AppColors.surface
                              : AppColors.cardBorder,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          optionLetter,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isThisSelected || (hasAnswered && isThisCorrectAnswer)
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (statusIcon != null) ...[
                        const SizedBox(width: 6),
                        Icon(statusIcon, size: 18, color: iconColor),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),

          // Feedback Banner after answering
          if (hasAnswered) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCorrect ? AppColors.greenLight : AppColors.coralLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCorrect ? AppColors.greenBorder : AppColors.coralBorder,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
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
                        if (qc.explanation.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            qc.explanation,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
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
