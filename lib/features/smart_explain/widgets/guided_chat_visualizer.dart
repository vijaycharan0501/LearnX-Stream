import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'topic_visualization_helper.dart';

/// Rich Guided Socratic Chat Visualizer with interactive checkpoints and instant feedback.
/// (e.g. Artificial Intelligence, Machine Learning, high-level conceptual discovery).
///
/// Features:
/// 1. Progressive bite-sized explanations (e.g. Step 1: What is AI? -> Step 2: How does it learn? -> Step 3: Where is it used?).
/// 2. Interactive checkpoint questions with selectable options.
/// 3. Immediate feedback upon selecting an option (success/correction indicator with rationale).
/// 4. Next/Restart controls to progress through the conversation.
/// 5. "Why this works" pedagogical summary card.
class GuidedChatVisualizer extends StatefulWidget {
  final String topic;
  final Map<String, dynamic>? visualizationData;

  const GuidedChatVisualizer({
    super.key,
    required this.topic,
    this.visualizationData,
  });

  @override
  State<GuidedChatVisualizer> createState() => _GuidedChatVisualizerState();
}

class _GuidedChatVisualizerState extends State<GuidedChatVisualizer> {
  late List<_SocraticStep> _steps;
  late String _whyWorksText;
  int _activeStepIndex = 0;
  final Map<int, int> _selectedAnswers = {}; // stepIndex -> optionIndex

  @override
  void initState() {
    super.initState();
    _initFromData();
  }

  @override
  void didUpdateWidget(covariant GuidedChatVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visualizationData != widget.visualizationData ||
        oldWidget.topic != widget.topic) {
      _initFromData();
    }
  }

  void _initFromData() {
    final rawData = widget.visualizationData;
    final bool hasValidSteps = rawData != null &&
        rawData['steps'] is List &&
        (rawData['steps'] as List).isNotEmpty;

    final data = hasValidSteps
        ? rawData
        : TopicVisualizationHelper.getGuidedChatData(widget.topic, rawData);

    final rawSteps = data['steps'] as List<dynamic>?;

    if (rawSteps != null && rawSteps.isNotEmpty) {
      _steps = rawSteps.map((s) {
        if (s is Map<String, dynamic>) {
          final rawOptions = s['options'] as List<dynamic>?;
          final options = rawOptions != null
              ? rawOptions.map((o) => o.toString()).toList()
              : <String>[];

          return _SocraticStep(
            stepNumber: (s['step_number'] as num?)?.toInt() ?? 1,
            title: s['title']?.toString() ?? 'Concept Step',
            explanation: s['explanation']?.toString() ?? (s['content']?.toString() ?? ''),
            question: s['question']?.toString() ?? '',
            options: options,
            correctIndex: (s['correct_index'] as num?)?.toInt() ?? 0,
            feedback: s['feedback']?.toString() ?? '',
          );
        }
        return _SocraticStep(
          stepNumber: 1,
          title: 'Understanding the Concept',
          explanation: s.toString(),
          question: '',
          options: [],
          correctIndex: 0,
          feedback: '',
        );
      }).toList();
    } else {
      _steps = [];
    }

    _whyWorksText = data['why_this_works'] as String? ??
        'Conversational inquiry promotes deeper conceptual understanding.';

    _activeStepIndex = 0;
    _selectedAnswers.clear();
  }

  void _selectOption(int optionIndex) {
    setState(() {
      _selectedAnswers[_activeStepIndex] = optionIndex;
    });
  }

  void _nextStep() {
    if (_activeStepIndex < _steps.length - 1) {
      setState(() {
        _activeStepIndex++;
      });
    }
  }

  void _previousStep() {
    if (_activeStepIndex > 0) {
      setState(() {
        _activeStepIndex--;
      });
    }
  }

  void _restart() {
    setState(() {
      _activeStepIndex = 0;
      _selectedAnswers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_steps.isEmpty) return const SizedBox.shrink();

    final current = _steps[_activeStepIndex];
    final selectedOption = _selectedAnswers[_activeStepIndex];
    final hasAnswered = selectedOption != null;
    final isCorrect = hasAnswered && selectedOption == current.correctIndex;
    final isFirst = _activeStepIndex == 0;
    final isLast = _activeStepIndex == _steps.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Main Socratic Guided Visualizer Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header & Step Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.tealLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.psychology_rounded, size: 16, color: AppColors.tealPrimary),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Step ${_activeStepIndex + 1}: ${current.title}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_activeStepIndex + 1} of ${_steps.length}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Explanation Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, size: 20, color: AppColors.tealPrimary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        current.explanation,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Interactive Checkpoint Question
              if (current.question.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.tealBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(Icons.help_outline_rounded, size: 16, color: AppColors.tealPrimary),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              current.question,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Options
                      ...List.generate(current.options.length, (optIdx) {
                        final optionText = current.options[optIdx];
                        final isSelected = selectedOption == optIdx;
                        final isThisCorrect = optIdx == current.correctIndex;

                        Color optBg = AppColors.surfaceSecondary;
                        Color optBorder = AppColors.cardBorder;
                        Color optTextColor = AppColors.textPrimary;

                        if (hasAnswered) {
                          if (isThisCorrect) {
                            optBg = AppColors.greenLight;
                            optBorder = AppColors.greenPrimary;
                            optTextColor = AppColors.greenPrimary;
                          } else if (isSelected && !isCorrect) {
                            optBg = AppColors.coralLight;
                            optBorder = AppColors.coralPrimary;
                            optTextColor = AppColors.coralPrimary;
                          }
                        } else if (isSelected) {
                          optBg = AppColors.tealLight;
                          optBorder = AppColors.tealPrimary;
                          optTextColor = AppColors.tealPrimary;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () => _selectOption(optIdx),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                              decoration: BoxDecoration(
                                color: optBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: optBorder, width: isSelected || isThisCorrect ? 1.5 : 1.0),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    hasAnswered
                                        ? (isThisCorrect
                                            ? Icons.check_circle_rounded
                                            : (isSelected ? Icons.cancel_rounded : Icons.radio_button_unchecked_rounded))
                                        : (isSelected
                                            ? Icons.radio_button_checked_rounded
                                            : Icons.radio_button_unchecked_rounded),
                                    size: 16,
                                    color: optTextColor,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      optionText,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected || (hasAnswered && isThisCorrect)
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: optTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                      // Feedback rationale display
                      if (hasAnswered && current.feedback.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isCorrect ? AppColors.greenLight : AppColors.orangeLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isCorrect ? AppColors.greenBorder : AppColors.orangeBorder,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                isCorrect ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                                size: 16,
                                color: isCorrect ? AppColors.greenPrimary : AppColors.orangePrimary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  current.feedback,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: isCorrect ? AppColors.greenPrimary : AppColors.textPrimary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // Navigation controls [Previous] [Next Step] / [Restart]
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isFirst ? null : _previousStep,
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: AppColors.cardBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: AppColors.surface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (isLast)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _restart,
                        icon: const Icon(Icons.replay_rounded, size: 16),
                        label: const Text('Revisit Flow'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tealPrimary,
                          foregroundColor: AppColors.textLight,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _nextStep,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: const Text('Next Step'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tealPrimary,
                          foregroundColor: AppColors.textLight,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 2. "Why this works" Card
        _buildWhyThisWorksCard(),
      ],
    );
  }

  Widget _buildWhyThisWorksCard() {
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
          const Row(
            children: [
              Icon(Icons.lightbulb_rounded, size: 18, color: AppColors.orangePrimary),
              SizedBox(width: 8),
              Text(
                'Why this works',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.orangeLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.orangeBorder),
            ),
            child: Text(
              _whyWorksText,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocraticStep {
  final int stepNumber;
  final String title;
  final String explanation;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String feedback;

  _SocraticStep({
    required this.stepNumber,
    required this.title,
    required this.explanation,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.feedback,
  });
}
