import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Interactive Visualizer for Search & Sorting Algorithms (e.g. Binary Search).
///
/// Features:
/// 1. Visual array with dynamic state (active, highlighted middle, faded discarded half, found target).
/// 2. Step-by-step logic breakdown with explicit comparison (e.g. `60 > 40 -> Search RIGHT half`).
/// 3. Clear Previous, Next, and Restart navigation controls.
/// 4. "Why did we ignore the left half?" pedagogical insight card.
/// 5. "Try it yourself" interactive target picker allowing students to experiment with any number.
class InteractiveVisualizer extends StatefulWidget {
  final int initialTarget;
  final Map<String, dynamic>? visualizationData;

  const InteractiveVisualizer({
    super.key,
    this.initialTarget = 60,
    this.visualizationData,
  });

  @override
  State<InteractiveVisualizer> createState() => _InteractiveVisualizerState();
}

class _InteractiveVisualizerState extends State<InteractiveVisualizer> {
  late List<int> _array;
  late int _target;
  late int _currentStep;
  late List<_SearchStep> _steps;
  late List<int> _quickTargets;
  late String _whyQuestion;
  late String _whyAnswer;
  late String _whyWorksText;
  final TextEditingController _customTargetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initFromData();
  }

  @override
  void dispose() {
    _customTargetController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant InteractiveVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visualizationData != widget.visualizationData) {
      _initFromData();
    }
  }

  void _initFromData() {
    final data = widget.visualizationData ?? {};

    // 1. Array numbers
    final rawItems = data['items'];
    if (rawItems is List && rawItems.isNotEmpty) {
      _array = rawItems.map((e) => int.tryParse(e.toString()) ?? 0).toList();
    } else {
      _array = [10, 20, 30, 40, 50, 60, 70];
    }

    // 2. Target
    final rawTarget = data['target'];
    if (rawTarget != null) {
      _target = int.tryParse(rawTarget.toString()) ?? widget.initialTarget;
    } else {
      _target = widget.initialTarget;
    }

    // 3. Quick targets
    final rawQuick = data['quick_targets'];
    if (rawQuick is List && rawQuick.isNotEmpty) {
      _quickTargets = rawQuick.map((e) => int.tryParse(e.toString()) ?? 0).toList();
    } else {
      _quickTargets = [20, 50, 70];
    }

    // 4. Pedagogical explanations
    _whyQuestion = data['why_question'] as String? ?? 'Why did we ignore the discarded half?';
    _whyAnswer = data['why_answer'] as String? ??
        'Because the array is sorted and comparing the middle value tells us exactly which half contains the target.';
    _whyWorksText = data['why_this_works'] as String? ??
        'Binary Search repeatedly cuts the search area in half, finding elements in O(log N) comparisons.';

    _computeSteps();
    _currentStep = 0;
  }

  void _setTarget(int newTarget) {
    setState(() {
      _target = newTarget;
      _computeSteps();
      _currentStep = 0;
    });
  }

  void _computeSteps() {
    _steps = [];
    int low = 0;
    int high = _array.length - 1;
    int stepNum = 1;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      final midVal = _array[mid];

      // Discarded indices before this comparison
      final discardedBefore = <int>[];
      for (int i = 0; i < _array.length; i++) {
        if (i < low || i > high) discardedBefore.add(i);
      }

      if (midVal == _target) {
        // Target Found step
        _steps.add(
          _SearchStep(
            stepNumber: stepNum++,
            title: 'Target Found! ✓',
            middleValue: midVal,
            targetValue: _target,
            comparison: '$_target == $midVal',
            action: 'Found at index $mid! Search complete.',
            description: 'Middle element ($midVal) matches our target ($_target).',
            activeIndices: [for (int i = low; i <= high; i++) i],
            discardedIndices: discardedBefore,
            highlightedIndex: mid,
            foundIndex: mid,
          ),
        );
        break;
      } else if (_target > midVal) {
        // Step checking middle
        _steps.add(
          _SearchStep(
            stepNumber: stepNum++,
            title: 'Middle element is $midVal',
            middleValue: midVal,
            targetValue: _target,
            comparison: '$_target > $midVal',
            action: 'Search the RIGHT half →',
            description: 'Since $_target is greater than $midVal and the list is sorted, $_target cannot be in the left half.',
            activeIndices: [for (int i = low; i <= high; i++) i],
            discardedIndices: discardedBefore,
            highlightedIndex: mid,
            foundIndex: null,
          ),
        );

        low = mid + 1;
      } else {
        // Target is smaller
        _steps.add(
          _SearchStep(
            stepNumber: stepNum++,
            title: 'Middle element is $midVal',
            middleValue: midVal,
            targetValue: _target,
            comparison: '$_target < $midVal',
            action: '← Search the LEFT half',
            description: 'Since $_target is less than $midVal and the list is sorted, $_target cannot be in the right half.',
            activeIndices: [for (int i = low; i <= high; i++) i],
            discardedIndices: discardedBefore,
            highlightedIndex: mid,
            foundIndex: null,
          ),
        );

        high = mid - 1;
      }
    }

    if (low > high) {
      _steps.add(
        _SearchStep(
          stepNumber: stepNum,
          title: 'Target Not Found',
          middleValue: null,
          targetValue: _target,
          comparison: 'Search Space Exhausted',
          action: 'Target does not exist in array.',
          description: 'We narrowed down the entire range and verified that $_target is not in the array.',
          activeIndices: [],
          discardedIndices: [for (int i = 0; i < _array.length; i++) i],
          highlightedIndex: null,
          foundIndex: null,
        ),
      );
    }
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _restart() {
    setState(() {
      _currentStep = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_steps.isEmpty) return const SizedBox.shrink();

    final current = _steps[_currentStep];
    final isFirstStep = _currentStep == 0;
    final isLastStep = _currentStep == _steps.length - 1;
    final isFound = current.foundIndex != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Main Interactive Visualizer Card
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: AppColors.softShadow,
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Target Badge & Step Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.tealLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.tealBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.radar_rounded, size: 15, color: AppColors.tealPrimary),
                        const SizedBox(width: 6),
                        Text(
                          'Target: $_target',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.tealPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      'STEP ${_currentStep + 1} of ${_steps.length}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Visual Array with Highlighted Middle & Faded Discarded Elements
              _buildArrayVisual(current),
              const SizedBox(height: 22),

              // Educational Logic Panel (Middle = X, Target = Y, Comparison -> Decision)
              _buildLogicPanel(current, isFound),
              const SizedBox(height: 20),

              // Step Navigation Controls [Previous] [Next] / [Restart]
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isFirstStep ? null : _previousStep,
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
                        side: const BorderSide(color: AppColors.cardBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: AppColors.surface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isLastStep)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _restart,
                        icon: const Icon(Icons.replay_rounded, size: 16),
                        label: const Text('Restart'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tealPrimary,
                          foregroundColor: AppColors.textLight,
                          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
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
                        label: const Text('Next'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tealPrimary,
                          foregroundColor: AppColors.textLight,
                          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
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

        // 2. "Why did we ignore the left half?" Pedagogical Card
        _buildWhyIgnoredCard(),
        const SizedBox(height: 18),

        // 3. "Try it yourself" Interactive Target Tester
        _buildTryItYourselfCard(),
      ],
    );
  }

  Widget _buildArrayVisual(_SearchStep step) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_array.length, (index) {
          final value = _array[index];
          final isHighlighted = step.highlightedIndex == index;
          final isFound = step.foundIndex == index;
          final isDiscarded = step.discardedIndices.contains(index);

          Color bgColor;
          Color borderColor;
          Color textColor;
          double scale = 1.0;

          if (isFound) {
            bgColor = AppColors.greenLight;
            borderColor = AppColors.greenPrimary;
            textColor = AppColors.greenPrimary;
            scale = 1.08;
          } else if (isHighlighted) {
            bgColor = AppColors.orangeLight;
            borderColor = AppColors.orangePrimary;
            textColor = AppColors.orangePrimary;
            scale = 1.08;
          } else if (isDiscarded) {
            // Discarded half visually faded
            bgColor = AppColors.surfaceSecondary.withValues(alpha: 0.35);
            borderColor = AppColors.cardBorder.withValues(alpha: 0.3);
            textColor = AppColors.textMuted.withValues(alpha: 0.35);
          } else {
            // Active search space
            bgColor = AppColors.surface;
            borderColor = AppColors.tealBorder;
            textColor = AppColors.textPrimary;
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            transform: Matrix4.diagonal3Values(scale, scale, 1.0),
            width: 44,
            height: 52,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: (isHighlighted || isFound) ? 2.0 : 1.2,
              ),
              boxShadow: (isHighlighted || isFound)
                  ? [
                      BoxShadow(
                        color: (isFound ? AppColors.greenPrimary : AppColors.orangePrimary)
                            .withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$value',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          decoration: isDiscarded ? TextDecoration.lineThrough : null,
                          decorationColor: AppColors.textMuted.withValues(alpha: 0.4),
                        ),
                      ),
                      if (isHighlighted && !isFound) ...[
                        const SizedBox(height: 2),
                        const Text(
                          'MID',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.orangePrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isFound)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.greenPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 11, color: AppColors.textLight),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLogicPanel(_SearchStep step, bool isFound) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isFound ? AppColors.greenLight : AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFound ? AppColors.greenBorder : AppColors.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isFound ? Icons.check_circle_rounded : Icons.compare_arrows_rounded,
                size: 20,
                color: isFound ? AppColors.greenPrimary : AppColors.orangePrimary,
              ),
              const SizedBox(width: 8),
              Text(
                step.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isFound ? AppColors.greenPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Explicit comparison display
          if (step.middleValue != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Middle = ${step.middleValue}',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Target = ${step.targetValue}',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.tealPrimary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isFound ? AppColors.greenLight : AppColors.orangeLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      step.comparison,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isFound ? AppColors.greenPrimary : AppColors.orangePrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          Text(
            step.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          if (step.action.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isFound ? AppColors.greenLight : AppColors.tealLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                step.action,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isFound ? AppColors.greenPrimary : AppColors.tealPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWhyIgnoredCard() {
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
          Row(
            children: [
              const Icon(Icons.help_outline_rounded, size: 18, color: AppColors.orangePrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _whyQuestion,
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
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.orangeLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.orangeBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _whyAnswer,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _whyWorksText,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTryItYourselfCard() {
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
              Icon(Icons.touch_app_rounded, size: 18, color: AppColors.tealPrimary),
              SizedBox(width: 8),
              Text(
                'Try it yourself',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Select a preset target or enter your own number to watch Binary Search in action:',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),

          // Preset target buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickTargets.map((targetVal) {
              final isSelected = _target == targetVal;
              return InkWell(
                onTap: () => _setTarget(targetVal),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.tealPrimary : AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.tealPrimary : AppColors.cardBorder,
                    ),
                  ),
                  child: Text(
                    'Target: $targetVal',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.textLight : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SearchStep {
  final int stepNumber;
  final String title;
  final int? middleValue;
  final int targetValue;
  final String comparison;
  final String action;
  final String description;
  final List<int> activeIndices;
  final List<int> discardedIndices;
  final int? highlightedIndex;
  final int? foundIndex;

  _SearchStep({
    required this.stepNumber,
    required this.title,
    required this.middleValue,
    required this.targetValue,
    required this.comparison,
    required this.action,
    required this.description,
    required this.activeIndices,
    required this.discardedIndices,
    required this.highlightedIndex,
    required this.foundIndex,
  });
}
