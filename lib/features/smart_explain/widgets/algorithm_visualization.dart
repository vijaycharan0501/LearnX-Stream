import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../data/visualization_data_provider.dart';
import '../models/visual_explanation_models.dart';

/// Generic, Data-Driven Algorithm & Dynamic Visualization Component for LearnX STREAM.
///
/// Handles arbitrary search, sorting, and pointer-based algorithmic sequences:
/// - Renders element arrays/items with animated active, eliminated, and highlighted states.
/// - Renders dynamically positioned pointers (e.g. LOW, MID, HIGH, LEFT, RIGHT, P1, P2) with arrows.
/// - Compares elements dynamically (Target vs Probed elements).
/// - Displays visual reduction flows and animated success/completion celebrations.
/// - Clean bottom navigation controls [ ← Previous ] [ ▶ Play / ⏸ Pause ] [ Restart ] [ Next → ].
class AlgorithmVisualization extends StatefulWidget {
  final String topic;
  final int? initialTarget;
  final List<dynamic>? initialArray;
  final Map<String, dynamic>? visualizationData;

  const AlgorithmVisualization({
    super.key,
    this.topic = 'Algorithm',
    this.initialTarget,
    this.initialArray,
    this.visualizationData,
  });

  @override
  State<AlgorithmVisualization> createState() => _AlgorithmVisualizationState();
}

class _AlgorithmVisualizationState extends State<AlgorithmVisualization>
    with SingleTickerProviderStateMixin {
  late Visualization _model;
  late int _currentStepIndex;
  dynamic _target;
  late List<dynamic> _elements;

  late AnimationController _celebrationController;
  late Animation<double> _celebrationScale;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _celebrationScale = Tween<double>(begin: 0.85, end: 1.05).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: Curves.elasticOut,
      ),
    );
    _initFromData();
  }

  @override
  void didUpdateWidget(covariant AlgorithmVisualization oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visualizationData != widget.visualizationData ||
        oldWidget.initialTarget != widget.initialTarget ||
        oldWidget.initialArray != widget.initialArray ||
        oldWidget.topic != widget.topic) {
      _initFromData();
    }
  }

  void _initFromData() {
    final data = widget.visualizationData ?? {};

    // 1. Elements
    if (widget.initialArray != null && widget.initialArray!.isNotEmpty) {
      _elements = List<dynamic>.from(widget.initialArray!);
    } else if (data['items'] is List && (data['items'] as List).isNotEmpty) {
      _elements = List<dynamic>.from(data['items'] as List);
    } else if (data['elements'] is List && (data['elements'] as List).isNotEmpty) {
      _elements = List<dynamic>.from(data['elements'] as List);
    } else {
      _elements = [10, 20, 30, 40, 50, 60, 70];
    }

    // 2. Target
    if (data['target'] != null) {
      _target = data['target'];
    } else if (widget.initialTarget != null) {
      _target = widget.initialTarget;
    } else {
      _target = 60;
    }

    // 3. Model construction using generic Visualization data architecture
    if (data['steps'] is List && (data['steps'] as List).isNotEmpty) {
      _model = Visualization.fromJson(data);
    } else if (widget.topic.toLowerCase().contains('binary search') ||
        (widget.initialTarget == null && widget.initialArray == null)) {
      _model = VisualizationDataProvider.getBinarySearchVisualization(
        array: _elements.map((e) => int.tryParse(e.toString()) ?? 0).toList(),
        target: int.tryParse(_target.toString()) ?? 60,
        topic: widget.topic.isNotEmpty ? widget.topic : 'Binary Search',
      );
    } else {
      // Compute dynamically from elements for any algorithm
      final intList = _elements
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .toList()
        ..sort();
      final parsedTarget = int.tryParse(_target.toString()) ?? 60;

      _model = VisualizationDataProvider.computeAlgorithmVisualization(
        array: intList,
        target: parsedTarget,
        topic: widget.topic.isNotEmpty ? widget.topic : 'Algorithm',
      );
    }

    _currentStepIndex = 0;
    _tappedElementIndex = null;
  }

  int? _tappedElementIndex;
  bool _isPlaying = false;
  Timer? _autoPlayTimer;

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _celebrationController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    setState(() => _isPlaying = true);
    _autoPlayTimer = Timer.periodic(const Duration(milliseconds: 2400), (timer) {
      if (_currentStepIndex < _model.steps.length - 1) {
        _goToNextStep(fromAutoPlay: true);
      } else {
        _stopAutoPlay();
      }
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    if (_isPlaying) {
      setState(() => _isPlaying = false);
    }
  }

  void _togglePlay() {
    if (_isPlaying) {
      _stopAutoPlay();
    } else {
      if (_currentStepIndex >= _model.steps.length - 1) {
        _restart();
      }
      _startAutoPlay();
    }
  }

  void _goToNextStep({bool fromAutoPlay = false}) {
    if (!fromAutoPlay) _stopAutoPlay();
    if (_currentStepIndex < _model.steps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _tappedElementIndex = null;
        if (_model.steps[_currentStepIndex].isFound) {
          _celebrationController.forward(from: 0.0);
        }
      });
    }
  }

  void _goToPreviousStep() {
    _stopAutoPlay();
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
        _tappedElementIndex = null;
        if (_model.steps[_currentStepIndex].isFound) {
          _celebrationController.forward(from: 0.0);
        }
      });
    }
  }

  void _restart() {
    _stopAutoPlay();
    setState(() {
      _currentStepIndex = 0;
      _tappedElementIndex = null;
      _celebrationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_model.steps.isEmpty) return const SizedBox.shrink();

    final step = _model.steps[_currentStepIndex];
    final isFirstStep = _currentStepIndex == 0;
    final isLastStep = _currentStepIndex == _model.steps.length - 1;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header: Target Badge + Step Counter Pill
          _buildHeaderRow(step),
          const SizedBox(height: 18),

          // 2. Step Title Banner
          _buildStepTitleBanner(step),
          const SizedBox(height: 18),

          // 3. Main Content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: (step.isIdeaStep || step.isWhyStep)
                ? _buildStep3UnderstandTheIdea(step)
                : _buildArrayStepContent(step),
          ),
          const SizedBox(height: 24),

          // 4. Controls: [ ← Previous ] [ Restart ] [ Next → ]
          _buildControlsRow(isFirstStep, isLastStep),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(VisualizationStep step) {
    final totalSteps = step.totalSteps > 0 ? step.totalSteps : _model.steps.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_target != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.tealLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.tealBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.radar_rounded, size: 16, color: AppColors.tealPrimary),
                const SizedBox(width: 6),
                Text(
                  'Target: $_target',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.tealPrimary,
                  ),
                ),
              ],
            ),
          )
        else
          const SizedBox.shrink(),

        // Step Progression Dots (● ● ● ○ ○)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(totalSteps, (i) {
            final isActive = i == _currentStepIndex;
            final isDone = i < _currentStepIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: isActive ? 16 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.tealPrimary
                    : (isDone ? AppColors.tealPrimary.withValues(alpha: 0.45) : AppColors.cardBorder),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.blueLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.blueBorder),
          ),
          child: Text(
            'Step ${step.stepNumber} of $totalSteps',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: AppColors.bluePrimary,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepTitleBanner(VisualizationStep step) {
    String bannerText = step.title;
    IconData icon = Icons.search_rounded;
    Color color = AppColors.tealPrimary;
    Color bgColor = AppColors.tealLight;
    Color borderColor = AppColors.tealBorder;

    if (step.isIdeaStep || step.isWhyStep) {
      bannerText = step.title.isNotEmpty ? step.title : 'STEP 3 — UNDERSTAND THE IDEA';
      icon = Icons.lightbulb_rounded;
      color = AppColors.purplePrimary;
      bgColor = AppColors.purpleLight;
      borderColor = AppColors.purpleBorder;
    } else if (step.isFound) {
      bannerText = step.title.isNotEmpty ? step.title : 'CHECK THE NEW MIDDLE';
      icon = Icons.check_circle_rounded;
      color = AppColors.greenPrimary;
      bgColor = AppColors.greenLight;
      borderColor = AppColors.greenBorder;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              bannerText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.4,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrayStepContent(VisualizationStep step) {
    final list = step.elements.isNotEmpty ? step.elements : _elements;

    return Column(
      key: ValueKey('algo_step_${step.stepNumber}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildArrayWithPointers(step),
        const SizedBox(height: 18),

        if (step.midValue != null) ...[
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: step.isFound ? AppColors.greenLight : AppColors.orangeLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: step.isFound ? AppColors.greenBorder : AppColors.orangeBorder,
                  width: 1.5,
                ),
              ),
              child: Text(
                '${step.midValue} = MIDDLE',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: step.isFound ? AppColors.greenPrimary : AppColors.orangePrimary,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        _buildComparisonAndActionBox(step),

        if (_tappedElementIndex != null && _tappedElementIndex! < list.length) ...[
          const SizedBox(height: 14),
          _buildTappedElementExploration(step, list),
        ],
      ],
    );
  }

  Widget _buildTappedElementExploration(VisualizationStep step, List<dynamic> list) {
    final index = _tappedElementIndex!;
    final value = list[index];
    final isMid = step.midIndex == index;
    final isEliminated = step.eliminatedIndices.contains(index);
    final isFound = step.isFound && step.foundIndex == index;
    final isActive = step.activeIndices.contains(index);

    String badgeText = 'ELEMENT AT INDEX $index';
    String title = 'Element: $value';
    String desc = 'Currently part of the array representation.';
    Color color = AppColors.tealPrimary;
    Color bgColor = AppColors.tealLight;
    Color borderColor = AppColors.tealBorder;
    IconData icon = Icons.touch_app_rounded;

    if (isFound) {
      badgeText = 'TARGET FOUND MATCH';
      title = 'Target $value Located at Index $index!';
      desc = 'The middle element matches the target value ($_target). Binary search terminates successfully.';
      color = AppColors.greenPrimary;
      bgColor = AppColors.greenLight;
      borderColor = AppColors.greenBorder;
      icon = Icons.check_circle_rounded;
    } else if (isMid) {
      badgeText = 'CURRENT MIDDLE (PROBE)';
      title = '$value is the Middle Element (MID)';
      desc = 'The algorithm probes index $index to compare $value with Target ($_target). If target is greater, search the right half; if smaller, search the left half.';
      color = AppColors.orangePrimary;
      bgColor = AppColors.orangeLight;
      borderColor = AppColors.orangeBorder;
      icon = Icons.radar_rounded;
    } else if (isEliminated) {
      badgeText = 'ELIMINATED CANDIDATE';
      title = '$value is Eliminated (Discarded)';
      desc = 'This element has been safely eliminated from the search range because monotonic sorted order guarantees the target cannot reside in this partition.';
      color = AppColors.textSecondary;
      bgColor = AppColors.surfaceSecondary;
      borderColor = AppColors.cardBorder;
      icon = Icons.block_rounded;
    } else if (isActive) {
      badgeText = 'ACTIVE SEARCH CANDIDATE';
      title = '$value is in Active Window';
      desc = 'This element remains within the current active boundary [LOW..HIGH] and will be partitioned in subsequent comparisons.';
      color = AppColors.bluePrimary;
      bgColor = AppColors.blueLight;
      borderColor = AppColors.blueBorder;
      icon = Icons.search_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                badgeText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => setState(() => _tappedElementIndex = null),
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrayWithPointers(VisualizationStep step) {
    final list = step.elements.isNotEmpty ? step.elements : _elements;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(list.length, (index) {
            final value = list[index];
            final isLow = step.lowIndex == index;
            final isMid = step.midIndex == index;
            final isHigh = step.highIndex == index;

            final isEliminated = step.eliminatedIndices.contains(index);
            final isActive = step.activeIndices.contains(index);
            final isFound = step.isFound && step.foundIndex == index;

            String? pointerLabel;
            Color pointerColor = AppColors.textSecondary;

            if (isMid) {
              pointerLabel = 'MID';
              pointerColor = isFound ? AppColors.greenPrimary : AppColors.orangePrimary;
            } else if (isLow) {
              pointerLabel = 'LOW';
              pointerColor = AppColors.bluePrimary;
            } else if (isHigh) {
              pointerLabel = 'HIGH';
              pointerColor = AppColors.purplePrimary;
            }

            Color bgColor = AppColors.surface;
            Color borderColor = AppColors.cardBorder;
            Color textColor = AppColors.textPrimary;
            double opacity = 1.0;
            double scale = 1.0;

            if (isFound) {
              bgColor = AppColors.greenLight;
              borderColor = AppColors.greenPrimary;
              textColor = AppColors.greenPrimary;
              scale = 1.1;
            } else if (isMid) {
              bgColor = AppColors.orangeLight;
              borderColor = AppColors.orangePrimary;
              textColor = AppColors.orangePrimary;
              scale = 1.06;
            } else if (isEliminated) {
              bgColor = AppColors.surfaceSecondary.withValues(alpha: 0.35);
              borderColor = AppColors.cardBorder.withValues(alpha: 0.3);
              textColor = AppColors.textMuted.withValues(alpha: 0.3);
              opacity = 0.28;
            } else if (isActive) {
              bgColor = AppColors.surface;
              borderColor = AppColors.blueBorder;
              textColor = AppColors.textPrimary;
            }

            return AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: opacity,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 20,
                      alignment: Alignment.center,
                      child: pointerLabel != null
                          ? Text(
                              pointerLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: pointerColor,
                                letterSpacing: 0.5,
                              ),
                            )
                          : const SizedBox(height: 20),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      height: 16,
                      alignment: Alignment.center,
                      child: pointerLabel != null
                          ? Icon(
                              Icons.arrow_downward_rounded,
                              size: 14,
                              color: pointerColor,
                            )
                          : const SizedBox(height: 16),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (_tappedElementIndex == index) {
                            _tappedElementIndex = null;
                          } else {
                            _tappedElementIndex = index;
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        transform: Matrix4.diagonal3Values(scale, scale, 1.0),
                        width: 46,
                        height: 60,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: (_tappedElementIndex == index)
                                ? AppColors.tealPrimary
                                : borderColor,
                            width: (_tappedElementIndex == index || isMid || isFound) ? 2.5 : 1.2,
                          ),
                          boxShadow: (isMid || isFound || _tappedElementIndex == index)
                              ? [
                                  BoxShadow(
                                    color: (isFound
                                            ? AppColors.greenPrimary
                                            : (isMid ? AppColors.orangePrimary : AppColors.tealPrimary))
                                        .withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Center(
                              child: Text(
                                '$value',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                  decoration: isEliminated ? TextDecoration.lineThrough : null,
                                  decorationColor: AppColors.textMuted.withValues(alpha: 0.5),
                                ),
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
                                  child: const Icon(Icons.check, size: 10, color: AppColors.textLight),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildComparisonAndActionBox(VisualizationStep step) {
    if (step.isFound) {
      return ScaleTransition(
        scale: _celebrationScale,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.greenLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.greenBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.greenPrimary.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPill(
                    step.comparisonLeft.isNotEmpty ? step.comparisonLeft : 'Target $_target',
                    AppColors.tealPrimary,
                    AppColors.surface,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '=',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.greenPrimary,
                      ),
                    ),
                  ),
                  _buildPill(
                    step.comparisonRight.isNotEmpty ? step.comparisonRight : 'Middle ${step.midValue}',
                    AppColors.greenPrimary,
                    AppColors.surface,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.greenPrimary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.greenPrimary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 22, color: AppColors.textLight),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        step.actionDirection.isNotEmpty ? step.actionDirection : '✓ TARGET FOUND',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textLight,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPill(
                step.comparisonLeft.isNotEmpty ? step.comparisonLeft : 'Target $_target',
                AppColors.tealPrimary,
                AppColors.tealLight,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  step.comparisonOperator.isNotEmpty ? step.comparisonOperator : '>',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.orangePrimary,
                  ),
                ),
              ),
              _buildPill(
                step.comparisonRight.isNotEmpty ? step.comparisonRight : 'Middle ${step.midValue}',
                AppColors.orangePrimary,
                AppColors.orangeLight,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (step.midValue != null) ...[
            Text(
              '$_target ${step.comparisonOperator.isNotEmpty ? step.comparisonOperator : '>'} ${step.midValue}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
          ],
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.tealLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.tealBorder),
            ),
            child: const Icon(
              Icons.arrow_downward_rounded,
              size: 18,
              color: AppColors.tealPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.tealLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.tealBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.tealPrimary),
                const SizedBox(width: 8),
                Text(
                  step.actionDirection.isNotEmpty ? step.actionDirection : 'Search RIGHT HALF →',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.tealPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String text, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStep3UnderstandTheIdea(VisualizationStep step) {
    final blocks = step.summaryBlocks.isNotEmpty
        ? step.summaryBlocks
        : ['7 elements', '3 elements', '1 element', 'FOUND'];

    return Container(
      key: const ValueKey('step_3_understand_the_idea'),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Text(
            widget.topic.isNotEmpty ? widget.topic : 'Algorithm Logic',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(blocks.length, (idx) {
            final blockText = blocks[idx];
            final isFoundBlock = blockText.toUpperCase().contains('FOUND');
            final isLast = idx == blocks.length - 1;

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isFoundBlock ? AppColors.greenPrimary : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isFoundBlock ? AppColors.greenPrimary : AppColors.cardBorder,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isFoundBlock ? AppColors.greenPrimary : Colors.black)
                            .withValues(alpha: isFoundBlock ? 0.2 : 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isFoundBlock) ...[
                        const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.textLight),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '[ $blockText ]',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: isFoundBlock ? AppColors.textLight : AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast) ...[
                  const SizedBox(height: 6),
                  const Icon(
                    Icons.arrow_downward_rounded,
                    size: 18,
                    color: AppColors.tealPrimary,
                  ),
                  const SizedBox(height: 6),
                ],
              ],
            );
          }),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Text(
              step.shortExplanation ??
                  'Each comparison eliminates about half of the remaining search area.',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsRow(bool isFirstStep, bool isLastStep) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isFirstStep ? null : _goToPreviousStep,
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text(
              'Previous',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.cardBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: AppColors.surface,
              disabledForegroundColor: AppColors.textMuted.withValues(alpha: 0.4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: _isPlaying ? 'Pause' : 'Play',
          onPressed: _togglePlay,
          icon: Icon(
            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 20,
            color: AppColors.tealPrimary,
          ),
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(12),
            backgroundColor: _isPlaying ? AppColors.tealLight : AppColors.surfaceSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: _isPlaying ? AppColors.tealPrimary : AppColors.cardBorder,
                width: _isPlaying ? 1.5 : 1.0,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: _restart,
          icon: const Icon(Icons.replay_rounded, size: 16),
          label: const Text(
            'Restart',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            side: const BorderSide(color: AppColors.cardBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppColors.surfaceSecondary,
            foregroundColor: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLastStep ? null : _goToNextStep,
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: const Text(
              'Next',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tealPrimary,
              foregroundColor: AppColors.textLight,
              disabledBackgroundColor: AppColors.tealLight.withValues(alpha: 0.5),
              disabledForegroundColor: AppColors.tealPrimary.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}

/// Backwards-compatible alias for BinarySearchVisualizer pointing to AlgorithmVisualization
typedef BinarySearchVisualizer = AlgorithmVisualization;
