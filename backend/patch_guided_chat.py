import os

file_path = r'c:\Users\vijay\OneDrive\Desktop\WebSites\LearnX Stream\Website LearnX stream\learnx_stream\lib\features\smart_explain\widgets\guided_chat_visualizer.dart'

new_content = '''import 'package:flutter/material.dart';
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
/// 6. 100% theme-adaptive matching Screenshot 1 design language.
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.getSurface(isDark),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.getCardBorder(isDark)),
            boxShadow: AppColors.softShadowFor(isDark),
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
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.getTealLight(isDark),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.psychology_rounded, size: 16, color: AppColors.tealPrimary),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Step ${_activeStepIndex + 1}: ${current.title}',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.getTextPrimary(isDark),
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
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.getSurfaceSecondary(isDark),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.getCardBorder(isDark)),
                    ),
                    child: Text(
                      '${_activeStepIndex + 1} of ${_steps.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Explanation Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.getSurfaceSecondary(isDark),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.getCardBorder(isDark)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppColors.tealPrimary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        current.explanation,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppColors.getTextPrimary(isDark),
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Interactive Checkpoint Question
              if (current.question.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.getSurface(isDark),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.getTealBorder(isDark)),
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
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.getTextPrimary(isDark),
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

                        Color optBg = AppColors.getSurfaceSecondary(isDark);
                        Color optBorder = AppColors.getCardBorder(isDark);
                        Color optTextColor = AppColors.getTextPrimary(isDark);

                        if (hasAnswered) {
                          if (isThisCorrect) {
                            optBg = AppColors.getGreenLight(isDark);
                            optBorder = AppColors.greenPrimary;
                            optTextColor = AppColors.greenPrimary;
                          } else if (isSelected && !isCorrect) {
                            optBg = AppColors.getCoralLight(isDark);
                            optBorder = AppColors.coralPrimary;
                            optTextColor = AppColors.coralPrimary;
                          }
                        } else if (isSelected) {
                          optBg = AppColors.getTealLight(isDark);
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
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                  const SizedBox(width: 8),
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
                            color: isCorrect ? AppColors.getGreenLight(isDark) : AppColors.getOrangeLight(isDark),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isCorrect ? AppColors.greenPrimary : AppColors.orangeBorder,
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
                                    color: isCorrect ? AppColors.greenPrimary : AppColors.getTextPrimary(isDark),
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
                const SizedBox(height: 16),
              ],

              // Step Navigation Controls [Previous] [Next] / [Restart] (Responsive LayoutBuilder)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 420;

                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isFirst ? null : _previousStep,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
                            side: BorderSide(color: AppColors.getCardBorder(isDark)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: AppColors.getSurface(isDark),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_back_rounded,
                                size: 15,
                                color: isFirst ? AppColors.getTextMuted(isDark) : AppColors.getTextPrimary(isDark),
                              ),
                              if (!isCompact) ...[
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Previous',
                                    style: TextStyle(
                                      color: isFirst ? AppColors.getTextMuted(isDark) : AppColors.getTextPrimary(isDark),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLast ? _restart : _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.tealPrimary,
                            foregroundColor: AppColors.textLight,
                            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  isLast ? 'Revisit' : 'Next',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                isLast ? Icons.replay_rounded : Icons.arrow_forward_rounded,
                                size: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. "Why this works" Card
        _buildWhyThisWorksCard(context, isDark),
      ],
    );
  }

  Widget _buildWhyThisWorksCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.getCardBorder(isDark)),
        boxShadow: AppColors.softShadowFor(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded, size: 17, color: AppColors.orangePrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Why this works',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.getTextPrimary(isDark),
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.getOrangeLight(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.orangeBorder),
            ),
            child: Text(
              _whyWorksText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(isDark),
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
'''

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_content)
print("Updated guided_chat_visualizer.dart successfully")
