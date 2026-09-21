import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'topic_visualization_helper.dart';

/// Generic Process & Workflow Visualization Component for LearnX STREAM.
///
/// Implements the Visualization-First spatial layout principle:
/// - Large central visual canvas (Inputs -> Central Processing Leaf/Engine -> Outputs).
/// - Direct element labels and chemical/system formulas.
/// - Meaningful animated flow arrows and particle streams.
/// - Clear visual hierarchy and single-action highlighting.
/// - Synchronized "What's happening?" explanation and teaching-speed controls.
class ProcessVisualization extends StatefulWidget {
  final String topic;
  final Map<String, dynamic>? visualizationData;

  const ProcessVisualization({
    super.key,
    required this.topic,
    this.visualizationData,
  });

  @override
  State<ProcessVisualization> createState() => _ProcessVisualizationState();
}

class _ProcessVisualizationState extends State<ProcessVisualization>
    with SingleTickerProviderStateMixin {
  int _activeStageIndex = 0;
  late List<String> _actors;
  late List<_ProcessStage> _stages;
  late List<_ProcessComponent> _components;
  _ProcessComponent? _selectedComponent;
  late String _whyWorksText;

  late AnimationController _particleAnimController;
  late Animation<double> _particlePosition;

  bool _isPlaying = false;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _particleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _particlePosition = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleAnimController, curve: Curves.easeInOutCubic),
    );

    _initFromData();
    _particleAnimController.forward();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _particleAnimController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ProcessVisualization oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visualizationData != widget.visualizationData ||
        oldWidget.topic != widget.topic) {
      _initFromData();
    }
  }

  bool get _isNetworkProtocol {
    final lower = widget.topic.toLowerCase();
    return lower.contains('tcp') ||
        lower.contains('handshake') ||
        lower.contains('http') ||
        lower.contains('packet') ||
        lower.contains('socket');
  }

  void _initFromData() {
    final rawData = widget.visualizationData;
    final bool hasValidStages = rawData != null &&
        (rawData['stages'] is List || rawData['steps'] is List);

    final data = hasValidStages
        ? rawData
        : TopicVisualizationHelper.getStepByStepData(widget.topic, rawData);

    // 1. Actors
    final rawActors = data['actors'] as List<dynamic>?;
    if (rawActors != null && rawActors.isNotEmpty) {
      _actors = rawActors.map((e) => e.toString()).toList();
    } else if (_isNetworkProtocol) {
      _actors = ['Client', 'Server'];
    } else {
      _actors = ['Inputs', 'Process', 'Outputs'];
    }

    // 2. Stages / Steps
    final rawStages = (data['stages'] as List<dynamic>?) ?? (data['steps'] as List<dynamic>?);
    if (rawStages != null && rawStages.isNotEmpty) {
      _stages = rawStages
          .whereType<Map<String, dynamic>>()
          .map((s) => _ProcessStage.fromJson(s))
          .toList();
    } else {
      _stages = [
        _ProcessStage(
          stageNumber: 1,
          title: '1. Light Energy Absorption',
          subtitle: 'Photons excite chloroplast chlorophyll',
          description: 'Solar light rays strike chlorophyll pigments, energizing electrons to initiate photosynthesis.',
          fromActor: 'Sunlight',
          toActor: 'Leaf Chloroplast',
          packetLabel: 'Solar Photons',
          stateLabel: 'LIGHT_ABSORPTION',
          icon: Icons.wb_sunny_rounded,
        ),
        _ProcessStage(
          stageNumber: 2,
          title: '2. Water & Carbon Dioxide Intake',
          subtitle: 'Roots draw H₂O, stomata absorb CO₂',
          description: 'Water molecules enter from the roots while atmospheric carbon dioxide diffuses into leaf cells.',
          fromActor: 'H₂O & CO₂',
          toActor: 'Thylakoid Membrane',
          packetLabel: 'Reactants Entering',
          stateLabel: 'REACTANT_INTAKE',
          icon: Icons.water_drop_rounded,
        ),
        _ProcessStage(
          stageNumber: 3,
          title: '3. Chemical Transformation (Calvin Cycle)',
          subtitle: 'Light reactions split water and fix carbon',
          description: 'Enzymes and chemical energy convert carbon dioxide and hydrogen into organic sugar compounds.',
          fromActor: 'Reaction Core',
          toActor: 'Stroma',
          packetLabel: 'Carbon Fixation',
          stateLabel: 'TRANSFORMATION',
          icon: Icons.autorenew_rounded,
        ),
      ];
    }

    // 3. Components / Reactants
    final lowerTopic = widget.topic.toLowerCase();
    final rawComps = data['components'] as List<dynamic>?;
    if (rawComps != null && rawComps.isNotEmpty) {
      _components = rawComps
          .whereType<Map<String, dynamic>>()
          .map((c) => _ProcessComponent.fromJson(c))
          .toList();
    } else if (lowerTopic.contains('photosynthesis') ||
        lowerTopic.contains('plant') ||
        lowerTopic.contains('chloroplast') ||
        lowerTopic.contains('calvin')) {
      _components = [
        const _ProcessComponent(
          id: 'sunlight',
          name: 'Sunlight',
          formula: 'Photons (hν)',
          role: 'Energy Source',
          description: 'Solar photons excite chlorophyll electrons in thylakoid membranes, providing energy to power photolysis and split water.',
          icon: Icons.wb_sunny_rounded,
          color: AppColors.orangePrimary,
          bgColor: AppColors.orangeLight,
        ),
        const _ProcessComponent(
          id: 'water',
          name: 'Water',
          formula: 'H₂O',
          role: 'Electron Donor & Reactant',
          description: 'Absorbed by plant roots; photolysis splits water into electrons, protons (H+), and releases essential byproduct oxygen (O₂).',
          icon: Icons.water_drop_rounded,
          color: AppColors.bluePrimary,
          bgColor: AppColors.blueLight,
        ),
        const _ProcessComponent(
          id: 'co2',
          name: 'CO₂',
          formula: 'Carbon Dioxide',
          role: 'Carbon Backbone Reactant',
          description: 'Diffuses into leaves via stomata; RuBisCO enzymes fix CO₂ in the Calvin cycle to assemble organic sugar backbones.',
          icon: Icons.cloud_outlined,
          color: AppColors.purplePrimary,
          bgColor: AppColors.purpleLight,
        ),
        const _ProcessComponent(
          id: 'glucose',
          name: 'Glucose',
          formula: 'C₆H₁₂O₆',
          role: 'Stored Chemical Energy',
          description: 'High-energy organic sugar synthesized in chloroplast stroma, fueling plant growth and cellular respiration.',
          icon: Icons.grain_rounded,
          color: AppColors.greenPrimary,
          bgColor: AppColors.greenLight,
        ),
        const _ProcessComponent(
          id: 'oxygen',
          name: 'Oxygen',
          formula: 'O₂',
          role: 'Vital Byproduct Gas',
          description: 'Atmospheric gas generated directly from splitting water molecules during light reactions, sustaining aerobic respiration.',
          icon: Icons.bubble_chart_rounded,
          color: AppColors.tealPrimary,
          bgColor: AppColors.tealLight,
        ),
      ];
    } else if (_isNetworkProtocol) {
      _components = [
        const _ProcessComponent(
          id: 'syn',
          name: 'SYN Packet',
          formula: 'Seq = ISN',
          role: 'Connection Request',
          description: 'Client generates an Initial Sequence Number and requests to establish synchronized communication with server.',
          icon: Icons.flight_takeoff_rounded,
          color: AppColors.bluePrimary,
          bgColor: AppColors.blueLight,
        ),
        const _ProcessComponent(
          id: 'syn_ack',
          name: 'SYN-ACK Packet',
          formula: 'Seq = ServerISN, Ack = ISN+1',
          role: 'Server Acknowledgment & Sync',
          description: 'Server verifies client sequence, acknowledges it with Ack=ISN+1, and sends its own server sequence number.',
          icon: Icons.sync_alt_rounded,
          color: AppColors.purplePrimary,
          bgColor: AppColors.purpleLight,
        ),
        const _ProcessComponent(
          id: 'ack',
          name: 'ACK Packet',
          formula: 'Ack = ServerISN+1',
          role: 'Final Verification',
          description: 'Client acknowledges server sequence number; both sockets transition to ESTABLISHED state for full-duplex data transfer.',
          icon: Icons.verified_rounded,
          color: AppColors.greenPrimary,
          bgColor: AppColors.greenLight,
        ),
      ];
    } else {
      _components = [];
    }

    _whyWorksText = data['why_this_works'] as String? ??
        'Breaking complex processes into sequential spatial stages provides intuitive checkpoints for mastering the workflow.';

    _activeStageIndex = 0;
    _selectedComponent = null;
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    setState(() => _isPlaying = true);
    _autoPlayTimer = Timer.periodic(const Duration(milliseconds: 2600), (timer) {
      if (_activeStageIndex < _stages.length - 1) {
        _nextStage(fromAutoPlay: true);
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
      if (_activeStageIndex >= _stages.length - 1) {
        _restart();
      }
      _startAutoPlay();
    }
  }

  void _nextStage({bool fromAutoPlay = false}) {
    if (!fromAutoPlay) _stopAutoPlay();
    if (_activeStageIndex < _stages.length - 1) {
      setState(() {
        _activeStageIndex++;
        _selectedComponent = null;
      });
      _particleAnimController.forward(from: 0.0);
    }
  }

  void _prevStage() {
    _stopAutoPlay();
    if (_activeStageIndex > 0) {
      setState(() {
        _activeStageIndex--;
        _selectedComponent = null;
      });
      _particleAnimController.forward(from: 0.0);
    }
  }

  void _restart() {
    _stopAutoPlay();
    setState(() {
      _activeStageIndex = 0;
      _selectedComponent = null;
    });
    _particleAnimController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    if (_stages.isEmpty) return const SizedBox.shrink();

    final currentStage = _stages[_activeStageIndex];
    final isFirst = _activeStageIndex == 0;
    final isLast = _activeStageIndex == _stages.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. DOMINANT CENTRAL VISUALIZATION CANVAS (65-75% screen presence)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row: Topic Badge & Stage Counter
              _buildCanvasHeader(currentStage),
              const SizedBox(height: 14),

              // Large Spatial Visual Diagram (Photosynthesis / Spatial Cycle OR Protocol Timeline)
              _isNetworkProtocol
                  ? _buildProtocolTimeline(currentStage)
                  : _buildSpatialProcessCanvas(currentStage),

              const SizedBox(height: 12),

              // Active Stage or Component "What's happening?" Card
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _selectedComponent != null
                    ? _buildComponentDetailCard(_selectedComponent!)
                    : _buildWhatsHappeningCard(currentStage),
              ),
              const SizedBox(height: 12),

              // Unified Pacing Navigation Controls
              _buildUnifiedControls(isFirst, isLast),
              const SizedBox(height: 12),

              // Interactive Element Chips (Tap to inspect)
              if (_components.isNotEmpty) ...[
                _buildComponentExplorer(),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Crisp Key Idea Card
        _buildWhyThisWorksCard(),
      ],
    );
  }

  Widget _buildCanvasHeader(_ProcessStage stage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.blueLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.blueBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sync_alt_rounded, size: 14, color: AppColors.bluePrimary),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    widget.topic,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.bluePrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),

        // Stage Progression Dots (● ● ● ○ ○)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_stages.length, (i) {
            final isActive = i == _activeStageIndex;
            final isDone = i < _activeStageIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: isActive ? 14 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.tealPrimary
                    : (isDone ? AppColors.tealPrimary.withValues(alpha: 0.45) : AppColors.cardBorder),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),

        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.tealLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.tealBorder),
          ),
          child: Text(
            'Stage ${stage.stageNumber} of ${_stages.length}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.tealPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// Large Spatial Process Canvas (Inputs -> Central Leaf/Engine -> Outputs)
  Widget _buildSpatialProcessCanvas(_ProcessStage stage) {
    final stepNum = stage.stageNumber;
    final isTransformStep = stepNum == 2 || stepNum == 3;
    final isOutputStep = stepNum >= 3;

    return Container(
      constraints: const BoxConstraints(minHeight: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          // ── INPUT LAYER ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildConceptObject(
                icon: Icons.wb_sunny_rounded,
                name: 'Sunlight',
                formula: 'Photons',
                role: 'Energy',
                color: AppColors.orangePrimary,
                bgColor: AppColors.orangeLight,
                isActive: stepNum == 1,
              ),
              _buildConceptObject(
                icon: Icons.cloud_outlined,
                name: 'CO₂',
                formula: 'Carbon Dioxide',
                role: 'Gas',
                color: AppColors.purplePrimary,
                bgColor: AppColors.purpleLight,
                isActive: stepNum == 1 || stepNum == 2,
              ),
              _buildConceptObject(
                icon: Icons.water_drop_rounded,
                name: 'H₂O',
                formula: 'Water',
                role: 'Liquid',
                color: AppColors.bluePrimary,
                bgColor: AppColors.blueLight,
                isActive: stepNum == 1 || stepNum == 2,
              ),
            ],
          ),
          const SizedBox(height: 6),

          // ── ANIMATED INPUT ARROWS ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAnimatedArrow(
                direction: Icons.arrow_downward_rounded,
                color: AppColors.orangePrimary,
                isActive: stepNum == 1,
              ),
              _buildAnimatedArrow(
                direction: Icons.south_east_rounded,
                color: AppColors.purplePrimary,
                isActive: stepNum == 2,
              ),
              _buildAnimatedArrow(
                direction: Icons.south_west_rounded,
                color: AppColors.bluePrimary,
                isActive: stepNum == 2,
              ),
            ],
          ),
          const SizedBox(height: 6),

          // ── CENTRAL TRANSFORMATION PROCESSOR (Leaf / Chloroplast Core) ──
          AnimatedBuilder(
            animation: _particlePosition,
            builder: (context, child) {
              final pulse = _particlePosition.value;
              final auraGlow = isTransformStep ? (pulse * 8.0 + 4.0) : 0.0;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isTransformStep ? AppColors.greenLight : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isTransformStep ? AppColors.greenPrimary : AppColors.cardBorder,
                    width: isTransformStep ? 2.0 : 1.0,
                  ),
                  boxShadow: isTransformStep
                      ? [
                          BoxShadow(
                            color: AppColors.greenPrimary.withValues(alpha: 0.35),
                            blurRadius: auraGlow,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isTransformStep ? AppColors.greenPrimary : AppColors.greenLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.eco_rounded,
                        size: 18,
                        color: isTransformStep ? AppColors.textLight : AppColors.greenPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🌿 LEAF / CHLOROPLAST',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          isTransformStep
                            ? '⚡ Reactions Active'
                            : 'Chemical Transformation Core',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: isTransformStep ? FontWeight.w800 : FontWeight.w500,
                            color: isTransformStep ? AppColors.greenPrimary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 6),

          // ── ANIMATED OUTPUT ARROWS ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAnimatedArrow(
                direction: Icons.south_west_rounded,
                color: AppColors.greenPrimary,
                isActive: isOutputStep,
              ),
              _buildAnimatedArrow(
                direction: Icons.south_east_rounded,
                color: AppColors.tealPrimary,
                isActive: isOutputStep,
              ),
            ],
          ),
          const SizedBox(height: 6),

          // ── OUTPUT LAYER ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildConceptObject(
                icon: Icons.grain_rounded,
                name: 'Glucose',
                formula: 'C₆H₁₂O₆',
                role: 'Energy Stored',
                color: AppColors.greenPrimary,
                bgColor: AppColors.greenLight,
                isActive: isOutputStep,
              ),
              _buildConceptObject(
                icon: Icons.bubble_chart_rounded,
                name: 'Oxygen',
                formula: 'O₂',
                role: 'Released Gas',
                color: AppColors.tealPrimary,
                bgColor: AppColors.tealLight,
                isActive: isOutputStep,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConceptObject({
    required IconData icon,
    required String name,
    required String formula,
    required String role,
    required Color color,
    required Color bgColor,
    required bool isActive,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? bgColor : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? color : AppColors.cardBorder,
          width: isActive ? 1.8 : 1.0,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 2),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isActive ? color : AppColors.textPrimary,
            ),
          ),
          if (formula.isNotEmpty) ...[
            Text(
              formula,
              style: TextStyle(
                fontSize: 9.5,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
                color: isActive ? color.withValues(alpha: 0.9) : AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimatedArrow({
    required IconData direction,
    required Color color,
    required bool isActive,
  }) {
    return AnimatedBuilder(
      animation: _particlePosition,
      builder: (context, child) {
        final t = _particlePosition.value;
        final opacity = isActive ? (0.4 + 0.6 * math.sin(t * math.pi)) : 0.25;

        return Opacity(
          opacity: opacity.clamp(0.2, 1.0),
          child: Icon(
            direction,
            size: 18,
            color: isActive ? color : AppColors.textMuted,
          ),
        );
      },
    );
  }

  /// Protocol Timeline Sequence (Client <-> Server)
  Widget _buildProtocolTimeline(_ProcessStage stage) {
    final fromActor = stage.fromActor.isNotEmpty ? stage.fromActor : (_actors.isNotEmpty ? _actors.first : 'Client');
    final toActor = stage.toActor.isNotEmpty ? stage.toActor : (_actors.length > 1 ? _actors[1] : 'Server');
    final isLeftToRight = _actors.isEmpty || _actors.first.toLowerCase() == fromActor.toLowerCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActorBadge(fromActor, AppColors.bluePrimary, AppColors.blueLight),
              _buildActorBadge(toActor, AppColors.purplePrimary, AppColors.purpleLight),
            ],
          ),
          const SizedBox(height: 14),

          // Traveling Packet Animation Lane
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              AnimatedBuilder(
                animation: _particlePosition,
                builder: (context, child) {
                  final t = _particlePosition.value;
                  final alignX = isLeftToRight ? (-1.0 + (t * 2.0)) : (1.0 - (t * 2.0));

                  return Align(
                    alignment: Alignment(alignX.clamp(-0.95, 0.95), 0.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.tealPrimary,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.tealPrimary.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLeftToRight ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
                            size: 12,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            stage.packetLabel,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Protocol State Flag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Text(
              'State: ${stage.stateLabel}',
              style: const TextStyle(
                fontSize: 10.5,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActorBadge(String name, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  /// "What's happening?" single state card
  Widget _buildWhatsHappeningCard(_ProcessStage stage) {
    return Container(
      key: ValueKey('stage_${stage.stageNumber}'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tealLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tealBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.tealPrimary),
              ),
              const SizedBox(width: 6),
              const Text(
                "WHAT'S HAPPENING?",
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: AppColors.tealPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            stage.description,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedControls(bool isFirst, bool isLast) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isFirst ? null : _prevStage,
            icon: const Icon(Icons.arrow_back_rounded, size: 15),
            label: const Text('Previous', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 11),
              side: const BorderSide(color: AppColors.cardBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: AppColors.surface,
              disabledForegroundColor: AppColors.textMuted.withValues(alpha: 0.4),
            ),
          ),
        ),
        const SizedBox(width: 6),
        IconButton.filledTonal(
          tooltip: _isPlaying ? 'Pause' : 'Play',
          onPressed: _togglePlay,
          icon: Icon(
            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 18,
            color: AppColors.tealPrimary,
          ),
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(10),
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
        const SizedBox(width: 6),
        OutlinedButton.icon(
          onPressed: _restart,
          icon: const Icon(Icons.replay_rounded, size: 15),
          label: const Text('Restart', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
            side: const BorderSide(color: AppColors.cardBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppColors.surfaceSecondary,
            foregroundColor: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLast ? _restart : _nextStage,
            icon: Icon(isLast ? Icons.check_circle_rounded : Icons.arrow_forward_rounded, size: 15),
            label: Text(
              isLast ? 'Restart' : 'Next',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tealPrimary,
              foregroundColor: AppColors.textLight,
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComponentExplorer() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _components.map((comp) {
          final isSelected = _selectedComponent?.id == comp.id;

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedComponent = isSelected ? null : comp;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected ? comp.bgColor : AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? comp.color : AppColors.cardBorder,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(comp.icon, size: 13, color: isSelected ? comp.color : AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      comp.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? comp.color : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildComponentDetailCard(_ProcessComponent comp) {
    return Container(
      key: ValueKey('comp_${comp.id}'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: comp.bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: comp.color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(comp.icon, size: 15, color: comp.color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${comp.name} (${comp.formula})',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: comp.color,
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close_rounded, size: 15),
                onPressed: () => setState(() => _selectedComponent = null),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            comp.description,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyThisWorksCard() {
    return Container(
      padding: const EdgeInsets.all(18),
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
              Icon(Icons.lightbulb_rounded, size: 18, color: AppColors.tealPrimary),
              SizedBox(width: 8),
              Text(
                'Why this works',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _whyWorksText,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessComponent {
  final String id;
  final String name;
  final String formula;
  final String role;
  final String description;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _ProcessComponent({
    required this.id,
    required this.name,
    required this.formula,
    required this.role,
    required this.description,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  factory _ProcessComponent.fromJson(Map<String, dynamic> json) {
    return _ProcessComponent(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['title'] as String? ?? 'Component',
      formula: json['formula'] as String? ?? json['subtitle'] as String? ?? '',
      role: json['role'] as String? ?? 'Reactant / Factor',
      description: json['description'] as String? ?? '',
      icon: Icons.bubble_chart_rounded,
      color: AppColors.tealPrimary,
      bgColor: AppColors.tealLight,
    );
  }
}

class _ProcessStage {
  final int stageNumber;
  final String title;
  final String subtitle;
  final String description;
  final String fromActor;
  final String toActor;
  final String packetLabel;
  final String stateLabel;
  final IconData icon;

  const _ProcessStage({
    required this.stageNumber,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.fromActor,
    required this.toActor,
    required this.packetLabel,
    required this.stateLabel,
    required this.icon,
  });

  factory _ProcessStage.fromJson(Map<String, dynamic> json) {
    return _ProcessStage(
      stageNumber: (json['stage_number'] as num?)?.toInt() ?? (json['step_number'] as num?)?.toInt() ?? 1,
      title: json['title'] as String? ?? 'Stage',
      subtitle: json['subtitle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      fromActor: json['from_actor'] as String? ?? json['from'] as String? ?? '',
      toActor: json['to_actor'] as String? ?? json['to'] as String? ?? '',
      packetLabel: json['packet_label'] as String? ?? json['action'] as String? ?? 'Action',
      stateLabel: json['state_label'] as String? ?? 'ACTIVE',
      icon: Icons.sync_rounded,
    );
  }
}

/// Backwards-compatible alias for WorkflowVisualizer pointing to ProcessVisualization
typedef WorkflowVisualizer = ProcessVisualization;
