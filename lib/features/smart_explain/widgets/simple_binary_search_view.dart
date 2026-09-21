import 'package:flutter/material.dart';
import 'binary_search_visualizer.dart';

/// Legacy alias / wrapper pointing to the rich BinarySearchVisualizer
class SimpleBinarySearchView extends StatelessWidget {
  final int initialTarget;
  final Map<String, dynamic>? visualizationData;

  const SimpleBinarySearchView({
    super.key,
    this.initialTarget = 60,
    this.visualizationData,
  });

  @override
  Widget build(BuildContext context) {
    return BinarySearchVisualizer(
      topic: 'Binary Search',
      initialTarget: initialTarget,
      visualizationData: visualizationData,
    );
  }
}

