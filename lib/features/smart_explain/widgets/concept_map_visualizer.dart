import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'topic_visualization_helper.dart';

/// Rich Interactive Concept Map for Hierarchies and Object-Oriented Structures.
///
/// Features:
/// 1. Hierarchical visual tree with level-based nodes and visual branch connectors.
/// 2. Interactive node selection displaying rich definition, role, and practical real-world examples.
/// 3. Dynamic layout supporting arbitrary concept maps (OOP, DBMS, Networking, Systems).
/// 4. "Try it yourself" interactive explorer encouraging students to inspect all foundational pillars.
class ConceptMapVisualizer extends StatefulWidget {
  final String topic;
  final Map<String, dynamic>? visualizationData;

  const ConceptMapVisualizer({
    super.key,
    required this.topic,
    this.visualizationData,
  });

  @override
  State<ConceptMapVisualizer> createState() => _ConceptMapVisualizerState();
}

class _ConceptMapVisualizerState extends State<ConceptMapVisualizer> {
  late String _rootTitle;
  late String _rootSubtitle;
  late List<_ConceptNode> _nodes;
  late String _whyWorksText;
  late _ConceptNode? _selectedNode;

  @override
  void initState() {
    super.initState();
    _initFromData();
  }

  @override
  void didUpdateWidget(covariant ConceptMapVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visualizationData != widget.visualizationData ||
        oldWidget.topic != widget.topic) {
      _initFromData();
    }
  }

  void _initFromData() {
    final rawData = widget.visualizationData;
    final bool hasValidNodes = rawData != null &&
        rawData['nodes'] is List &&
        (rawData['nodes'] as List).isNotEmpty;

    final data = hasValidNodes
        ? rawData
        : TopicVisualizationHelper.getConceptMapData(widget.topic, rawData, null);

    final root = data['root_node'] as Map<String, dynamic>?;
    _rootTitle = root?['title'] as String? ??
        (widget.topic.isNotEmpty ? widget.topic : 'Study Concept');
    _rootSubtitle = root?['subtitle'] as String? ?? 'Conceptual Structure & Hierarchy';

    final rawNodes = data['nodes'] as List<dynamic>?;
    if (rawNodes != null && rawNodes.isNotEmpty) {
      _nodes = rawNodes.map((n) {
        if (n is Map<String, dynamic>) {
          return _ConceptNode(
            id: n['id']?.toString() ?? '',
            title: n['title']?.toString() ?? 'Concept',
            definition: n['definition']?.toString() ?? (n['subtitle']?.toString() ?? 'Core conceptual building block.'),
            example: n['example']?.toString() ?? '',
            parentId: n['parent_id']?.toString() ?? 'root',
            level: (n['level'] as num?)?.toInt() ?? 1,
            iconName: n['icon']?.toString(),
          );
        }
        return _ConceptNode(
          id: n.toString(),
          title: n.toString(),
          definition: 'Associated conceptual building block.',
          example: '',
          parentId: 'root',
          level: 1,
        );
      }).toList();
    } else {
      _nodes = [];
    }

    _whyWorksText = data['why_this_works'] as String? ??
        'Concept maps organize complex architectures into clear parent-child relationships, showing where properties come from.';

    // Default select first child node
    _selectedNode = _nodes.isNotEmpty ? _nodes.first : null;
  }

  IconData _resolveIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'blueprint':
      case 'class':
        return Icons.architecture_rounded;
      case 'instance':
      case 'object':
        return Icons.widgets_rounded;
      case 'hierarchy':
      case 'inheritance':
        return Icons.account_tree_rounded;
      case 'lock':
      case 'encapsulation':
        return Icons.lock_outline_rounded;
      case 'shapes':
      case 'polymorphism':
        return Icons.auto_awesome_motion_rounded;
      case 'visibility_off':
      case 'abstraction':
        return Icons.visibility_off_rounded;
      default:
        return Icons.subdirectory_arrow_right_rounded;
    }
  }

  Color _getNodeColor(int index) {
    final colors = [
      AppColors.tealPrimary,
      AppColors.orangePrimary,
      AppColors.purplePrimary,
      AppColors.coralPrimary,
      AppColors.bluePrimary,
    ];
    return colors[index % colors.length];
  }

  Color _getNodeBgColor(int index) {
    final bgColors = [
      AppColors.tealLight,
      AppColors.orangeLight,
      AppColors.purpleLight,
      AppColors.coralLight,
      AppColors.blueLight,
    ];
    return bgColors[index % bgColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Interactive Hierarchy Visualizer Canvas
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
              // Header instruction
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      'Interactive Concept Hierarchy',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.purpleLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Tap nodes to inspect',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.purplePrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Visual Root Node
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.purpleLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.purpleBorder, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.hub_rounded, size: 18, color: AppColors.purplePrimary),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _rootTitle,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.purplePrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_rootSubtitle.isNotEmpty)
                              Text(
                                _rootSubtitle,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Connector Arrow Down
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Icon(Icons.arrow_downward_rounded, color: AppColors.textMuted, size: 20),
                ),
              ),

              // Grid / Wrap of Child Hierarchy Nodes
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: List.generate(_nodes.length, (index) {
                  final node = _nodes[index];
                  final isSelected = _selectedNode?.id == node.id;
                  final color = _getNodeColor(index);
                  final bgColor = _getNodeBgColor(index);

                  return InkWell(
                    onTap: () => setState(() => _selectedNode = node),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? bgColor : AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? color : AppColors.cardBorder,
                          width: isSelected ? 2.0 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_resolveIcon(node.iconName), size: 16, color: color),
                          const SizedBox(width: 6),
                          Text(
                            node.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                              color: isSelected ? color : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Active Node Details Card (Definition + Practical Example)
              if (_selectedNode != null) _buildSelectedNodeCard(_selectedNode!),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 2. "Why this works" Card
        _buildWhyThisWorksCard(),
        const SizedBox(height: 18),

        // 3. "Try it yourself" Interactive Pillar Explorer
        _buildTryItYourselfCard(),
      ],
    );
  }

  Widget _buildSelectedNodeCard(_ConceptNode node) {
    final index = _nodes.indexWhere((n) => n.id == node.id);
    final color = _getNodeColor(index >= 0 ? index : 0);
    final bgColor = _getNodeBgColor(index >= 0 ? index : 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(_resolveIcon(node.iconName), size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  node.title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            node.definition,
            style: const TextStyle(
              fontSize: 13,
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
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.code_rounded, size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Example: ${node.example}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color,
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
              Icon(Icons.explore_rounded, size: 18, color: AppColors.tealPrimary),
              SizedBox(width: 8),
              Text(
                'Explore all pillars',
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
            'Tap each building block to see how they connect together:',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _nodes.map((node) {
              final isSelected = _selectedNode?.id == node.id;
              return InkWell(
                onTap: () => setState(() => _selectedNode = node),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.tealPrimary : AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.tealPrimary : AppColors.cardBorder,
                    ),
                  ),
                  child: Text(
                    node.title,
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

class _ConceptNode {
  final String id;
  final String title;
  final String definition;
  final String example;
  final String parentId;
  final int level;
  final String? iconName;

  _ConceptNode({
    required this.id,
    required this.title,
    required this.definition,
    required this.example,
    required this.parentId,
    required this.level,
    this.iconName,
  });
}
