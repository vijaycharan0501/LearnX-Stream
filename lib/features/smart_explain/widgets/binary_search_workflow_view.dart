import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Interactive Workflow visualization for Binary Search
/// Guides student through 6 pedagogical stages:
/// - Step 1: Initial state (Target 60, mid 40), interactive "Search LEFT" vs "Search RIGHT"
/// - Step 2 & 3: Visual transition (dim 0..3, mid 5 = 60), interactive "Yes, found!" vs "No, continue"
/// - Step 4: Success state (Target 60 found in 2 comparisons)
/// - Step 5: Application Challenge (Target 20, full interactive binary search)
/// - Step 6: Mastery Dashboard (Recall, Understanding, Application, Overall Mastery %, insights)
class BinarySearchWorkflowView extends StatefulWidget {
  final VoidCallback? onRestart;

  const BinarySearchWorkflowView({
    super.key,
    this.onRestart,
  });

  @override
  State<BinarySearchWorkflowView> createState() => _BinarySearchWorkflowViewState();
}

enum BinarySearchStage {
  step1SearchDirection,
  step2TransitionAndStep3FoundCheck,
  step4Success,
  challengeStep1SearchDirection,
  challengeStep2FoundCheck,
  challengeSuccess,
  masteryDashboard,
}

class _BinarySearchWorkflowViewState extends State<BinarySearchWorkflowView> {
  final List<int> _array = const [10, 20, 30, 40, 50, 60, 70];

  BinarySearchStage _stage = BinarySearchStage.step1SearchDirection;

  // Additional challenge target if user taps "Try Another Challenge"
  int _challengeTargetIndex = 0;
  static const List<int> _extraChallengeTargets = [20, 50, 10, 70];

  // Feedback state
  String? _feedbackMessage;
  bool _isFeedbackError = false;

  // Track attempts for score metrics
  int _mistakesCount = 0;

  int get _target {
    switch (_stage) {
      case BinarySearchStage.step1SearchDirection:
      case BinarySearchStage.step2TransitionAndStep3FoundCheck:
      case BinarySearchStage.step4Success:
        return 60;
      case BinarySearchStage.challengeStep1SearchDirection:
      case BinarySearchStage.challengeStep2FoundCheck:
      case BinarySearchStage.challengeSuccess:
        return _extraChallengeTargets[_challengeTargetIndex % _extraChallengeTargets.length];
      case BinarySearchStage.masteryDashboard:
        return 60;
    }
  }

  int get _lowIndex {
    switch (_stage) {
      case BinarySearchStage.step1SearchDirection:
        return 0;
      case BinarySearchStage.step2TransitionAndStep3FoundCheck:
      case BinarySearchStage.step4Success:
        return 4;
      case BinarySearchStage.challengeStep1SearchDirection:
        return 0;
      case BinarySearchStage.challengeStep2FoundCheck:
      case BinarySearchStage.challengeSuccess:
        final currentChallengeTarget = _target;
        if (currentChallengeTarget == 20 || currentChallengeTarget == 10) {
          return 0;
        } else {
          return 4;
        }
      case BinarySearchStage.masteryDashboard:
        return 0;
    }
  }

  int get _highIndex {
    switch (_stage) {
      case BinarySearchStage.step1SearchDirection:
        return 6;
      case BinarySearchStage.step2TransitionAndStep3FoundCheck:
      case BinarySearchStage.step4Success:
        return 6;
      case BinarySearchStage.challengeStep1SearchDirection:
        return 6;
      case BinarySearchStage.challengeStep2FoundCheck:
      case BinarySearchStage.challengeSuccess:
        final currentChallengeTarget = _target;
        if (currentChallengeTarget == 20 || currentChallengeTarget == 10) {
          return 2;
        } else {
          return 6;
        }
      case BinarySearchStage.masteryDashboard:
        return 6;
    }
  }

  int get _midIndex {
    switch (_stage) {
      case BinarySearchStage.step1SearchDirection:
        return 3;
      case BinarySearchStage.step2TransitionAndStep3FoundCheck:
      case BinarySearchStage.step4Success:
        return 5;
      case BinarySearchStage.challengeStep1SearchDirection:
        return 3;
      case BinarySearchStage.challengeStep2FoundCheck:
      case BinarySearchStage.challengeSuccess:
        final currentChallengeTarget = _target;
        if (currentChallengeTarget == 20) {
          return 1;
        } else if (currentChallengeTarget == 10) {
          return 0;
        } else if (currentChallengeTarget == 50) {
          return 4;
        } else if (currentChallengeTarget == 70) {
          return 6;
        }
        return 1;
      case BinarySearchStage.masteryDashboard:
        return 3;
    }
  }

  int get _midValue => _array[_midIndex];

  bool get _isTargetFound {
    return _stage == BinarySearchStage.step4Success ||
        _stage == BinarySearchStage.challengeSuccess ||
        (_stage == BinarySearchStage.step2TransitionAndStep3FoundCheck && _midValue == _target && _feedbackMessage != null && !_isFeedbackError);
  }

  Set<int> get _eliminatedIndices {
    switch (_stage) {
      case BinarySearchStage.step1SearchDirection:
        return {};
      case BinarySearchStage.step2TransitionAndStep3FoundCheck:
      case BinarySearchStage.step4Success:
        return {0, 1, 2, 3}; // Left half eliminated
      case BinarySearchStage.challengeStep1SearchDirection:
        return {};
      case BinarySearchStage.challengeStep2FoundCheck:
      case BinarySearchStage.challengeSuccess:
        final currentChallengeTarget = _target;
        if (currentChallengeTarget == 20 || currentChallengeTarget == 10) {
          return {3, 4, 5, 6}; // Right half eliminated
        } else {
          return {0, 1, 2, 3}; // Left half eliminated
        }
      case BinarySearchStage.masteryDashboard:
        return {};
    }
  }

  bool get _isChallengeActive {
    return _stage == BinarySearchStage.challengeStep1SearchDirection ||
        _stage == BinarySearchStage.challengeStep2FoundCheck ||
        _stage == BinarySearchStage.challengeSuccess;
  }

  void _handleStep1Choice(String choice) {
    setState(() {
      if (choice == 'RIGHT') {
        _feedbackMessage = 'Correct! Since 40 < 60, the target must be in the right half.';
        _isFeedbackError = false;
        _stage = BinarySearchStage.step2TransitionAndStep3FoundCheck;
      } else {
        _mistakesCount++;
        _feedbackMessage = 'Notice: 40 is smaller than 60 (40 < 60). In a sorted array, elements on the left are even smaller. You must search RIGHT.';
        _isFeedbackError = true;
      }
    });
  }

  void _handleStep3Choice(String choice) {
    setState(() {
      if (choice == 'YES') {
        _feedbackMessage = 'Awesome! arr[5] is 60, which exactly matches Target 60.';
        _isFeedbackError = false;
        _stage = BinarySearchStage.step4Success;
      } else {
        _mistakesCount++;
        _feedbackMessage = 'Take a look at arr[5] (60) and Target (60). 60 == 60, so the element is indeed found!';
        _isFeedbackError = true;
      }
    });
  }

  void _startApplicationChallenge() {
    setState(() {
      _feedbackMessage = null;
      _isFeedbackError = false;
      _stage = BinarySearchStage.challengeStep1SearchDirection;
    });
  }

  void _handleChallengeStep1Choice(String choice) {
    setState(() {
      final currentTarget = _target;
      final shouldSearchLeft = currentTarget < 40;
      final expectedChoice = shouldSearchLeft ? 'LEFT' : 'RIGHT';

      if (choice == expectedChoice) {
        _feedbackMessage = shouldSearchLeft
            ? 'Correct! Since $currentTarget < 40, the target must be in the left half.'
            : 'Correct! Since $currentTarget > 40, the target must be in the right half.';
        _isFeedbackError = false;
        _stage = BinarySearchStage.challengeStep2FoundCheck;
      } else {
        _mistakesCount++;
        _feedbackMessage = shouldSearchLeft
            ? 'Notice: Target $currentTarget is smaller than middle element 40 ($currentTarget < 40). You should search LEFT.'
            : 'Notice: Target $currentTarget is greater than middle element 40 ($currentTarget > 40). You should search RIGHT.';
        _isFeedbackError = true;
      }
    });
  }

  void _handleChallengeStep2Choice(String choice) {
    setState(() {
      if (choice == 'YES') {
        _feedbackMessage = 'Brilliant! Target $_target found in 2 comparisons.';
        _isFeedbackError = false;
        _stage = BinarySearchStage.challengeSuccess;
      } else {
        _mistakesCount++;
        _feedbackMessage = 'Look at arr[$_midIndex] ($_midValue) and Target ($_target). They are equal ($_midValue == $_target)!';
        _isFeedbackError = true;
      }
    });
  }

  void _showMasteryDashboard() {
    setState(() {
      _feedbackMessage = null;
      _isFeedbackError = false;
      _stage = BinarySearchStage.masteryDashboard;
    });
  }

  void _tryAnotherChallenge() {
    setState(() {
      _challengeTargetIndex++;
      _feedbackMessage = null;
      _isFeedbackError = false;
      _stage = BinarySearchStage.challengeStep1SearchDirection;
    });
  }

  void _restart() {
    setState(() {
      _stage = BinarySearchStage.step1SearchDirection;
      _challengeTargetIndex = 0;
      _feedbackMessage = null;
      _isFeedbackError = false;
      _mistakesCount = 0;
    });
    widget.onRestart?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Target & Step Status Header
        _buildTargetHeader(),
        const SizedBox(height: 16),

        // 2. Interactive Array Visualizer with Pointers
        if (_stage != BinarySearchStage.masteryDashboard) ...[
          _buildArrayCard(),
          const SizedBox(height: 16),
        ],

        // 3. Step Arithmetic & Comparison Box
        if (_stage != BinarySearchStage.masteryDashboard) ...[
          _buildComparisonCard(),
          const SizedBox(height: 16),
        ],

        // 4. Interactive Feedback & Question / Mastery Area
        _buildInteractiveActionCard(),
        const SizedBox(height: 16),

        // 5. Pedagogical Explanation & Learning Signal
        if (_stage != BinarySearchStage.masteryDashboard)
          _buildExplanationCard(),

        // 6. Navigation Controls Footer
        const SizedBox(height: 16),
        _buildControlsCard(),
      ],
    );
  }

  /// Target & Step Status Header Banner
  Widget _buildTargetHeader() {
    String stepLabel;
    IconData stepIcon;

    switch (_stage) {
      case BinarySearchStage.step1SearchDirection:
        stepLabel = 'Step 1: Direction Choice';
        stepIcon = Icons.fork_right_rounded;
        break;
      case BinarySearchStage.step2TransitionAndStep3FoundCheck:
        stepLabel = 'Step 2 & 3: Match Verification';
        stepIcon = Icons.fact_check_rounded;
        break;
      case BinarySearchStage.step4Success:
        stepLabel = 'Step 4: Target Found';
        stepIcon = Icons.check_circle_rounded;
        break;
      case BinarySearchStage.challengeStep1SearchDirection:
        stepLabel = 'Step 5: Challenge (Decision)';
        stepIcon = Icons.bolt_rounded;
        break;
      case BinarySearchStage.challengeStep2FoundCheck:
        stepLabel = 'Step 5: Challenge (Verify)';
        stepIcon = Icons.psychology_rounded;
        break;
      case BinarySearchStage.challengeSuccess:
        stepLabel = 'Step 5: Challenge Complete';
        stepIcon = Icons.military_tech_rounded;
        break;
      case BinarySearchStage.masteryDashboard:
        stepLabel = 'Step 6: Mastery Dashboard';
        stepIcon = Icons.workspace_premium_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          // Target Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isChallengeActive ? AppColors.purpleLight : AppColors.tealLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isChallengeActive ? AppColors.purpleBorder : AppColors.tealBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isChallengeActive ? Icons.flash_on_rounded : Icons.track_changes_rounded,
                  size: 16,
                  color: _isChallengeActive ? AppColors.purplePrimary : AppColors.tealPrimary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Target: $_target',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _isChallengeActive ? AppColors.purplePrimary : AppColors.tealPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Step Counter Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(stepIcon, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  stepLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Main Array Visualization Card with Pointer Indicators
  Widget _buildArrayCard() {
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.view_column_rounded, size: 18, color: AppColors.tealPrimary),
                  SizedBox(width: 8),
                  Text(
                    'Sorted Search Space',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_array.length - _eliminatedIndices.length} Active / 7 Total',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Scrollable / Centered Array Representation
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_array.length, (index) {
                  return _buildArrayItem(index);
                }),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Pointer Legend
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              _buildLegendItem('LOW', AppColors.bluePrimary, AppColors.blueLight),
              _buildLegendItem('MID', AppColors.orangePrimary, AppColors.orangeLight),
              _buildLegendItem('HIGH', AppColors.purplePrimary, AppColors.purpleLight),
              if (_eliminatedIndices.isNotEmpty)
                _buildLegendItem('EXCLUDED', AppColors.coralPrimary, AppColors.coralLight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _buildArrayItem(int index) {
    final value = _array[index];
    final isMid = index == _midIndex;
    final isLow = index == _lowIndex;
    final isHigh = index == _highIndex;
    final isEliminated = _eliminatedIndices.contains(index);
    final isFound = (_isTargetFound || _stage == BinarySearchStage.step4Success || _stage == BinarySearchStage.challengeSuccess) && index == _midIndex;

    // Background and border styling
    Color boxBgColor = AppColors.surfaceSecondary;
    Color boxBorderColor = AppColors.cardBorder;
    Color textColor = AppColors.textPrimary;
    double borderWidth = 1.2;

    if (isFound) {
      boxBgColor = AppColors.greenLight;
      boxBorderColor = AppColors.greenPrimary;
      textColor = AppColors.greenPrimary;
      borderWidth = 2.0;
    } else if (isMid) {
      boxBgColor = AppColors.orangeLight;
      boxBorderColor = AppColors.orangePrimary;
      textColor = AppColors.orangePrimary;
      borderWidth = 2.0;
    } else if (isEliminated) {
      boxBgColor = AppColors.surfaceSecondary.withValues(alpha: 0.35);
      boxBorderColor = AppColors.cardBorder.withValues(alpha: 0.4);
      textColor = AppColors.textMuted.withValues(alpha: 0.35);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          // Top Pointer Badges
          SizedBox(
            height: 22,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLow && !isEliminated)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.blueLight,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.blueBorder),
                    ),
                    child: const Text(
                      'L',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.bluePrimary,
                      ),
                    ),
                  ),
                if (isMid && !isEliminated) ...[
                  if (isLow) const SizedBox(width: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: isFound ? AppColors.greenLight : AppColors.orangeLight,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isFound ? AppColors.greenBorder : AppColors.orangeBorder,
                      ),
                    ),
                    child: Text(
                      isFound ? 'FOUND' : 'MID',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: isFound ? AppColors.greenPrimary : AppColors.orangePrimary,
                      ),
                    ),
                  ),
                ],
                if (isHigh && !isEliminated && (!isLow || index != _lowIndex) && (!isMid || index != _midIndex)) ...[
                  const SizedBox(width: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.purpleLight,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.purpleBorder),
                    ),
                    child: const Text(
                      'H',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.purplePrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Value Box
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 44,
            height: 52,
            decoration: BoxDecoration(
              color: boxBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: boxBorderColor, width: borderWidth),
              boxShadow: (isMid || isFound) && !isEliminated
                  ? [
                      BoxShadow(
                        color: (isFound ? AppColors.greenPrimary : AppColors.orangePrimary)
                            .withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: (isMid || isFound) && !isEliminated ? FontWeight.w800 : FontWeight.w700,
                    color: textColor,
                    decoration: isEliminated ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.coralPrimary.withValues(alpha: 0.6),
                    decorationThickness: 2,
                  ),
                ),
                if (isEliminated)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Icon(
                      Icons.close_rounded,
                      size: 10,
                      color: AppColors.coralPrimary.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Bottom Index Number
          Text(
            '[$index]',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isEliminated ? AppColors.textMuted.withValues(alpha: 0.4) : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Comparison & Pointer Arithmetic Card
  Widget _buildComparisonCard() {
    String stepTitle;
    String midFormula;
    String comparisonText;
    Color accentColor;
    Color accentBg;

    if (_stage == BinarySearchStage.step1SearchDirection ||
        _stage == BinarySearchStage.challengeStep1SearchDirection) {
      stepTitle = 'Step 1: Calculate Middle & Compare';
      midFormula = 'mid = ⌊(0 + 6) / 2⌋ = 3';
      final currentTarget = _target;
      if (currentTarget == 60) {
        comparisonText = 'arr[3] (40) < Target (60)';
      } else {
        comparisonText = 'Target ($currentTarget) < arr[3] (40)';
      }
      accentColor = AppColors.orangePrimary;
      accentBg = AppColors.orangeLight;
    } else if (_stage == BinarySearchStage.step2TransitionAndStep3FoundCheck ||
        _stage == BinarySearchStage.step4Success) {
      stepTitle = 'Step 2: Narrow Search Space';
      midFormula = 'mid = ⌊(4 + 6) / 2⌋ = 5';
      comparisonText = 'arr[5] (60) == Target (60) ✔';
      accentColor = AppColors.greenPrimary;
      accentBg = AppColors.greenLight;
    } else {
      // Challenge Step 2 & Success
      stepTitle = 'Step 2: Narrow Search Space';
      final currentTarget = _target;
      if (currentTarget == 20) {
        midFormula = 'mid = ⌊(0 + 2) / 2⌋ = 1';
        comparisonText = 'arr[1] (20) == Target (20) ✔';
      } else {
        midFormula = 'mid = ⌊($_lowIndex + $_highIndex) / 2⌋ = $_midIndex';
        comparisonText = 'arr[$_midIndex] ($_midValue) == Target ($currentTarget) ✔';
      }
      accentColor = AppColors.greenPrimary;
      accentBg = AppColors.greenLight;
    }

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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calculate_rounded, size: 18, color: accentColor),
                  const SizedBox(width: 8),
                  Text(
                    stepTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'mid = $_midIndex',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bounds & Mid:',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      midFormula,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Comparison:',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      comparisonText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Interactive Decision / Action Card for each step
  Widget _buildInteractiveActionCard() {
    switch (_stage) {
      case BinarySearchStage.step1SearchDirection:
        return _buildStep1PromptCard();
      case BinarySearchStage.step2TransitionAndStep3FoundCheck:
        return _buildStep3PromptCard();
      case BinarySearchStage.step4Success:
        return _buildStep4SuccessCard();
      case BinarySearchStage.challengeStep1SearchDirection:
        return _buildChallengeStep1PromptCard();
      case BinarySearchStage.challengeStep2FoundCheck:
        return _buildChallengeStep2PromptCard();
      case BinarySearchStage.challengeSuccess:
        return _buildChallengeSuccessCard();
      case BinarySearchStage.masteryDashboard:
        return _buildMasteryDashboardCard();
    }
  }

  /// STEP 1 PROMPT: "What should Binary Search do?" -> Search LEFT / Search RIGHT
  Widget _buildStep1PromptCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.orangeBorder, width: 1.5),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step Header & Target Context
          const Row(
            children: [
              Icon(Icons.help_outline_rounded, size: 20, color: AppColors.orangePrimary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'What should Binary Search do?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.orangeLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Wrap(
              alignment: WrapAlignment.spaceAround,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                Text('Target = 60', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.orangePrimary)),
                Text('•', style: TextStyle(color: AppColors.orangePrimary)),
                Text('arr[3] = 40', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.orangePrimary)),
                Text('•', style: TextStyle(color: AppColors.orangePrimary)),
                Text('40 < 60', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.orangePrimary)),
              ],
            ),
          ),
          if (_feedbackMessage != null) ...[
            const SizedBox(height: 12),
            _buildFeedbackBox(),
          ],
          const SizedBox(height: 16),
          // Decision Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleStep1Choice('LEFT'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: AppColors.surfaceSecondary,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.textPrimary),
                      SizedBox(width: 6),
                      Text(
                        'Search LEFT',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleStep1Choice('RIGHT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orangePrimary,
                    foregroundColor: AppColors.textLight,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Search RIGHT',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 16),
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

  /// STEP 3 PROMPT: "Is the target equal to the middle element?" -> Yes, found! / No, continue
  Widget _buildStep3PromptCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.tealBorder, width: 1.5),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.fact_check_rounded, size: 20, color: AppColors.tealPrimary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Is the target equal to the middle element?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.tealLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Wrap(
              alignment: WrapAlignment.spaceAround,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                Text('Target = 60', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.tealPrimary)),
                Text('•', style: TextStyle(color: AppColors.tealPrimary)),
                Text('arr[5] = 60', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.tealPrimary)),
                Text('•', style: TextStyle(color: AppColors.tealPrimary)),
                Text('60 == 60', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.tealPrimary)),
              ],
            ),
          ),
          if (_feedbackMessage != null) ...[
            const SizedBox(height: 12),
            _buildFeedbackBox(),
          ],
          const SizedBox(height: 16),
          // Decision Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleStep3Choice('YES'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenPrimary,
                    foregroundColor: AppColors.textLight,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 17),
                      SizedBox(width: 6),
                      Text(
                        'Yes, found!',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleStep3Choice('NO'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: AppColors.surfaceSecondary,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, size: 16, color: AppColors.textSecondary),
                      SizedBox(width: 6),
                      Text(
                        'No, continue',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
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

  /// STEP 4: Success state
  Widget _buildStep4SuccessCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greenBorder, width: 1.5),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.greenPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: AppColors.textLight, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎉 Target 60 found!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Binary Search found the target in 2 comparisons.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greenPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _startApplicationChallenge,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tealPrimary,
              foregroundColor: AppColors.textLight,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    'Step 5: Start Application Challenge (Target: 20)',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// STEP 5 — APPLICATION CHALLENGE (Direction Choice for Target 20)
  Widget _buildChallengeStep1PromptCard() {
    final currentTarget = _target;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.purpleBorder, width: 1.5),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.purpleLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bolt_rounded, size: 18, color: AppColors.purplePrimary),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Application Challenge: Target 20',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'The middle element is arr[3] = 40. Compare Target (20) with 40:',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.purpleLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                Text('Target = $currentTarget', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.purplePrimary)),
                const Text('•', style: TextStyle(color: AppColors.purplePrimary)),
                const Text('arr[3] = 40', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.purplePrimary)),
                const Text('•', style: TextStyle(color: AppColors.purplePrimary)),
                Text('$currentTarget < 40', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.purplePrimary)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'What should Binary Search do?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          if (_feedbackMessage != null) ...[
            const SizedBox(height: 12),
            _buildFeedbackBox(),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleChallengeStep1Choice('LEFT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purplePrimary,
                    foregroundColor: AppColors.textLight,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_rounded, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Search LEFT',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleChallengeStep1Choice('RIGHT'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: AppColors.surfaceSecondary,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Search RIGHT',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textPrimary),
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

  /// STEP 5 — APPLICATION CHALLENGE (Verify match for Target 20)
  Widget _buildChallengeStep2PromptCard() {
    final currentTarget = _target;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.purpleBorder, width: 1.5),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.purpleLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.psychology_rounded, size: 18, color: AppColors.purplePrimary),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Is the target equal to the middle element?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.purpleLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                Text('Target = $currentTarget', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.purplePrimary)),
                const Text('•', style: TextStyle(color: AppColors.purplePrimary)),
                Text('arr[$_midIndex] = $_midValue', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.purplePrimary)),
                const Text('•', style: TextStyle(color: AppColors.purplePrimary)),
                Text('$_midValue == $currentTarget', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.purplePrimary)),
              ],
            ),
          ),
          if (_feedbackMessage != null) ...[
            const SizedBox(height: 12),
            _buildFeedbackBox(),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleChallengeStep2Choice('YES'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenPrimary,
                    foregroundColor: AppColors.textLight,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 17),
                      SizedBox(width: 6),
                      Text(
                        'Yes, found!',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleChallengeStep2Choice('NO'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: AppColors.surfaceSecondary,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, size: 16, color: AppColors.textSecondary),
                      SizedBox(width: 6),
                      Text(
                        'No, continue',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
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

  /// Challenge Success State
  Widget _buildChallengeSuccessCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greenBorder, width: 1.5),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.greenPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star_rounded, color: AppColors.textLight, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎉 Target $_target found!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Binary Search found the target in 2 comparisons.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greenPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _showMasteryDashboard,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purplePrimary,
              foregroundColor: AppColors.textLight,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    'Step 6: View Mastery Breakdown',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// STEP 6: MASTERY DASHBOARD
  Widget _buildMasteryDashboardCard() {
    final recallScore = _mistakesCount == 0 ? '100%' : '95%';
    final understandingScore = _mistakesCount == 0 ? '100%' : '92%';
    final applicationScore = _mistakesCount == 0 ? '100%' : '96%';
    final overallMastery = _mistakesCount == 0 ? '100%' : '94%';

    return Container(
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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.tealLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.tealBorder),
                ),
                child: const Icon(Icons.workspace_premium_rounded, size: 24, color: AppColors.tealPrimary),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Binary Search Mastery',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Algorithm Concept Fully Learned',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tealPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.greenBorder),
                ),
                child: Text(
                  overallMastery,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.greenPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 4-Pillar Mastery Grid
          Row(
            children: [
              Expanded(
                child: _buildMasteryPillar(
                  title: 'Recall',
                  score: recallScore,
                  subtitle: 'Formula & Invariant',
                  icon: Icons.memory_rounded,
                  color: AppColors.bluePrimary,
                  bgColor: AppColors.blueLight,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMasteryPillar(
                  title: 'Understanding',
                  score: understandingScore,
                  subtitle: 'Search Space Halving',
                  icon: Icons.psychology_rounded,
                  color: AppColors.orangePrimary,
                  bgColor: AppColors.orangeLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMasteryPillar(
                  title: 'Application',
                  score: applicationScore,
                  subtitle: 'Interactive Decisions',
                  icon: Icons.auto_awesome_rounded,
                  color: AppColors.purplePrimary,
                  bgColor: AppColors.purpleLight,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMasteryPillar(
                  title: 'Overall Mastery',
                  score: overallMastery,
                  subtitle: 'O(log N) Efficiency',
                  icon: Icons.verified_rounded,
                  color: AppColors.greenPrimary,
                  bgColor: AppColors.greenLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Explanation of what the student understood
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.tealLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.tealBorder),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, size: 16, color: AppColors.tealPrimary),
                    SizedBox(width: 6),
                    Text(
                      'What You Understood',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.tealPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'You have mastered how Binary Search repeatedly halves the search space using midpoint comparisons (mid = ⌊(low + high) / 2⌋), pruning half the elements in O(log N) logarithmic time instead of checking every element sequentially.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textPrimary,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Action Buttons: "Try Another Challenge" and "Restart Workflow"
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _restart,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: AppColors.surface,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.replay_rounded, size: 16, color: AppColors.textPrimary),
                      SizedBox(width: 6),
                      Text(
                        'Restart Workflow',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _tryAnotherChallenge,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tealPrimary,
                    foregroundColor: AppColors.textLight,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bolt_rounded, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Try Another Challenge',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildMasteryPillar({
    required String title,
    required String score,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const Spacer(),
              Text(
                score,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackBox() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _isFeedbackError ? AppColors.coralLight : AppColors.greenLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _isFeedbackError ? AppColors.coralBorder : AppColors.greenBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _isFeedbackError ? Icons.info_outline_rounded : Icons.check_circle_outline_rounded,
            size: 16,
            color: _isFeedbackError ? AppColors.coralPrimary : AppColors.greenPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _feedbackMessage!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _isFeedbackError ? AppColors.coralPrimary : AppColors.greenPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Pedagogical Explanation & Learning Signal
  Widget _buildExplanationCard() {
    if (_stage == BinarySearchStage.step1SearchDirection) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.orangeLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.orangeBorder),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppColors.orangePrimary),
                SizedBox(width: 8),
                Text(
                  'Pedagogical Explanation',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.orangePrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'The middle element is 40. Because the array is sorted and 40 < 60, the target value 60 cannot exist anywhere from index 0 to 3 (values 10, 20, 30, 40).',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.auto_awesome_rounded, size: 15, color: AppColors.orangePrimary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Learning Signal: Left half [10, 20, 30, 40] eliminated in 1 check!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.orangePrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (_stage == BinarySearchStage.challengeStep1SearchDirection ||
        _stage == BinarySearchStage.challengeStep2FoundCheck) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.purpleLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.purpleBorder),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bolt_rounded, size: 18, color: AppColors.purplePrimary),
                SizedBox(width: 8),
                Text(
                  'Application Practice Insight',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.purplePrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'For Target 20, 20 < 40 indicates we must discard the right half [40, 50, 60, 70] and search in [10, 20, 30]. The new midpoint immediately lands on 20!',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.tealLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.tealBorder),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.military_tech_rounded, size: 20, color: AppColors.tealPrimary),
                SizedBox(width: 8),
                Text(
                  'Binary Search Mastery',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.tealPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Instead of checking all 7 elements sequentially with linear search, Binary Search located the target in only 2 comparisons.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.speed_rounded, size: 16, color: AppColors.tealPrimary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Complexity Achieved: O(log N) — 4 unnecessary checks skipped!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tealPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  /// Interactive Control Buttons: Reset / Navigation
  Widget _buildControlsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          // Restart Button
          OutlinedButton(
            onPressed: _restart,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              side: const BorderSide(color: AppColors.cardBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.replay_rounded, size: 16, color: AppColors.textPrimary),
                SizedBox(width: 4),
                Text(
                  'Restart',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Interactive Guided Status
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.touch_app_rounded, size: 15, color: AppColors.tealPrimary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _stage == BinarySearchStage.masteryDashboard
                          ? 'Mastery Complete'
                          : 'Interactive Choices Active',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
