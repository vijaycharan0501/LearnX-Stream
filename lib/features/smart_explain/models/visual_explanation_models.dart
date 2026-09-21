/// Supported Visualization Types across LearnX STREAM's pedagogical engine
enum VisualizationType {
  visualExplanation,
  stepByStep,
  conceptMap,
  simulation,
  workflow,
  guidedChat,
}

extension VisualizationTypeExtension on VisualizationType {
  String get key {
    switch (this) {
      case VisualizationType.visualExplanation:
        return 'visualExplanation';
      case VisualizationType.stepByStep:
        return 'stepByStep';
      case VisualizationType.conceptMap:
        return 'conceptMap';
      case VisualizationType.simulation:
        return 'simulation';
      case VisualizationType.workflow:
        return 'workflow';
      case VisualizationType.guidedChat:
        return 'guidedChat';
    }
  }

  String get displayName {
    switch (this) {
      case VisualizationType.visualExplanation:
        return 'Visual Explanation';
      case VisualizationType.stepByStep:
        return 'Step-by-Step';
      case VisualizationType.conceptMap:
        return 'Concept Map';
      case VisualizationType.simulation:
        return 'Interactive Simulation';
      case VisualizationType.workflow:
        return 'Process Workflow';
      case VisualizationType.guidedChat:
        return 'Guided Chat';
    }
  }

  static VisualizationType fromString(String? val) {
    if (val == null || val.isEmpty) return VisualizationType.visualExplanation;
    final clean = val.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
    if (clean.contains('step')) return VisualizationType.stepByStep;
    if (clean.contains('concept') || clean.contains('map')) return VisualizationType.conceptMap;
    if (clean.contains('simul')) return VisualizationType.simulation;
    if (clean.contains('work') || clean.contains('process')) return VisualizationType.workflow;
    if (clean.contains('chat') || clean.contains('guide')) return VisualizationType.guidedChat;
    return VisualizationType.visualExplanation;
  }
}

/// Primary generic model representing an AI-generated or locally computed visual explanation.
class Visualization {
  final String topic;
  final VisualizationType type;
  final String title;
  final String subtitle;
  final String summary;
  final List<VisualizationStep> steps;
  final List<dynamic> elements;
  final dynamic target;
  final String explanation;
  final String whyThisWorks;
  final List<DiagramRelationshipModel> relationships;
  final Map<String, dynamic> interactions;
  final List<SocraticQuestionModel> questions;
  final List<dynamic> actions;
  final Map<String, dynamic> metadata;

  const Visualization({
    required this.topic,
    this.type = VisualizationType.visualExplanation,
    this.title = '',
    this.subtitle = '',
    this.summary = '',
    this.steps = const [],
    this.elements = const [],
    this.target,
    this.explanation = '',
    this.whyThisWorks = '',
    this.relationships = const [],
    this.interactions = const {},
    this.questions = const [],
    this.actions = const [],
    this.metadata = const {},
  });

  String get visualizationType => type.key;

  factory Visualization.fromJson(Map<String, dynamic> json) {
    final elements = (json['elements'] as List<dynamic>?) ?? (json['items'] as List<dynamic>?) ?? [];
    final target = json['target'] ?? json['target_value'] ?? json['targetValue'];
    final topic = json['topic'] as String? ?? 'Study Concept';
    final typeStr = json['type'] as String? ??
        json['visualization_type'] as String? ??
        json['visualizationType'] as String?;
    final type = VisualizationTypeExtension.fromString(typeStr);

    final rawSteps = json['steps'] as List<dynamic>? ?? [];
    var parsedSteps = rawSteps
        .whereType<Map<String, dynamic>>()
        .map((s) => VisualizationStep.fromJson({
              ...s,
              if (!s.containsKey('elements') || (s['elements'] as List).isEmpty) 'elements': elements,
              if (!s.containsKey('target_value') && target != null) 'target_value': target,
            }))
        .toList();

    // If algorithmic topic or Binary Search has missing steps, compute dynamically
    if (parsedSteps.isEmpty && elements.isNotEmpty && target != null) {
      final intList = elements.map((e) => int.tryParse(e.toString()) ?? 0).toList()..sort();
      final parsedTarget = int.tryParse(target.toString()) ?? 60;
      return computeBinarySearch(
        array: intList,
        target: parsedTarget,
        topic: topic,
      );
    }

    // Ensure Binary Search / step progression always includes Step 3 ("UNDERSTAND THE IDEA") if missing
    if (parsedSteps.isNotEmpty && !parsedSteps.any((s) => s.isIdeaStep || s.isWhyStep)) {
      final totalLen = elements.isNotEmpty ? elements.length : 7;
      final summaryBlocks = <String>[
        '$totalLen elements',
        '${(totalLen - 1) ~/ 2} elements',
        '1 element',
        'FOUND',
      ];

      parsedSteps.add(
        VisualizationStep(
          stepNumber: parsedSteps.length + 1,
          totalSteps: parsedSteps.length + 1,
          title: 'STEP ${parsedSteps.length + 1} — UNDERSTAND THE IDEA',
          description: 'Binary Search eliminates half the remaining elements with each comparison.',
          elements: elements,
          targetValue: target,
          isFound: true,
          isWhyStep: true,
          isIdeaStep: true,
          shortExplanation: 'Each comparison eliminates about half of the remaining search area.',
          summaryBlocks: summaryBlocks,
          linearProgression: [for (int i = totalLen; i >= 1; i--) i],
          binaryProgression: [7, 3, 1],
          action: 'Logarithmic O(log N) Efficiency',
          actionDirection: 'Logarithmic O(log N) Efficiency',
          actionExplanation: 'Each comparison eliminates about half of the remaining search area.',
          result: 'FOUND',
        ),
      );
    }

    // Ensure totalSteps is consistently set to the total step count across all steps
    final totalCount = parsedSteps.length;
    final finalizedSteps = <VisualizationStep>[
      for (int i = 0; i < parsedSteps.length; i++)
        parsedSteps[i].copyWithStepNumberAndTotal(i + 1, totalCount),
    ];

    final rawRelationships = json['relationships'] as List<dynamic>? ?? [];
    final parsedRelationships = rawRelationships
        .whereType<Map<String, dynamic>>()
        .map((r) => DiagramRelationshipModel.fromJson(r))
        .toList();

    final rawQuestions = json['questions'] as List<dynamic>? ?? [];
    final parsedQuestions = rawQuestions
        .whereType<Map<String, dynamic>>()
        .map((q) => SocraticQuestionModel.fromJson(q))
        .toList();

    final keyIdea = json['keyIdea'] as String? ??
        json['key_idea'] as String? ??
        json['why_this_works'] as String? ??
        json['whyThisWorks'] as String? ??
        '';

    final interactionMap = (json['interaction'] as Map<String, dynamic>?) ??
        (json['interactions'] as Map<String, dynamic>?) ??
        {};

    return Visualization(
      topic: topic,
      type: type,
      title: json['title'] as String? ?? (json['topic'] as String? ?? 'Visual Explanation'),
      subtitle: json['subtitle'] as String? ?? "Let's understand it visually.",
      summary: json['summary'] as String? ?? (json['reason'] as String? ?? ''),
      steps: finalizedSteps,
      elements: elements,
      relationships: parsedRelationships,
      interactions: interactionMap,
      explanation: json['explanation'] as String? ?? '',
      questions: parsedQuestions,
      actions: (json['actions'] as List<dynamic>?) ?? [],
      whyThisWorks: keyIdea,
      target: target,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topic': topic,
      'type': type.key,
      'title': title,
      'subtitle': subtitle,
      'visualization_type': visualizationType,
      'summary': summary,
      'steps': steps.map((s) => s.toJson()).toList(),
      'elements': elements,
      'relationships': relationships.map((r) => r.toJson()).toList(),
      'interactions': interactions,
      'explanation': explanation,
      'questions': questions.map((q) => q.toJson()).toList(),
      'actions': actions,
      'why_this_works': whyThisWorks,
      'target': target,
      'metadata': metadata,
    };
  }

  /// Data-driven algorithm engine: computes visual steps for any sorted array and target.
  static Visualization computeBinarySearch({
    required List<int> array,
    required int target,
    String topic = 'Binary Search',
  }) {
    final sortedArray = List<int>.from(array)..sort();
    final steps = <VisualizationStep>[];

    int low = 0;
    int high = sortedArray.length - 1;
    int stepNum = 1;
    bool found = false;
    int? foundIdx;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      final midVal = sortedArray[mid];

      final currentlyEliminated = [
        for (int i = 0; i < sortedArray.length; i++)
          if (i < low || i > high) i
      ];
      final currentActive = [for (int i = low; i <= high; i++) i];
      final activeEls = [for (int i = low; i <= high; i++) sortedArray[i]];
      final eliminatedEls = [
        for (int i = 0; i < sortedArray.length; i++)
          if (i < low || i > high) sortedArray[i]
      ];

      if (midVal == target) {
        found = true;
        foundIdx = mid;
        steps.add(
          VisualizationStep(
            stepNumber: stepNum,
            totalSteps: 0,
            title: stepNum == 1
                ? 'STEP 1 — FIND THE MIDDLE'
                : 'STEP $stepNum — CHECK THE NEW MIDDLE',
            description: 'Target $target matches Middle element $midVal at index $mid.',
            elements: sortedArray,
            highlightedElements: [midVal],
            activeElements: activeEls,
            eliminatedElements: eliminatedEls,
            lowIndex: low,
            midIndex: mid,
            highIndex: high,
            lowValue: sortedArray[low],
            midValue: midVal,
            highValue: sortedArray[high],
            targetValue: target,
            activeIndices: currentActive,
            eliminatedIndices: currentlyEliminated,
            comparison: '$target = $midVal',
            comparisonLeft: 'Target $target',
            comparisonOperator: '==',
            comparisonRight: 'Middle $midVal',
            action: 'TARGET FOUND',
            actionDirection: '✓ TARGET FOUND',
            actionExplanation: 'Target $target is equal to middle element $midVal at index $mid. Search succeeded!',
            result: 'TARGET FOUND',
            isFound: true,
            foundIndex: mid,
          ),
        );
        break;
      } else if (target > midVal) {
        steps.add(
          VisualizationStep(
            stepNumber: stepNum,
            totalSteps: 0,
            title: stepNum == 1 ? 'STEP 1 — FIND THE MIDDLE' : 'STEP $stepNum — CHECK THE NEW MIDDLE',
            description: 'Compare Target $target with Middle $midVal.',
            elements: sortedArray,
            highlightedElements: [midVal],
            activeElements: activeEls,
            eliminatedElements: eliminatedEls,
            lowIndex: low,
            midIndex: mid,
            highIndex: high,
            lowValue: sortedArray[low],
            midValue: midVal,
            highValue: sortedArray[high],
            targetValue: target,
            activeIndices: currentActive,
            eliminatedIndices: currentlyEliminated,
            comparison: '$target > $midVal',
            comparisonLeft: 'Target $target',
            comparisonOperator: '>',
            comparisonRight: 'Middle $midVal',
            action: 'Search RIGHT HALF',
            actionDirection: 'Search RIGHT HALF →',
            actionExplanation: 'Left half ${sortedArray.sublist(low, mid + 1)} is eliminated.',
            isFound: false,
          ),
        );
        low = mid + 1;
      } else {
        steps.add(
          VisualizationStep(
            stepNumber: stepNum,
            totalSteps: 0,
            title: stepNum == 1 ? 'STEP 1 — FIND THE MIDDLE' : 'STEP $stepNum — CHECK THE NEW MIDDLE',
            description: 'Compare Target $target with Middle $midVal.',
            elements: sortedArray,
            highlightedElements: [midVal],
            activeElements: activeEls,
            eliminatedElements: eliminatedEls,
            lowIndex: low,
            midIndex: mid,
            highIndex: high,
            lowValue: sortedArray[low],
            midValue: midVal,
            highValue: sortedArray[high],
            targetValue: target,
            activeIndices: currentActive,
            eliminatedIndices: currentlyEliminated,
            comparison: '$target < $midVal',
            comparisonLeft: 'Target $target',
            comparisonOperator: '<',
            comparisonRight: 'Middle $midVal',
            action: 'Search LEFT HALF',
            actionDirection: '← Search LEFT HALF',
            actionExplanation: 'Right half ${sortedArray.sublist(mid, high + 1)} is eliminated.',
            isFound: false,
          ),
        );
        high = mid - 1;
      }
      stepNum++;
    }

    if (!found) {
      steps.add(
        VisualizationStep(
          stepNumber: stepNum++,
          totalSteps: 0,
          title: 'TARGET NOT FOUND',
          description: 'Search completed without finding $target.',
          elements: sortedArray,
          targetValue: target,
          activeIndices: [],
          activeElements: [],
          eliminatedIndices: [for (int i = 0; i < sortedArray.length; i++) i],
          eliminatedElements: sortedArray,
          comparison: '$target ≠ Not in array',
          comparisonLeft: 'Target $target',
          comparisonOperator: '≠',
          comparisonRight: 'Not in array',
          action: 'Search Complete',
          actionDirection: 'Search Complete',
          actionExplanation: '$target does not exist in this sorted array.',
          result: 'NOT FOUND',
          isFound: false,
        ),
      );
    }

    // Step 3: "UNDERSTAND THE IDEA"
    final totalLen = sortedArray.length;
    final summaryBlocks = <String>[];
    int curr = totalLen;
    summaryBlocks.add('$curr elements');
    while (curr > 1) {
      curr = (curr - 1) ~/ 2;
      if (curr >= 1) {
        summaryBlocks.add(curr == 1 ? '1 element' : '$curr elements');
      }
    }
    summaryBlocks.add(found ? 'FOUND' : 'NOT FOUND');

    steps.add(
      VisualizationStep(
        stepNumber: 3,
        totalSteps: 3,
        title: 'STEP 3 — UNDERSTAND THE IDEA',
        description: 'Binary Search eliminates half the remaining elements with each comparison.',
        elements: sortedArray,
        targetValue: target,
        isFound: found,
        foundIndex: foundIdx,
        isWhyStep: true,
        isIdeaStep: true,
        shortExplanation:
            'Each comparison eliminates about half of the remaining search area.',
        summaryBlocks: summaryBlocks,
        linearProgression: [for (int i = totalLen; i >= 1; i--) i],
        binaryProgression: [7, 3, 1],
        action: 'Logarithmic O(log N) Efficiency',
        actionDirection: 'Logarithmic O(log N) Efficiency',
        actionExplanation: 'Each comparison eliminates about half of the remaining search area.',
        result: found ? 'FOUND' : 'NOT FOUND',
      ),
    );

    final totalCount = steps.length;
    final finalizedSteps = <VisualizationStep>[
      for (int i = 0; i < steps.length; i++)
        steps[i].copyWithStepNumberAndTotal(i + 1, totalCount),
    ];

    return Visualization(
      topic: topic,
      type: VisualizationType.visualExplanation,
      title: topic,
      subtitle: "Let's understand it visually.",
      target: target,
      elements: sortedArray,
      steps: finalizedSteps,
      whyThisWorks: 'Each comparison eliminates about half of the remaining search area.',
    );
  }
}

/// Typed aliases for backward compatibility
typedef VisualExplanationModel = Visualization;
typedef VisualExplanation = Visualization;

/// Generic Step in a Process, Algorithm, or Protocol Visualization
class VisualizationStep {
  final int stepNumber;
  final int totalSteps;
  final String title;
  final String description;
  final List<dynamic> elements;
  final List<dynamic> highlightedElements;
  final List<dynamic> eliminatedElements;
  final List<dynamic> activeElements;
  final List<int> activeIndices;
  final List<int> eliminatedIndices;
  final String comparison;
  final String comparisonLeft;
  final String comparisonOperator;
  final String comparisonRight;
  final String action;
  final String actionDirection;
  final String actionExplanation;
  final String? result;
  final String visualAction;
  final bool isFound;
  final int? foundIndex;
  final bool isWhyStep;
  final bool isIdeaStep;
  final String? shortExplanation;
  final List<String> summaryBlocks;
  final int? lowIndex;
  final int? midIndex;
  final int? highIndex;
  final dynamic lowValue;
  final dynamic midValue;
  final dynamic highValue;
  final dynamic targetValue;
  final List<dynamic>? linearProgression;
  final List<dynamic>? binaryProgression;
  final Map<String, dynamic> metadata;

  const VisualizationStep({
    required this.stepNumber,
    required this.totalSteps,
    required this.title,
    this.description = '',
    required this.elements,
    this.highlightedElements = const [],
    this.eliminatedElements = const [],
    this.activeElements = const [],
    this.activeIndices = const [],
    this.eliminatedIndices = const [],
    this.comparison = '',
    this.comparisonLeft = '',
    this.comparisonOperator = '',
    this.comparisonRight = '',
    this.action = '',
    this.actionDirection = '',
    this.actionExplanation = '',
    this.result,
    this.visualAction = '',
    this.isFound = false,
    this.foundIndex,
    this.isWhyStep = false,
    this.isIdeaStep = false,
    this.shortExplanation,
    this.summaryBlocks = const [],
    this.lowIndex,
    this.midIndex,
    this.highIndex,
    this.lowValue,
    this.midValue,
    this.highValue,
    this.targetValue,
    this.linearProgression,
    this.binaryProgression,
    this.metadata = const {},
  });

  VisualizationStep copyWithStepNumberAndTotal(int step, int total) {
    return VisualizationStep(
      stepNumber: step,
      totalSteps: total,
      title: title,
      description: description,
      elements: elements,
      highlightedElements: highlightedElements,
      eliminatedElements: eliminatedElements,
      activeElements: activeElements,
      activeIndices: activeIndices,
      eliminatedIndices: eliminatedIndices,
      comparison: comparison,
      comparisonLeft: comparisonLeft,
      comparisonOperator: comparisonOperator,
      comparisonRight: comparisonRight,
      action: action,
      actionDirection: actionDirection,
      actionExplanation: actionExplanation,
      result: result,
      visualAction: visualAction,
      isFound: isFound,
      foundIndex: foundIndex,
      isWhyStep: isWhyStep,
      isIdeaStep: isIdeaStep,
      shortExplanation: shortExplanation,
      summaryBlocks: summaryBlocks,
      lowIndex: lowIndex,
      midIndex: midIndex,
      highIndex: highIndex,
      lowValue: lowValue,
      midValue: midValue,
      highValue: highValue,
      targetValue: targetValue,
      linearProgression: linearProgression,
      binaryProgression: binaryProgression,
      metadata: metadata,
    );
  }

  VisualizationStep copyWithTotalSteps(int total) {
    return copyWithStepNumberAndTotal(stepNumber, total);
  }

  factory VisualizationStep.fromJson(Map<String, dynamic> json) {
    final stepNum = (json['step_number'] as num?)?.toInt() ??
        (json['stepNumber'] as num?)?.toInt() ??
        (json['step'] as num?)?.toInt() ??
        1;
    final totalSteps = (json['total_steps'] as num?)?.toInt() ??
        (json['totalSteps'] as num?)?.toInt() ??
        3;

    final elements = (json['elements'] as List<dynamic>?) ?? (json['items'] as List<dynamic>?) ?? [];
    final highlightedRaw = json['highlighted_elements'] ??
        json['highlightedElements'] ??
        json['highlight'] ??
        json['highlighted'];
    final List<dynamic> highlighted = highlightedRaw is List
        ? highlightedRaw
        : (highlightedRaw != null ? [highlightedRaw] : []);

    final lowIdx = (json['low_index'] as num?)?.toInt() ?? (json['lowIndex'] as num?)?.toInt() ?? (json['low'] as num?)?.toInt();
    final midIdx = (json['mid_index'] as num?)?.toInt() ?? (json['midIndex'] as num?)?.toInt() ?? (json['mid'] as num?)?.toInt();
    final highIdx = (json['high_index'] as num?)?.toInt() ?? (json['highIndex'] as num?)?.toInt() ?? (json['high'] as num?)?.toInt();
    final foundIdx = (json['found_index'] as num?)?.toInt() ?? (json['foundIndex'] as num?)?.toInt();

    final lowVal = json['low_value'] ?? json['low_val'] ?? json['lowValue'] ?? (lowIdx != null && lowIdx >= 0 && lowIdx < elements.length ? elements[lowIdx] : null);
    final midVal = json['mid_value'] ?? json['middle_val'] ?? json['middleValue'] ?? json['midVal'] ?? (midIdx != null && midIdx >= 0 && midIdx < elements.length ? elements[midIdx] : null);
    final highVal = json['high_value'] ?? json['high_val'] ?? json['highValue'] ?? (highIdx != null && highIdx >= 0 && highIdx < elements.length ? elements[highIdx] : null);
    final targetVal = json['target_value'] ?? json['target_val'] ?? json['targetValue'] ?? json['target'];

    final active = (json['active_indices'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ??
        (json['active'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ??
        (lowIdx != null && highIdx != null ? [for (int i = lowIdx; i <= highIdx; i++) i] : []);

    final eliminated = (json['eliminated_indices'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ??
        (json['discarded_indices'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ??
        (json['eliminated'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ??
        (lowIdx != null && highIdx != null && elements.isNotEmpty
            ? [for (int i = 0; i < elements.length; i++) if (i < lowIdx || i > highIdx) i]
            : []);

    final activeEls = (json['active_elements'] as List<dynamic>?) ??
        (json['activeElements'] as List<dynamic>?) ??
        (active.isNotEmpty && elements.isNotEmpty ? [for (int idx in active) if (idx >= 0 && idx < elements.length) elements[idx]] : []);

    final eliminatedEls = (json['eliminated_elements'] as List<dynamic>?) ??
        (json['eliminatedElements'] as List<dynamic>?) ??
        (eliminated.isNotEmpty && elements.isNotEmpty ? [for (int idx in eliminated) if (idx >= 0 && idx < elements.length) elements[idx]] : []);

    final actionDir = json['action_direction'] as String? ?? json['action'] as String? ?? '';
    final actionText = json['action'] as String? ?? actionDir;
    final bool explicitFound = (json['is_found'] as bool?) ?? (json['isFound'] as bool?) ?? false;
    final bool isFound = explicitFound ||
        (foundIdx != null) ||
        (actionDir.toUpperCase().contains('FOUND')) ||
        (actionText.toUpperCase().contains('FOUND')) ||
        (midVal != null && targetVal != null && midVal.toString() == targetVal.toString());

    final resultVal = json['result'] as String? ?? (isFound ? 'TARGET FOUND' : null);

    final comparisonStr = json['comparison'] as String? ??
        (targetVal != null && midVal != null
            ? '$targetVal ${isFound ? '=' : ((num.tryParse(targetVal.toString()) ?? 0) > (num.tryParse(midVal.toString()) ?? 0) ? '>' : '<')} $midVal'
            : '');

    return VisualizationStep(
      stepNumber: stepNum,
      totalSteps: totalSteps,
      title: json['title'] as String? ?? 'Step $stepNum',
      description: json['description'] as String? ?? '',
      elements: elements,
      highlightedElements: highlighted.isNotEmpty ? highlighted : (midVal != null ? [midVal] : []),
      eliminatedElements: eliminatedEls,
      activeElements: activeEls,
      activeIndices: active,
      eliminatedIndices: eliminated,
      comparison: comparisonStr,
      comparisonLeft: json['comparison_left'] as String? ?? (targetVal != null ? 'Target $targetVal' : ''),
      comparisonOperator: json['comparison_operator'] as String? ??
          (isFound ? '==' : (targetVal != null && midVal != null ? ((num.tryParse(targetVal.toString()) ?? 0) > (num.tryParse(midVal.toString()) ?? 0) ? '>' : '<') : '')),
      comparisonRight: json['comparison_right'] as String? ?? (midVal != null ? 'Middle $midVal' : ''),
      action: actionText.isNotEmpty ? actionText : (isFound ? 'TARGET FOUND' : 'Search RIGHT HALF'),
      actionDirection: isFound ? '✓ TARGET FOUND' : (actionDir.isNotEmpty ? actionDir : 'Search RIGHT HALF →'),
      actionExplanation: json['action_explanation'] as String? ?? '',
      result: resultVal,
      visualAction: json['visual_action'] as String? ?? actionDir,
      isFound: isFound,
      foundIndex: foundIdx ?? (isFound ? midIdx : null),
      isWhyStep: json['is_why_step'] as bool? ?? false,
      isIdeaStep: json['is_idea_step'] as bool? ?? (json['is_why_step'] as bool? ?? false),
      shortExplanation: json['short_explanation'] as String?,
      summaryBlocks: (json['summary_blocks'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      lowIndex: lowIdx,
      midIndex: midIdx,
      highIndex: highIdx,
      lowValue: lowVal,
      midValue: midVal,
      highValue: highVal,
      targetValue: targetVal,
      linearProgression: json['linear_progression'] as List<dynamic>?,
      binaryProgression: json['binary_progression'] as List<dynamic>?,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step_number': stepNumber,
      'total_steps': totalSteps,
      'title': title,
      'description': description,
      'elements': elements,
      'highlighted_elements': highlightedElements,
      'eliminated_elements': eliminatedElements,
      'active_elements': activeElements,
      'active_indices': activeIndices,
      'eliminated_indices': eliminatedIndices,
      'comparison': comparison,
      'comparison_left': comparisonLeft,
      'comparison_operator': comparisonOperator,
      'comparison_right': comparisonRight,
      'action': action,
      'action_direction': actionDirection,
      'action_explanation': actionExplanation,
      'result': result,
      'visual_action': visualAction,
      'is_found': isFound,
      'found_index': foundIndex,
      'is_why_step': isWhyStep,
      'is_idea_step': isIdeaStep,
      'short_explanation': shortExplanation,
      'summary_blocks': summaryBlocks,
      'low_index': lowIndex,
      'mid_index': midIndex,
      'high_index': highIndex,
      'low_value': lowValue,
      'mid_value': midValue,
      'high_value': highValue,
      'target_value': targetValue,
      'linear_progression': linearProgression,
      'binary_progression': binaryProgression,
      'metadata': metadata,
    };
  }
}

/// Typed alias for backward compatibility
typedef VisualStepModel = VisualizationStep;

/// Generic Relationship / Connection in an Interactive Diagram (e.g. SQL JOIN, Circuit, Architecture)
class DiagramRelationshipModel {
  final String sourceId;
  final String targetId;
  final String type;
  final String label;
  final String description;

  const DiagramRelationshipModel({
    required this.sourceId,
    required this.targetId,
    this.type = 'connects',
    this.label = '',
    this.description = '',
  });

  factory DiagramRelationshipModel.fromJson(Map<String, dynamic> json) {
    return DiagramRelationshipModel(
      sourceId: json['source_id'] as String? ?? json['source'] as String? ?? '',
      targetId: json['target_id'] as String? ?? json['target'] as String? ?? '',
      type: json['type'] as String? ?? 'connects',
      label: json['label'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source_id': sourceId,
      'target_id': targetId,
      'type': type,
      'label': label,
      'description': description,
    };
  }
}

/// Generic Socratic Question in Guided Chat
class SocraticQuestionModel {
  final int stepNumber;
  final String title;
  final String explanation;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String feedback;

  const SocraticQuestionModel({
    required this.stepNumber,
    required this.title,
    required this.explanation,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.feedback,
  });

  factory SocraticQuestionModel.fromJson(Map<String, dynamic> json) {
    return SocraticQuestionModel(
      stepNumber: (json['step_number'] as num?)?.toInt() ?? 1,
      title: json['title'] as String? ?? 'Checkpoint',
      explanation: json['explanation'] as String? ?? '',
      question: json['question'] as String? ?? 'What is the key takeaway?',
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      correctIndex: (json['correct_index'] as num?)?.toInt() ?? 0,
      feedback: json['feedback'] as String? ?? 'Great understanding!',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step_number': stepNumber,
      'title': title,
      'explanation': explanation,
      'question': question,
      'options': options,
      'correct_index': correctIndex,
      'feedback': feedback,
    };
  }
}
