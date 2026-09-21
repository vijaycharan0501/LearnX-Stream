import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'topic_visualization_helper.dart';

/// Generic Interactive Diagram Visualization for LearnX STREAM.
///
/// Handles relational models, diagrams, entity relationships, and architectural components:
/// - Relational Databases & SQL JOINs (INNER, LEFT, RIGHT, FULL OUTER)
/// - Anatomical & Biological Systems (e.g. Human Heart chambers & systemic circulation)
/// - Network Topologies & System Architectures (e.g. Client-Server-Database tiers)
/// - Interactive node/region selection with real-time inspection, relationship highlighting, and pedagogical rationale.
class InteractiveDiagramVisualization extends StatefulWidget {
  final String topic;
  final Map<String, dynamic>? visualizationData;

  const InteractiveDiagramVisualization({
    super.key,
    required this.topic,
    this.visualizationData,
  });

  @override
  State<InteractiveDiagramVisualization> createState() => _InteractiveDiagramVisualizationState();
}

class _InteractiveDiagramVisualizationState extends State<InteractiveDiagramVisualization> {
  late String _title;
  late String _subtitle;
  late List<_DiagramNode> _nodes;
  late List<_DiagramModeOption> _modes;
  late int _selectedModeIndex;
  late _DiagramNode? _selectedNode;
  late String _whyWorksText;

  @override
  void initState() {
    super.initState();
    _initFromData();
  }

  @override
  void didUpdateWidget(covariant InteractiveDiagramVisualization oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visualizationData != widget.visualizationData ||
        oldWidget.topic != widget.topic) {
      _initFromData();
    }
  }

  void _initFromData() {
    final rawData = widget.visualizationData;
    final bool hasValidData = rawData != null &&
        (rawData['nodes'] is List || rawData['diagram_modes'] is List);

    final data = hasValidData
        ? rawData
        : TopicVisualizationHelper.getInteractiveDiagramData(widget.topic, rawData);

    _title = data['title'] as String? ?? (widget.topic.isNotEmpty ? widget.topic : 'Interactive Diagram');
    _subtitle = data['subtitle'] as String? ?? 'Explore relationships and interactive visual elements.';
    _whyWorksText = data['why_this_works'] as String? ??
        'Interactive diagrams show how separate entities connect and transform data together.';

    // Modes
    final rawModes = data['diagram_modes'] as List<dynamic>? ?? [];
    if (rawModes.isNotEmpty) {
      _modes = rawModes
          .whereType<Map<String, dynamic>>()
          .map((m) => _DiagramModeOption.fromJson(m))
          .toList();
    } else {
      _modes = [
        const _DiagramModeOption(
          id: 'standard',
          label: 'Default View',
          description: 'Standard relational view',
          highlightedRegion: 'all',
        ),
      ];
    }
    _selectedModeIndex = 0;

    // Nodes
    final rawNodes = data['nodes'] as List<dynamic>? ?? [];
    if (rawNodes.isNotEmpty) {
      _nodes = rawNodes
          .whereType<Map<String, dynamic>>()
          .map((n) => _DiagramNode.fromJson(n))
          .toList();
    } else {
      _nodes = [
        _DiagramNode(
          id: 'entity_a',
          title: 'Primary Entity A',
          subtitle: 'Core source component',
          description: 'The primary entity driving the relationship in ${widget.topic}.',
          example: 'Source Table / Left Operand',
          color: AppColors.tealPrimary,
          bgColor: AppColors.tealLight,
          borderColor: AppColors.tealBorder,
          icon: Icons.table_chart_rounded,
        ),
        _DiagramNode(
          id: 'entity_b',
          title: 'Related Entity B',
          subtitle: 'Linked target component',
          description: 'The secondary entity connected via foreign keys or shared attributes.',
          example: 'Target Table / Right Operand',
          color: AppColors.purplePrimary,
          bgColor: AppColors.purpleLight,
          borderColor: AppColors.purpleBorder,
          icon: Icons.view_column_rounded,
        ),
        _DiagramNode(
          id: 'intersection',
          title: 'Joined Result / Interaction',
          subtitle: 'Matching records and relationship overlap',
          description: 'The intersection and matched relationships established between entities.',
          example: 'Matched result rows where A.key == B.key',
          color: AppColors.greenPrimary,
          bgColor: AppColors.greenLight,
          borderColor: AppColors.greenBorder,
          icon: Icons.join_inner_rounded,
        ),
      ];
    }

    _selectedNode = _nodes.isNotEmpty ? _nodes.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final activeMode = _modes.isNotEmpty ? _modes[_selectedModeIndex] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Main Interactive Diagram Canvas Card
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
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.tealLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.tealBorder),
                    ),
                    child: const Icon(Icons.schema_rounded, size: 20, color: AppColors.tealPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _subtitle,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Mode Switcher (e.g. SQL JOIN Types: INNER, LEFT, RIGHT, FULL)
              if (_modes.length > 1) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: List.generate(_modes.length, (idx) {
                      final m = _modes[idx];
                      final isSelected = idx == _selectedModeIndex;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedModeIndex = idx;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.tealPrimary : AppColors.surfaceSecondary,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.tealPrimary : AppColors.cardBorder,
                              ),
                            ),
                            child: Text(
                              m.label,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? AppColors.textLight : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Mode Description Banner
              if (activeMode != null && activeMode.description.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.tealPrimary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          activeMode.description,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // Interactive Diagram Nodes Grid / Flow
              _buildDiagramVisual(activeMode),
              const SizedBox(height: 18),

              // Selected Node Detail Inspector
              if (_selectedNode != null) _buildNodeInspector(_selectedNode!),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 2. "Why this works" Card
        _buildWhyThisWorksCard(),
      ],
    );
  }

  Widget _buildDiagramVisual(_DiagramModeOption? activeMode) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _nodes.map((node) {
              final isSelected = _selectedNode?.id == node.id;
              final isHighlighted = activeMode?.highlightedRegion == 'all' ||
                  activeMode?.highlightedRegion == node.id ||
                  (activeMode?.highlightedRegion == 'intersection' && node.id == 'intersection');

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedNode = node;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: 140,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? node.bgColor : (isHighlighted ? node.bgColor.withValues(alpha: 0.5) : AppColors.surface),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? node.color : (isHighlighted ? node.borderColor : AppColors.cardBorder),
                        width: isSelected ? 2.0 : 1.2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: node.color.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.surface : node.bgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(node.icon, size: 20, color: node.color),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          node.title,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? node.color : AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          node.subtitle,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
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

  Widget _buildNodeInspector(_DiagramNode node) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: node.bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: node.borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(node.icon, size: 18, color: node.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  node.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: node.color,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: node.borderColor),
                ),
                child: const Text(
                  'Inspecting',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            node.description,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          if (node.example.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: node.borderColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.code_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Example: ${node.example}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
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

class _DiagramModeOption {
  final String id;
  final String label;
  final String description;
  final String highlightedRegion;

  const _DiagramModeOption({
    required this.id,
    required this.label,
    required this.description,
    this.highlightedRegion = 'all',
  });

  factory _DiagramModeOption.fromJson(Map<String, dynamic> json) {
    return _DiagramModeOption(
      id: json['id'] as String? ?? 'mode',
      label: json['label'] as String? ?? 'Mode',
      description: json['description'] as String? ?? '',
      highlightedRegion: json['highlighted_region'] as String? ?? 'all',
    );
  }
}

class _DiagramNode {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String example;
  final Color color;
  final Color bgColor;
  final Color borderColor;
  final IconData icon;

  const _DiagramNode({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.example,
    required this.color,
    required this.bgColor,
    required this.borderColor,
    required this.icon,
  });

  factory _DiagramNode.fromJson(Map<String, dynamic> json) {
    final colorStr = (json['color'] as String? ?? '').toLowerCase();
    Color color = AppColors.tealPrimary;
    Color bgColor = AppColors.tealLight;
    Color borderColor = AppColors.tealBorder;

    if (colorStr.contains('purple')) {
      color = AppColors.purplePrimary;
      bgColor = AppColors.purpleLight;
      borderColor = AppColors.purpleBorder;
    } else if (colorStr.contains('orange')) {
      color = AppColors.orangePrimary;
      bgColor = AppColors.orangeLight;
      borderColor = AppColors.orangeBorder;
    } else if (colorStr.contains('green')) {
      color = AppColors.greenPrimary;
      bgColor = AppColors.greenLight;
      borderColor = AppColors.greenBorder;
    } else if (colorStr.contains('coral') || colorStr.contains('red')) {
      color = AppColors.coralPrimary;
      bgColor = AppColors.coralLight;
      borderColor = AppColors.coralBorder;
    } else if (colorStr.contains('blue')) {
      color = AppColors.bluePrimary;
      bgColor = AppColors.blueLight;
      borderColor = AppColors.blueBorder;
    }

    return _DiagramNode(
      id: json['id'] as String? ?? 'node',
      title: json['title'] as String? ?? 'Node',
      subtitle: json['subtitle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      example: json['example'] as String? ?? '',
      color: color,
      bgColor: bgColor,
      borderColor: borderColor,
      icon: Icons.hub_rounded,
    );
  }
}
