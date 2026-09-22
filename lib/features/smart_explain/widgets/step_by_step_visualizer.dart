import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'topic_visualization_helper.dart';

/// Rich Animated Step-by-Step Visualizer for multi-stage protocols and sequential flows.
/// (e.g. TCP Three-Way Handshake, Photosynthesis, Authentication flows).
///
/// Features:
/// 1. Interactive animated packet / message flow traveling between actors (e.g. Client <-> Server).
/// 2. Clear stage checkpoints with state labels (e.g. SYN_SENT -> SYN_RCVD -> ESTABLISHED).
/// 3. Step-by-step navigation (Previous, Next, Restart).
/// 4. Concise 1-2 sentence explanations without text walls.
/// 5. "Why this works" pedagogical card.
class StepByStepVisualizer extends StatefulWidget {
  final String topic;
  final Map<String, dynamic>? visualizationData;

  const StepByStepVisualizer({
    super.key,
    required this.topic,
    this.visualizationData,
  });

  @override
  State<StepByStepVisualizer> createState() => _StepByStepVisualizerState();
}

class _StepByStepVisualizerState extends State<StepByStepVisualizer>
    with SingleTickerProviderStateMixin {
  int _activeStageIndex = 0;
  late List<String> _actors;
  late List<_WorkflowStage> _stages;
  late String _whyWorksText;

  late AnimationController _packetAnimController;
  late Animation<double> _packetPosition;

  @override
  void initState() {
    super.initState();
    _packetAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _packetPosition = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _packetAnimController, curve: Curves.easeInOut),
    );
    _initFromData();
    _packetAnimController.forward();
  }

  @override
  void dispose() {
    _packetAnimController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StepByStepVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visualizationData != widget.visualizationData ||
        oldWidget.topic != widget.topic) {
      _initFromData();
    }
  }

  void _initFromData() {
    final rawData = widget.visualizationData;
    final bool hasValidStages = rawData != null &&
        rawData['stages'] is List &&
        (rawData['stages'] as List).isNotEmpty;

    final data = hasValidStages
        ? rawData
        : TopicVisualizationHelper.getStepByStepData(widget.topic, rawData);

    final rawActors = data['actors'] as List<dynamic>?;
    if (rawActors != null && rawActors.isNotEmpty) {
      _actors = rawActors.map((a) => a.toString()).toList();
    } else {
      _actors = ['Step Initiation', 'Execution Result'];
    }

    final rawStages = data['stages'] as List<dynamic>?;
    if (rawStages != null && rawStages.isNotEmpty) {
      _stages = rawStages.map((s) {
        if (s is Map<String, dynamic>) {
          return _WorkflowStage(
            stageNumber: (s['stage_number'] as num?)?.toInt() ?? 1,
            title: s['title']?.toString() ?? 'Stage',
            fromActor: s['from_actor']?.toString() ?? _actors.first,
            toActor: s['to_actor']?.toString() ?? _actors.last,
            packetLabel: s['packet_label']?.toString() ?? 'State Checkpoint',
            direction: s['direction']?.toString() ?? 'client_to_server',
            explanation: s['explanation']?.toString() ?? (s['description']?.toString() ?? ''),
            stateLabel: s['state_label']?.toString() ?? '',
            iconName: s['icon']?.toString(),
          );
        }
        return _WorkflowStage(
          stageNumber: 1,
          title: s.toString(),
          fromActor: _actors.first,
          toActor: _actors.last,
          packetLabel: 'Data Transfer',
          direction: 'client_to_server',
          explanation: '',
          stateLabel: '',
        );
      }).toList();
    } else {
      _stages = [];
    }

    _whyWorksText = data['why_this_works'] as String? ??
        'Step-by-step breakdowns turn complex multi-stage processes into clear sequential checkpoints.';

    _activeStageIndex = 0;
  }

  void _goToStage(int index) {
    if (index >= 0 && index < _stages.length) {
      setState(() {
        _activeStageIndex = index;
      });
      _packetAnimController.reset();
      _packetAnimController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_stages.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentStage = _stages[_activeStageIndex];
    final isFirst = _activeStageIndex == 0;
    final isLast = _activeStageIndex == _stages.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Main Animated Stage Visualizer Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.getSurface(isDark),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.getCardBorder(isDark)),
            boxShadow: AppColors.softShadowFor(isDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header & Step Counter
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Text(
                    widget.topic.isNotEmpty ? widget.topic : 'Step-by-Step Workflow',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.getTealLight(isDark),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.getTealBorder(isDark)),
                    ),
                    child: Text(
                      'STAGE ${_activeStageIndex + 1} of ${_stages.length}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.tealPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Animated Packet Travel Visual (Client <---> Server)
              _buildAnimatedFlowVisual(currentStage, isDark),
              const SizedBox(height: 18),

              // Current Stage Explanation Box
              _buildStageExplanationBox(currentStage, isDark),
              const SizedBox(height: 18),

              // Step Navigation Controls [Previous] [Next] / [Restart]
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 560;
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isFirst ? null : () => _goToStage(_activeStageIndex - 1),
                          icon: const Icon(Icons.arrow_back_rounded, size: 15),
                          label: Text(
                            'Previous',
                            style: TextStyle(
                              fontSize: isCompact ? 12 : 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            side: BorderSide(color: AppColors.getCardBorder(isDark)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: AppColors.getSurface(isDark),
                            foregroundColor: AppColors.getTextPrimary(isDark),
                            disabledForegroundColor: AppColors.getTextMuted(isDark).withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isLast)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _goToStage(0),
                            icon: const Icon(Icons.replay_rounded, size: 15),
                            label: Text(
                              'Restart',
                              style: TextStyle(
                                fontSize: isCompact ? 12 : 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.tealPrimary,
                              foregroundColor: AppColors.textLight,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
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
                            onPressed: () => _goToStage(_activeStageIndex + 1),
                            icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                            label: Text(
                              'Next',
                              style: TextStyle(
                                fontSize: isCompact ? 12 : 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.tealPrimary,
                              foregroundColor: AppColors.textLight,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
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
        const SizedBox(height: 18),

        // 2. All Stages Progress Timeline
        _buildStagesTimeline(isDark),
        const SizedBox(height: 18),

        // 3. "Why this works" Card
        _buildWhyThisWorksCard(isDark),
      ],
    );
  }

  Widget _buildAnimatedFlowVisual(_WorkflowStage stage, bool isDark) {
    final isRightToLeft = stage.direction == 'server_to_client';
    final isBidirectional = stage.direction == 'bidirectional';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceSecondary(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.getCardBorder(isDark)),
      ),
      child: Column(
        children: [
          // Actor Endpoints (e.g. Client & Server)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // From Actor Card (Left)
              _buildActorCard(
                name: _actors.isNotEmpty ? _actors.first : 'Client',
                icon: Icons.computer_rounded,
                color: AppColors.tealPrimary,
                bgColor: AppColors.getTealLight(isDark),
                isDark: isDark,
              ),

              // Message in Transit
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: AnimatedBuilder(
                    animation: _packetAnimController,
                    builder: (context, child) {
                      double alignX;
                      if (isBidirectional) {
                        alignX = 0.0;
                      } else if (isRightToLeft) {
                        alignX = 1.0 - (_packetPosition.value * 2.0); // 1 to -1
                      } else {
                        alignX = -1.0 + (_packetPosition.value * 2.0); // -1 to 1
                      }

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Dashed / Track Line
                          Container(
                            height: 2,
                            color: AppColors.getCardBorder(isDark),
                          ),
                          // Moving Packet Badge
                          Align(
                            alignment: Alignment(alignX.clamp(-1.0, 1.0), 0.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isBidirectional
                                    ? AppColors.getGreenLight(isDark)
                                    : (isRightToLeft ? AppColors.getBlueLight(isDark) : AppColors.getTealLight(isDark)),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isBidirectional
                                      ? AppColors.greenPrimary
                                      : (isRightToLeft ? AppColors.bluePrimary : AppColors.tealPrimary),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isBidirectional
                                            ? AppColors.greenPrimary
                                            : AppColors.tealPrimary)
                                        .withValues(alpha: 0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 160),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isBidirectional
                                          ? Icons.swap_horiz_rounded
                                          : (isRightToLeft ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded),
                                      size: 12,
                                      color: isBidirectional
                                          ? AppColors.greenPrimary
                                          : (isRightToLeft ? AppColors.bluePrimary : AppColors.tealPrimary),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        stage.packetLabel,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: isBidirectional
                                              ? AppColors.greenPrimary
                                              : (isRightToLeft ? AppColors.bluePrimary : AppColors.tealPrimary),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // To Actor Card (Right)
              _buildActorCard(
                name: _actors.length > 1 ? _actors[1] : 'Server',
                icon: Icons.dns_rounded,
                color: AppColors.bluePrimary,
                bgColor: AppColors.getBlueLight(isDark),
                isDark: isDark,
              ),
            ],
          ),
          if (stage.stateLabel.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.getSurface(isDark),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.getCardBorder(isDark)),
              ),
              child: Text(
                'Status: ${stage.stateLabel}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActorCard({
    required String name,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required bool isDark,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.getTextPrimary(isDark),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStageExplanationBox(_WorkflowStage stage, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: stage.direction == 'bidirectional'
            ? AppColors.getGreenLight(isDark)
            : AppColors.getSurfaceSecondary(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: stage.direction == 'bidirectional'
              ? AppColors.getGreenBorder(isDark)
              : AppColors.getCardBorder(isDark),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                stage.direction == 'bidirectional'
                    ? Icons.check_circle_rounded
                    : Icons.send_rounded,
                size: 17,
                color: stage.direction == 'bidirectional'
                    ? AppColors.greenPrimary
                    : AppColors.tealPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stage.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: stage.direction == 'bidirectional'
                        ? AppColors.greenPrimary
                        : AppColors.getTextPrimary(isDark),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            stage.explanation,
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

  Widget _buildStagesTimeline(bool isDark) {
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
          Text(
            'Stage Progression',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(_stages.length, (index) {
            final s = _stages[index];
            final isActive = _activeStageIndex == index;
            final isCompleted = _activeStageIndex > index;

            return InkWell(
              onTap: () => _goToStage(index),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.getGreenLight(isDark)
                            : (isActive ? AppColors.tealPrimary : AppColors.getSurfaceSecondary(isDark)),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted
                              ? AppColors.greenPrimary
                              : (isActive ? AppColors.tealPrimary : AppColors.getCardBorder(isDark)),
                        ),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, size: 14, color: AppColors.greenPrimary)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isActive ? AppColors.textLight : AppColors.getTextSecondary(isDark),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                          color: isActive ? AppColors.tealPrimary : AppColors.getTextPrimary(isDark),
                        ),
                      ),
                    ),
                    if (isActive)
                      const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.tealPrimary),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWhyThisWorksCard(bool isDark) {
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
              const Icon(Icons.lightbulb_rounded, size: 18, color: AppColors.orangePrimary),
              const SizedBox(width: 8),
              Text(
                'Why this works',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.getTextPrimary(isDark),
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
              color: AppColors.getOrangeLight(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.getOrangeBorder(isDark)),
            ),
            child: Text(
              _whyWorksText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFFED7AA) : const Color(0xFF7C2D12),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkflowStage {
  final int stageNumber;
  final String title;
  final String fromActor;
  final String toActor;
  final String packetLabel;
  final String direction;
  final String explanation;
  final String stateLabel;
  final String? iconName;

  _WorkflowStage({
    required this.stageNumber,
    required this.title,
    required this.fromActor,
    required this.toActor,
    required this.packetLabel,
    required this.direction,
    required this.explanation,
    required this.stateLabel,
    this.iconName,
  });
}
