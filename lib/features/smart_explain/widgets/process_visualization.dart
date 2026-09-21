import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'topic_visualization_helper.dart';

/// Generic Process & Workflow Visualization Component for LearnX STREAM.
///
/// Handles multi-stage transformations, biological cycles, sequential workflows, and network protocols:
/// - Biological Cycles: Photosynthesis (Sunlight -> Water Splitting -> Calvin Cycle), Mitosis, Krebs Cycle.
/// - Network Protocols: TCP Three-Way Handshake (SYN -> SYN-ACK -> ACK), HTTP Request/Response, OAuth.
/// - Engineering Pipelines: Compiler Front/Back-end, CI/CD, Database ACID Transactions.
/// - Interactive particle/packet travel animation between actors/stages, stage checkpoints, and state indicators.
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

  @override
  void initState() {
    super.initState();
    _particleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _particlePosition = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleAnimController, curve: Curves.easeInOut),
    );
    _initFromData();
    _particleAnimController.forward();
  }

  @override
  void dispose() {
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
    } else {
      _actors = ['Input Source', 'Processing Engine'];
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
          title: '1. Initiation Phase',
          subtitle: 'Establish baseline inputs',
          description: 'Initial inputs are received and processed by the engine for ${widget.topic}.',
          fromActor: _actors.first,
          toActor: _actors.length > 1 ? _actors[1] : _actors.first,
          packetLabel: 'Input Signals',
          stateLabel: 'INITIATED',
          icon: Icons.play_arrow_rounded,
        ),
      ];
    }

    // 3. Components / Molecules (e.g. for Photosynthesis, TCP Handshake)
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
          description: 'High-energy organic sugar synthesized in chloroplast stroma, fueling plant cellular respiration, growth, and the global food web.',
          icon: Icons.grain_rounded,
          color: AppColors.greenPrimary,
          bgColor: AppColors.greenLight,
        ),
        const _ProcessComponent(
          id: 'oxygen',
          name: 'Oxygen',
          formula: 'O₂',
          role: 'Vital Byproduct Gas',
          description: 'Atmospheric gas generated directly from splitting water molecules during light reactions, sustaining aerobic respiration on Earth.',
          icon: Icons.bubble_chart_rounded,
          color: AppColors.tealPrimary,
          bgColor: AppColors.tealLight,
        ),
      ];
    } else if (lowerTopic.contains('tcp') || lowerTopic.contains('handshake')) {
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
        'Breaking complex processes into sequential stages provides intuitive checkpoints for mastering the workflow.';

    _activeStageIndex = 0;
    _selectedComponent = null;
  }

  void _nextStage() {
    if (_activeStageIndex < _stages.length - 1) {
      setState(() {
        _activeStageIndex++;
        _selectedComponent = null;
      });
      _particleAnimController.forward(from: 0.0);
    }
  }

  void _prevStage() {
    if (_activeStageIndex > 0) {
      setState(() {
        _activeStageIndex--;
        _selectedComponent = null;
      });
      _particleAnimController.forward(from: 0.0);
    }
  }

  void _restart() {
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
        // 1. Main Process Canvas Card
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
              // Header Row: Topic Badge & Stage Pill
              _buildHeader(currentStage),
              const SizedBox(height: 20),

              // Animated Actors & Traveling Particle Lane
              _buildActorLane(currentStage),
              const SizedBox(height: 22),

              // Stage Progression Steps (1 -> 2 -> 3)
              _buildStageCheckpoints(),
              const SizedBox(height: 18),

              // Interactive Component / Reactant Explorer Bar (if available)
              if (_components.isNotEmpty) ...[
                _buildComponentExplorer(),
                const SizedBox(height: 18),
              ],

              // Active Stage or Component Detailed Explanation Box
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _selectedComponent != null
                    ? _buildComponentDetailCard(_selectedComponent!)
                    : _buildStageDetailCard(currentStage),
              ),
              const SizedBox(height: 24),

              // Functional Navigation Bar: [Previous] [Restart] [Next]
              _buildControls(isFirst, isLast),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 2. Pedagogical Summary Card
        _buildWhyThisWorksCard(),
      ],
    );
  }

  Widget _buildHeader(_ProcessStage stage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.blueLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.blueBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sync_alt_rounded, size: 14, color: AppColors.bluePrimary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    widget.topic,
                    style: const TextStyle(
                      fontSize: 12.5,
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
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.tealLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.tealBorder),
          ),
          child: Text(
            'Stage ${stage.stageNumber} of ${_stages.length}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.tealPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActorLane(_ProcessStage stage) {
    final fromActor = stage.fromActor.isNotEmpty ? stage.fromActor : (_actors.isNotEmpty ? _actors.first : 'Source');
    final toActor = stage.toActor.isNotEmpty ? stage.toActor : (_actors.length > 1 ? _actors[1] : 'Target');
    final isLeftToRight = _actors.isEmpty || _actors.first == fromActor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
              _buildActorBadge(
                fromActor,
                isLeftToRight ? AppColors.bluePrimary : AppColors.purplePrimary,
                isLeftToRight ? AppColors.blueLight : AppColors.purpleLight,
                Icons.account_tree_rounded,
              ),
              _buildActorBadge(
                toActor,
                isLeftToRight ? AppColors.purplePrimary : AppColors.bluePrimary,
                isLeftToRight ? AppColors.purpleLight : AppColors.blueLight,
                Icons.memory_rounded,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Traveling Packet Animation
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
                            blurRadius: 8,
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

          // State Status Badge (e.g. SYN_SENT, LIGHT_CAPTURED, COMMITTED)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Text(
              'State: ${stage.stateLabel}',
              style: const TextStyle(
                fontSize: 11,
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

  Widget _buildActorBadge(String name, Color color, Color bgColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageCheckpoints() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_stages.length, (index) {
          final isCompleted = index < _activeStageIndex;
          final isCurrent = index == _activeStageIndex;

          Color borderColor = AppColors.cardBorder;
          Color bgColor = AppColors.surface;
          Color textColor = AppColors.textSecondary;

          if (isCurrent) {
            borderColor = AppColors.tealPrimary;
            bgColor = AppColors.tealLight;
            textColor = AppColors.tealPrimary;
          } else if (isCompleted) {
            borderColor = AppColors.greenBorder;
            bgColor = AppColors.greenLight;
            textColor = AppColors.greenPrimary;
          }

          return InkWell(
            onTap: () {
              setState(() {
                _activeStageIndex = index;
              });
              _particleAnimController.forward(from: 0.0);
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor, width: isCurrent ? 1.8 : 1.0),
              ),
              child: Row(
                children: [
                  Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : (isCurrent ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                    size: 13,
                    color: textColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Stage ${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStageDetailCard(_ProcessStage stage) {
    return Container(
      key: ValueKey('stage_${stage.stageNumber}'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.tealLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(stage.icon, size: 16, color: AppColors.tealPrimary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage.title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (stage.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        stage.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            stage.description,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(bool isFirst, bool isLast) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isFirst ? null : _prevStage,
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text('Previous', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.cardBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: AppColors.surface,
              disabledForegroundColor: AppColors.textMuted.withValues(alpha: 0.4),
            ),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: _restart,
          icon: const Icon(Icons.replay_rounded, size: 16),
          label: const Text('Restart', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            side: const BorderSide(color: AppColors.cardBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppColors.surfaceSecondary,
            foregroundColor: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLast ? _restart : _nextStage,
            icon: Icon(isLast ? Icons.check_circle_rounded : Icons.arrow_forward_rounded, size: 16),
            label: Text(
              isLast ? 'Restart' : 'Next',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tealPrimary,
              foregroundColor: AppColors.textLight,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComponentExplorer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                'Interactive Process Elements',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.tealLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Tap elements to inspect role',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.tealPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _components.map((comp) {
              final isSelected = _selectedComponent?.id == comp.id;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (_selectedComponent?.id == comp.id) {
                        _selectedComponent = null;
                      } else {
                        _selectedComponent = comp;
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? comp.bgColor : AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? comp.color : AppColors.cardBorder,
                        width: isSelected ? 1.8 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: comp.color.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(comp.icon, size: 15, color: isSelected ? comp.color : AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          comp.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? comp.color : AppColors.textPrimary,
                          ),
                        ),
                        if (comp.formula.isNotEmpty && comp.formula != comp.name) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(${comp.formula})',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? comp.color.withValues(alpha: 0.8) : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildComponentDetailCard(_ProcessComponent comp) {
    return Container(
      key: ValueKey('comp_${comp.id}'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: comp.bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: comp.color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: comp.color.withValues(alpha: 0.4)),
                ),
                child: Icon(comp.icon, size: 18, color: comp.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            comp.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: comp.color,
                              letterSpacing: -0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (comp.formula.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              comp.formula,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'monospace',
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Role: ${comp.role}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                onPressed: () => setState(() => _selectedComponent = null),
                tooltip: 'Return to stage view',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comp.description,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
        ],
      ),
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
              Icon(Icons.lightbulb_rounded, size: 18, color: AppColors.tealPrimary),
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
              color: AppColors.tealLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.tealBorder),
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

