import 'package:flutter/material.dart';
import 'step_by_step_visualizer.dart';

/// Legacy alias / wrapper pointing to StepByStepVisualizer
class SimpleStepByStepView extends StatelessWidget {
  final String topic;
  final Map<String, dynamic>? visualizationData;

  const SimpleStepByStepView({
    super.key,
    required this.topic,
    this.visualizationData,
  });

  @override
  Widget build(BuildContext context) {
    return StepByStepVisualizer(
      topic: topic,
      visualizationData: visualizationData,
    );
  }
}
