import 'package:flutter/material.dart';
import '../../material_input/models/material_analysis_models.dart';
import 'algorithm_visualization.dart';
import 'concept_map_visualization.dart';
import 'guided_chat_visualizer.dart';
import 'interactive_diagram_visualization.dart';
import 'process_visualization.dart';
import 'simulation_visualization.dart';
import 'step_visualization.dart';

/// Reusable Visualization Router/Factory Widget for LearnX STREAM.
///
/// Dynamically routes to one of the pedagogical visualization components:
/// - `algorithm` / `interactive_visualization` -> AlgorithmVisualization (dynamic arrays, pointers, search/sort)
/// - `process` / `workflow` -> ProcessVisualization (multi-stage cycles, protocols, transitions)
/// - `diagram` / `interactive_diagram` -> InteractiveDiagramVisualization (SQL JOINs, anatomy, system diagrams)
/// - `concept_map` -> ConceptMapVisualization (OOP pillars, hierarchies, taxonomic trees)
/// - `simulation` -> SimulationVisualization (physics formulas, reactive circuits, math models)
/// - `step_by_step` -> StepVisualization (sequential stage breakdowns)
/// - `guided_chat` -> GuidedChatVisualizer (interactive Socratic discovery)
///
/// Error Handling:
/// - Falls back safely to `guided_chat` if an unsupported visualization type is provided.
/// - Renders gracefully if visualization data is empty or corrupted without crashing.
class VisualizationRenderer extends StatelessWidget {
  final MaterialAnalysisResponse analysis;
  final String? overrideMode;

  const VisualizationRenderer({
    super.key,
    required this.analysis,
    this.overrideMode,
  });

  bool _isTopic(List<String> keywords) {
    final lower = analysis.topic.toLowerCase();
    return keywords.any((k) => lower.contains(k));
  }

  @override
  Widget build(BuildContext context) {
    final effectiveType = _resolveEffectiveType();

    switch (effectiveType) {
      case 'process':
      case 'workflow':
        return ProcessVisualization(
          topic: analysis.topic,
          visualizationData: analysis.visualizationData,
        );

      case 'diagram':
      case 'interactive_diagram':
        return InteractiveDiagramVisualization(
          topic: analysis.topic,
          visualizationData: analysis.visualizationData,
        );

      case 'concept_map':
        return ConceptMapVisualization(
          topic: analysis.topic,
          visualizationData: analysis.visualizationData,
        );

      case 'simulation':
        return SimulationVisualization(
          topic: analysis.topic,
          visualizationData: analysis.visualizationData,
        );

      case 'step_by_step':
        return StepVisualization(
          topic: analysis.topic,
          visualizationData: analysis.visualizationData,
        );

      case 'algorithm':
      case 'interactive_visualization':
      case 'dynamic_visualization':
      case 'binary_search':
        // If the topic is clearly a process/circuit/concept, route appropriately
        if (_isTopic(['ohm', 'circuit', 'voltage', 'resistance', 'current', 'physics'])) {
          return SimulationVisualization(
            topic: analysis.topic,
            visualizationData: analysis.visualizationData,
          );
        } else if (_isTopic(['join', 'sql', 'heart', 'cardiovascular', 'anatomy'])) {
          return InteractiveDiagramVisualization(
            topic: analysis.topic,
            visualizationData: analysis.visualizationData,
          );
        } else if (_isTopic(['tcp', 'handshake', 'photosynthesis', 'calvin', 'mitosis'])) {
          return ProcessVisualization(
            topic: analysis.topic,
            visualizationData: analysis.visualizationData,
          );
        } else if (_isTopic(['oop', 'object oriented', 'class', 'inheritance'])) {
          return ConceptMapVisualization(
            topic: analysis.topic,
            visualizationData: analysis.visualizationData,
          );
        }
        return AlgorithmVisualization(
          topic: analysis.topic,
          visualizationData: analysis.visualizationData,
        );

      case 'guided_chat':
        return GuidedChatVisualizer(
          topic: analysis.topic,
          visualizationData: analysis.visualizationData,
        );

      default:
        return GuidedChatVisualizer(
          topic: analysis.topic,
          visualizationData: analysis.visualizationData,
        );
    }
  }

  String _resolveEffectiveType() {
    if (overrideMode != null && overrideMode!.isNotEmpty) {
      return _normalizeType(overrideMode!);
    }
    if (analysis.recommendedVisualization.isNotEmpty) {
      return _normalizeType(analysis.recommendedVisualization);
    }
    return _normalizeType(analysis.visualizationType);
  }

  static String _normalizeType(String rawType) {
    final t = rawType.toLowerCase().trim().replaceAll('-', '_').replaceAll(' ', '_');
    if (t == 'process' || t == 'workflow') {
      return 'process';
    } else if (t == 'diagram' || t == 'interactive_diagram') {
      return 'interactive_diagram';
    } else if (t == 'concept_map' || t == 'conceptmap') {
      return 'concept_map';
    } else if (t == 'simulation') {
      return 'simulation';
    } else if (t == 'step_by_step' || t == 'stepbystep') {
      return 'step_by_step';
    } else if (t == 'algorithm' ||
        t == 'interactive_visualization' ||
        t == 'dynamic_visualization' ||
        t == 'binary_search' ||
        t == 'visualization' ||
        t == 'visualexplanation' ||
        t == 'visual_explanation') {
      return 'algorithm';
    } else if (t == 'guided_chat' || t == 'guidedchat') {
      return 'guided_chat';
    }
    return 'guided_chat'; // Safe fallback
  }

  /// Helper to get user-friendly display name for a mode/type
  static String getDisplayName(String type) {
    final norm = _normalizeType(type);
    switch (norm) {
      case 'process':
        return 'Process Workflow';
      case 'interactive_diagram':
        return 'Interactive Diagram';
      case 'concept_map':
        return 'Concept Map';
      case 'simulation':
        return 'Interactive Simulation';
      case 'step_by_step':
        return 'Step-by-Step';
      case 'algorithm':
        return 'Visual Explanation';
      case 'guided_chat':
        return 'Guided Chat';
      default:
        return 'Visual Explanation';
    }
  }
}

