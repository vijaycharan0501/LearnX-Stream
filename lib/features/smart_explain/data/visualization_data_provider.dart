import '../models/visual_explanation_models.dart';

/// Reusable Visualization Data Provider & Factory for LearnX STREAM.
///
/// Decouples visualization data generation and state definitions from UI rendering widgets.
/// Supplies generic [Visualization] and [VisualizationStep] models across all supported
/// visualization types:
/// - [VisualizationType.visualExplanation] (e.g. Binary Search array states, search & sort)
/// - [VisualizationType.stepByStep] (e.g. sequential stages)
/// - [VisualizationType.conceptMap] (e.g. OOP pillars, hierarchies)
/// - [VisualizationType.simulation] (e.g. Ohm's Law variables, equations)
/// - [VisualizationType.workflow] (e.g. TCP Handshake, Photosynthesis)
/// - [VisualizationType.guidedChat] (e.g. Socratic discovery)
class VisualizationDataProvider {
  VisualizationDataProvider._();

  /// Canonical Binary Search visualization data
  /// Uses [VisualizationType.visualExplanation]
  static Visualization getBinarySearchVisualization({
    List<int>? array,
    int? target,
    String topic = 'Binary Search',
  }) {
    final arr = array ?? [10, 20, 30, 40, 50, 60, 70];
    final tgt = target ?? 60;

    // STEP 1:
    // low = 0, mid = 3, high = 6
    // elements: 10, 20, 30, 40, 50, 60, 70
    // highlight: 40
    // comparison: 60 > 40
    // action: Search RIGHT HALF
    final step1 = VisualizationStep(
      stepNumber: 1,
      totalSteps: 3,
      title: 'STEP 1 — FIND THE MIDDLE',
      description: 'Compare Target $tgt with Middle 40.',
      elements: arr,
      highlightedElements: [40],
      activeElements: arr,
      activeIndices: const [0, 1, 2, 3, 4, 5, 6],
      eliminatedElements: const [],
      eliminatedIndices: const [],
      lowIndex: 0,
      midIndex: 3,
      highIndex: 6,
      lowValue: 10,
      midValue: 40,
      highValue: 70,
      targetValue: tgt,
      comparison: '$tgt > 40',
      comparisonLeft: 'Target $tgt',
      comparisonOperator: '>',
      comparisonRight: 'Middle 40',
      action: 'Search RIGHT HALF',
      actionDirection: 'Search RIGHT HALF →',
      actionExplanation: 'Left half [10, 20, 30, 40] is eliminated.',
      isFound: false,
    );

    // STEP 2:
    // active elements: 50, 60, 70
    // eliminated elements: 10, 20, 30, 40
    // low = 4, mid = 5, high = 6
    // highlight: 60
    // comparison: 60 = 60
    // result: TARGET FOUND
    final step2 = VisualizationStep(
      stepNumber: 2,
      totalSteps: 3,
      title: 'STEP 2 — CHECK THE NEW MIDDLE',
      description: 'Target $tgt matches Middle element 60 at index 5.',
      elements: arr,
      highlightedElements: [60],
      activeElements: const [50, 60, 70],
      activeIndices: const [4, 5, 6],
      eliminatedElements: const [10, 20, 30, 40],
      eliminatedIndices: const [0, 1, 2, 3],
      lowIndex: 4,
      midIndex: 5,
      highIndex: 6,
      lowValue: 50,
      midValue: 60,
      highValue: 70,
      targetValue: tgt,
      comparison: '$tgt = 60',
      comparisonLeft: 'Target $tgt',
      comparisonOperator: '==',
      comparisonRight: 'Middle 60',
      action: 'TARGET FOUND',
      actionDirection: '✓ TARGET FOUND',
      actionExplanation: 'Target $tgt is equal to middle element 60 at index 5. Search succeeded!',
      result: 'TARGET FOUND',
      isFound: true,
      foundIndex: 5,
    );

    // STEP 3:
    // [ 7 elements ]
    //        ↓
    // [ 3 elements ]
    //        ↓
    // [ 1 element ]
    //        ↓
    // [ FOUND ]
    // Text: "Each comparison eliminates about half of the remaining search area."
    final step3 = VisualizationStep(
      stepNumber: 3,
      totalSteps: 3,
      title: 'STEP 3 — UNDERSTAND THE IDEA',
      description: 'Binary Search eliminates half the remaining elements with each comparison.',
      elements: arr,
      highlightedElements: [60],
      targetValue: tgt,
      isFound: true,
      foundIndex: 5,
      isWhyStep: true,
      isIdeaStep: true,
      shortExplanation: 'Each comparison eliminates about half of the remaining search area.',
      summaryBlocks: const ['7 elements', '3 elements', '1 element', 'FOUND'],
      action: 'Logarithmic O(log N) Efficiency',
      actionDirection: 'Logarithmic O(log N) Efficiency',
      actionExplanation: 'Each comparison eliminates about half of the remaining search area.',
      result: 'FOUND',
    );

    return Visualization(
      topic: topic,
      type: VisualizationType.visualExplanation,
      title: topic,
      subtitle: "Let's understand it visually.",
      target: tgt,
      elements: arr,
      steps: [step1, step2, step3],
      whyThisWorks: 'Each comparison eliminates about half of the remaining search area.',
    );
  }

  /// Dynamic algorithm computation engine for arbitrary arrays & targets
  static Visualization computeAlgorithmVisualization({
    required List<int> array,
    required int target,
    String topic = 'Binary Search',
  }) {
    return Visualization.computeBinarySearch(
      array: array,
      target: target,
      topic: topic,
    );
  }

  /// Resolves or constructs a generic [Visualization] for any topic and desired type.
  static Visualization getVisualizationForTopic({
    required String topic,
    VisualizationType type = VisualizationType.visualExplanation,
    Map<String, dynamic>? customData,
  }) {
    if (customData != null && customData.isNotEmpty) {
      return Visualization.fromJson({
        ...customData,
        'topic': topic,
        'type': type.key,
      });
    }

    switch (type) {
      case VisualizationType.visualExplanation:
        return getBinarySearchVisualization(topic: topic);

      case VisualizationType.conceptMap:
        return Visualization(
          topic: topic,
          type: VisualizationType.conceptMap,
          title: '$topic Concept Map',
          subtitle: 'Conceptual pillars & relationships',
          whyThisWorks: 'Concept maps visually organize foundational ideas into clear pillars.',
        );

      case VisualizationType.simulation:
        return Visualization(
          topic: topic,
          type: VisualizationType.simulation,
          title: '$topic Interactive Simulation',
          subtitle: 'Experiment with variables and see real-time changes',
          whyThisWorks: 'Simulations provide immediate interactive feedback on parameter variations.',
        );

      case VisualizationType.workflow:
      case VisualizationType.stepByStep:
        return Visualization(
          topic: topic,
          type: type,
          title: '$topic Workflow',
          subtitle: 'Sequential step-by-step breakdown',
          whyThisWorks: 'Step-by-step breakdowns allow mastering complex processes one stage at a time.',
        );

      case VisualizationType.guidedChat:
        return Visualization(
          topic: topic,
          type: VisualizationType.guidedChat,
          title: '$topic Guided Discovery',
          subtitle: 'Socratic dialogue to test and solidify understanding',
          whyThisWorks: 'Active recall and Socratic questions reinforce concept retention.',
        );
    }
  }
}
