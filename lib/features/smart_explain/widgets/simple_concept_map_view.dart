import 'package:flutter/material.dart';
import 'concept_map_visualizer.dart';

/// Legacy alias / wrapper pointing to ConceptMapVisualizer
class SimpleConceptMapView extends StatelessWidget {
  final String topic;
  final Map<String, dynamic>? visualizationData;

  const SimpleConceptMapView({
    super.key,
    required this.topic,
    this.visualizationData,
  });

  @override
  Widget build(BuildContext context) {
    return ConceptMapVisualizer(
      topic: topic,
      visualizationData: visualizationData,
    );
  }
}
