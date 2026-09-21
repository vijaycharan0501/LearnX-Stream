import 'package:flutter/material.dart';
import 'simulation_visualizer.dart';

/// Legacy alias / wrapper pointing to SimulationVisualizer
class SimpleSimulationView extends StatelessWidget {
  final String topic;
  final Map<String, dynamic>? visualizationData;

  const SimpleSimulationView({
    super.key,
    required this.topic,
    this.visualizationData,
  });

  @override
  Widget build(BuildContext context) {
    return SimulationVisualizer(
      topic: topic,
      visualizationData: visualizationData,
    );
  }
}
