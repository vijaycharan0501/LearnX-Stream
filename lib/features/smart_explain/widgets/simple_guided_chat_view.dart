import 'package:flutter/material.dart';
import 'guided_chat_visualizer.dart';

/// Legacy alias / wrapper pointing to GuidedChatVisualizer
class SimpleGuidedChatView extends StatelessWidget {
  final String topic;
  final Map<String, dynamic>? visualizationData;

  const SimpleGuidedChatView({
    super.key,
    required this.topic,
    this.visualizationData,
  });

  @override
  Widget build(BuildContext context) {
    return GuidedChatVisualizer(
      topic: topic,
      visualizationData: visualizationData,
    );
  }
}
