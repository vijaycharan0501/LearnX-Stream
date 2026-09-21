import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Individual concept extracted by AI
class ConceptItem {
  final String name;
  final String type;
  final String importance; // "high", "medium", "low"

  const ConceptItem({
    required this.name,
    required this.type,
    required this.importance,
  });

  factory ConceptItem.fromJson(Map<String, dynamic> json) {
    return ConceptItem(
      name: json['name'] as String? ?? 'Unnamed Concept',
      type: json['type'] as String? ?? 'concept',
      importance: (json['importance'] as String? ?? 'medium').toLowerCase(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'importance': importance,
    };
  }

  /// Human-friendly display label for concept type (e.g. "algorithmic_paradigm" -> "Algorithmic Paradigm")
  String get formattedType {
    if (type.isEmpty) return 'General Concept';
    return type
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  Color get importanceColor {
    switch (importance) {
      case 'high':
        return AppColors.coralPrimary;
      case 'medium':
        return AppColors.orangePrimary;
      case 'low':
      default:
        return AppColors.tealPrimary;
    }
  }

  Color get importanceBgColor {
    switch (importance) {
      case 'high':
        return AppColors.coralLight;
      case 'medium':
        return AppColors.orangeLight;
      case 'low':
      default:
        return AppColors.tealLight;
    }
  }

  Color get importanceBorderColor {
    switch (importance) {
      case 'high':
        return AppColors.coralBorder;
      case 'medium':
        return AppColors.orangeBorder;
      case 'low':
      default:
        return AppColors.tealBorder;
    }
  }
}

/// AI-recommended learning format and pedagogical rationale
class RecommendedRepresentation {
  final String type; // "visualExplanation" | "workflow" | "conceptMap" | "simulation" | "stepByStep" | "guidedChat"
  final String reason;

  const RecommendedRepresentation({
    required this.type,
    required this.reason,
  });

  factory RecommendedRepresentation.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'] as String? ?? 'visualExplanation';
    return RecommendedRepresentation(
      type: _normalizeType(rawType),
      reason: json['reason'] as String? ?? 'Best interactive format suited for this topic.',
    );
  }

  static String _normalizeType(String val) {
    final clean = val.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
    if (clean.contains('simul')) return 'simulation';
    if (clean.contains('concept') || clean.contains('map')) return 'conceptMap';
    if (clean.contains('work') || clean.contains('process')) return 'workflow';
    if (clean.contains('step')) return 'stepByStep';
    if (clean.contains('chat') || clean.contains('guide')) return 'guidedChat';
    if (clean.contains('diag') || clean.contains('interactive_diagram')) return 'interactive_diagram';
    return 'visualExplanation';
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'reason': reason,
    };
  }

  String get displayName {
    switch (type) {
      case 'simulation':
        return 'Interactive Simulation';
      case 'stepByStep':
      case 'step_by_step':
        return 'Step-by-Step Visualization';
      case 'workflow':
      case 'process':
        return 'Workflow Sequence';
      case 'conceptMap':
      case 'concept_map':
        return 'Interactive Concept Map';
      case 'interactive_diagram':
        return 'Interactive Component Diagram';
      case 'guidedChat':
      case 'guided_chat':
        return 'Guided Socratic Exploration';
      case 'visualExplanation':
      case 'interactive_visualization':
      case 'algorithm':
      default:
        return 'Visual Interactive Learning';
    }
  }

  IconData get icon {
    switch (type) {
      case 'simulation':
        return Icons.science_rounded;
      case 'stepByStep':
      case 'step_by_step':
        return Icons.format_list_numbered_rounded;
      case 'workflow':
      case 'process':
        return Icons.schema_rounded;
      case 'conceptMap':
      case 'concept_map':
        return Icons.account_tree_rounded;
      case 'interactive_diagram':
        return Icons.layers_rounded;
      case 'guidedChat':
      case 'guided_chat':
        return Icons.forum_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  Color get accentColor {
    switch (type) {
      case 'simulation':
        return AppColors.tealPrimary;
      case 'stepByStep':
      case 'step_by_step':
        return AppColors.bluePrimary;
      case 'workflow':
      case 'process':
        return AppColors.orangePrimary;
      case 'conceptMap':
      case 'concept_map':
        return AppColors.purplePrimary;
      case 'interactive_diagram':
        return AppColors.tealPrimary;
      case 'guidedChat':
      case 'guided_chat':
        return AppColors.bluePrimary;
      default:
        return AppColors.tealPrimary;
    }
  }

  Color get accentBgColor {
    switch (type) {
      case 'simulation':
        return AppColors.tealLight;
      case 'stepByStep':
      case 'step_by_step':
        return AppColors.blueLight;
      case 'workflow':
      case 'process':
        return AppColors.orangeLight;
      case 'conceptMap':
      case 'concept_map':
        return AppColors.purpleLight;
      case 'interactive_diagram':
        return AppColors.tealLight;
      case 'guidedChat':
      case 'guided_chat':
        return AppColors.blueLight;
      default:
        return AppColors.tealLight;
    }
  }

  Color get accentBorderColor {
    switch (type) {
      case 'simulation':
        return AppColors.tealBorder;
      case 'stepByStep':
      case 'step_by_step':
        return AppColors.blueBorder;
      case 'workflow':
      case 'process':
        return AppColors.orangeBorder;
      case 'conceptMap':
      case 'concept_map':
        return AppColors.purpleBorder;
      case 'interactive_diagram':
        return AppColors.tealBorder;
      case 'guidedChat':
      case 'guided_chat':
        return AppColors.blueBorder;
      default:
        return AppColors.tealBorder;
    }
  }
}

class StepItem {
  final int stepNumber;
  final String title;
  final String description;
  final List<dynamic> visualElements;
  final List<dynamic> highlightedElements;
  final List<dynamic> activeElements;
  final String action;
  final String result;
  final String whatIsHappening;

  const StepItem({
    this.stepNumber = 1,
    this.title = '',
    this.description = '',
    this.visualElements = const [],
    this.highlightedElements = const [],
    this.activeElements = const [],
    this.action = '',
    this.result = '',
    this.whatIsHappening = '',
  });

  factory StepItem.fromJson(Map<String, dynamic> json) {
    return StepItem(
      stepNumber: json['stepNumber'] as int? ?? json['step_number'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? json['what_is_happening'] as String? ?? '',
      visualElements: (json['visualElements'] as List<dynamic>?) ??
          (json['visual_elements'] as List<dynamic>?) ??
          (json['elements'] as List<dynamic>?) ??
          const [],
      highlightedElements: (json['highlightedElements'] as List<dynamic>?) ??
          (json['highlighted_elements'] as List<dynamic>?) ??
          const [],
      activeElements: (json['activeElements'] as List<dynamic>?) ??
          (json['active_elements'] as List<dynamic>?) ??
          const [],
      action: json['action'] as String? ?? json['action_direction'] as String? ?? '',
      result: json['result'] as String? ?? json['action_explanation'] as String? ?? '',
      whatIsHappening: json['whatIsHappening'] as String? ??
          json['what_is_happening'] as String? ??
          json['description'] as String? ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'title': title,
      'description': description,
      'visualElements': visualElements,
      'highlightedElements': highlightedElements,
      'activeElements': activeElements,
      'action': action,
      'result': result,
      'whatIsHappening': whatIsHappening,
    };
  }
}

/// Individual flexible educational section
class AnswerSection {
  final String heading;
  final String content;
  final String type; // "text", "example", "mechanism", "formula", "comparison"

  const AnswerSection({
    required this.heading,
    required this.content,
    this.type = 'text',
  });

  factory AnswerSection.fromJson(Map<String, dynamic> json) {
    return AnswerSection(
      heading: json['heading'] as String? ?? 'Explanation',
      content: json['content'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heading': heading,
      'content': content,
      'type': type,
    };
  }
}

/// Flexible, natural ChatGPT/Gemini-style educational answer payload
class AnswerPayload {
  final String title;
  final String summary;
  final List<AnswerSection> sections;

  const AnswerPayload({
    required this.title,
    required this.summary,
    this.sections = const [],
  });

  factory AnswerPayload.fromJson(Map<String, dynamic> json) {
    final rawSections = json['sections'];
    final List<AnswerSection> parsedSections = [];
    if (rawSections is List) {
      for (final item in rawSections) {
        if (item is Map<String, dynamic>) {
          parsedSections.add(AnswerSection.fromJson(item));
        }
      }
    }
    return AnswerPayload(
      title: json['title'] as String? ?? 'Concept Explanation',
      summary: json['summary'] as String? ?? '',
      sections: parsedSections,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'sections': sections.map((s) => s.toJson()).toList(),
    };
  }
}

/// Lightweight Concept Check Question with options & instant pedagogical feedback
class QuickCheck {
  final bool enabled;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  const QuickCheck({
    this.enabled = true,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation = '',
  });

  factory QuickCheck.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final List<String> parsedOptions = [];
    if (rawOptions is List) {
      for (final opt in rawOptions) {
        if (opt != null) {
          parsedOptions.add(opt.toString());
        }
      }
    }
    return QuickCheck(
      enabled: json['enabled'] as bool? ?? true,
      question: json['question'] as String? ?? 'Concept Check Question',
      options: parsedOptions,
      correctAnswer: json['correctAnswer'] as String? ??
          json['correct_answer'] as String? ??
          (parsedOptions.isNotEmpty ? parsedOptions.first : ''),
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }
}

/// Comprehensive AI study material analysis response
class MaterialAnalysisResponse {
  final String topic;
  final String summary;
  final AnswerPayload? answer;
  final String? visualExplanation;
  final String? keyTakeaway;
  final String? conceptOverview;
  final List<StepItem>? steps;
  final String? keyIdea;
  final String? realWorldConnection;
  final QuickCheck? quickCheck;

  final List<ConceptItem> concepts;
  final String difficulty; // "easy" | "medium" | "hard"
  final List<String> prerequisites;
  final RecommendedRepresentation recommendedRepresentation;

  final String visualizationType;
  final Map<String, dynamic> visualizationData;
  final String whyThisWorks;

  final String recommendedVisualization;
  final String reason;
  final Map<String, dynamic> visualization;

  const MaterialAnalysisResponse({
    required this.topic,
    required this.summary,
    this.answer,
    this.visualExplanation,
    this.keyTakeaway,
    this.conceptOverview,
    this.steps,
    this.keyIdea,
    this.realWorldConnection,
    this.quickCheck,
    required this.concepts,
    required this.difficulty,
    required this.prerequisites,
    required this.recommendedRepresentation,
    this.visualizationType = 'visualExplanation',
    this.visualizationData = const {},
    this.whyThisWorks = 'This visual representation breaks down complex logic into intuitive, digestible stages.',
    this.recommendedVisualization = '',
    this.reason = '',
    this.visualization = const {},
  });

  bool get isVisualizationEnabled {
    if (visualization.containsKey('enabled') && visualization['enabled'] == false) {
      return false;
    }
    if (visualizationData.containsKey('enabled') && visualizationData['enabled'] == false) {
      return false;
    }
    return true;
  }

  String get effectiveOverview {
    if (answer != null && answer!.summary.trim().isNotEmpty) {
      return answer!.summary.trim();
    }
    if (conceptOverview != null && conceptOverview!.trim().isNotEmpty) {
      return conceptOverview!.trim();
    }
    return summary;
  }

  String get effectiveKeyIdea {
    if (keyTakeaway != null && keyTakeaway!.trim().isNotEmpty) {
      return keyTakeaway!.trim();
    }
    if (keyIdea != null && keyIdea!.trim().isNotEmpty) {
      return keyIdea!.trim();
    }
    return whyThisWorks;
  }

  String get effectiveVisualExplanation {
    if (visualExplanation != null && visualExplanation!.trim().isNotEmpty) {
      return visualExplanation!.trim();
    }
    return whyThisWorks;
  }

  List<StepItem> get effectiveSteps {
    if (steps != null && steps!.isNotEmpty) {
      return steps!;
    }
    final rawSteps = visualization['steps'] ?? visualizationData['steps'] ?? visualizationData['stages'];
    if (rawSteps is List && rawSteps.isNotEmpty) {
      return rawSteps
          .whereType<Map<String, dynamic>>()
          .map((s) => StepItem.fromJson(s))
          .toList();
    }
    return const [];
  }

  QuickCheck? get effectiveQuickCheck {
    if (quickCheck != null && quickCheck!.enabled && quickCheck!.options.isNotEmpty) {
      return quickCheck;
    }
    final rawQc = visualizationData['quickCheck'] ?? visualizationData['quick_check'];
    if (rawQc is Map<String, dynamic>) {
      final parsed = QuickCheck.fromJson(rawQc);
      if (parsed.enabled && parsed.options.isNotEmpty) {
        return parsed;
      }
    }
    return null;
  }

  factory MaterialAnalysisResponse.fromJson(Map<String, dynamic> json) {
    // Parse concepts list safely
    final rawConcepts = json['concepts'];
    final List<ConceptItem> parsedConcepts = [];
    if (rawConcepts is List) {
      for (final item in rawConcepts) {
        if (item is Map<String, dynamic>) {
          parsedConcepts.add(ConceptItem.fromJson(item));
        }
      }
    }

    // Parse prerequisites safely
    final rawPrereqs = json['prerequisites'];
    final List<String> parsedPrereqs = [];
    if (rawPrereqs is List) {
      for (final p in rawPrereqs) {
        if (p != null) {
          final str = p.toString().trim();
          if (str.isNotEmpty) {
            parsedPrereqs.add(str);
          }
        }
      }
    }

    // Parse steps list safely
    final rawSteps = json['steps'] ?? json['stages'];
    final List<StepItem> parsedSteps = [];
    if (rawSteps is List) {
      for (final item in rawSteps) {
        if (item is Map<String, dynamic>) {
          parsedSteps.add(StepItem.fromJson(item));
        }
      }
    }

    // Parse AnswerPayload
    final rawAnswer = json['answer'];
    final AnswerPayload? parsedAnswer = rawAnswer is Map<String, dynamic>
        ? AnswerPayload.fromJson(rawAnswer)
        : null;

    // Parse QuickCheck safely
    final rawQuickCheck = json['quickCheck'] ?? json['quick_check'];
    final QuickCheck? parsedQuickCheck = rawQuickCheck is Map<String, dynamic>
        ? QuickCheck.fromJson(rawQuickCheck)
        : null;

    // Parse recommended representation
    final rawRep = json['recommended_representation'] ?? json['recommendedRepresentation'];
    final RecommendedRepresentation parsedRep = rawRep is Map<String, dynamic>
        ? RecommendedRepresentation.fromJson(rawRep)
        : const RecommendedRepresentation(
            type: 'step_by_step',
            reason: 'Interactive step-by-step breakdown recommended.',
          );

    // Resolve visualizationType & recommendedVisualization
    final rawVisType = json['visualization_type'] as String? ??
        json['visualizationType'] as String? ??
        (rawRep is Map<String, dynamic> ? rawRep['type'] as String? : null) ??
        json['recommendedVisualization'] as String? ??
        'interactive_visualization';

    final rawRecVis = json['recommendedVisualization'] as String? ??
        json['recommended_visualization'] as String? ??
        rawVisType;
    final normalizedVis = _normalizeType(rawRecVis);

    // Parse visualization data
    final rawVisData = json['visualization'] ?? json['visualization_data'];
    final Map<String, dynamic> parsedVisData = rawVisData is Map<String, dynamic>
        ? Map<String, dynamic>.from(rawVisData)
        : {};

    final reasonStr = json['reason'] as String? ??
        parsedRep.reason;

    final keyTakeawayStr = json['keyTakeaway'] as String? ?? json['key_takeaway'] as String?;
    final keyIdeaStr = keyTakeawayStr ?? (json['keyIdea'] as String? ?? json['key_idea'] as String?);
    final visualExpStr = json['visualExplanation'] as String? ?? json['visual_explanation'] as String?;
    final realWorldStr = json['realWorldConnection'] as String? ?? json['real_world_connection'] as String?;
    final conceptOverviewStr = parsedAnswer?.summary ?? (json['conceptOverview'] as String? ?? json['concept_overview'] as String?);

    final whyWorks = visualExpStr ?? (json['why_this_works'] as String? ??
        keyIdeaStr ??
        (parsedVisData['why_this_works'] as String?) ??
        reasonStr);

    return MaterialAnalysisResponse(
      topic: json['topic'] as String? ?? 'Study Concept',
      summary: json['summary'] as String? ?? parsedAnswer?.summary ?? 'Concept analysis overview.',
      answer: parsedAnswer,
      visualExplanation: visualExpStr,
      keyTakeaway: keyTakeawayStr,
      conceptOverview: conceptOverviewStr,
      steps: parsedSteps.isNotEmpty ? parsedSteps : null,
      keyIdea: keyIdeaStr,
      realWorldConnection: realWorldStr,
      quickCheck: parsedQuickCheck,
      concepts: parsedConcepts,
      difficulty: (json['difficulty'] as String? ?? 'medium').toLowerCase().trim(),
      prerequisites: parsedPrereqs,
      recommendedRepresentation: parsedRep,
      visualizationType: rawVisType,
      visualizationData: parsedVisData,
      whyThisWorks: whyWorks,
      recommendedVisualization: normalizedVis,
      reason: reasonStr,
      visualization: parsedVisData,
    );
  }

  static String _normalizeType(String val) {
    final clean = val.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
    if (clean.contains('simul')) return 'simulation';
    if (clean.contains('concept') || clean.contains('map')) return 'conceptMap';
    if (clean.contains('work') || clean.contains('process')) return 'workflow';
    if (clean.contains('step')) return 'stepByStep';
    if (clean.contains('chat') || clean.contains('guide')) return 'guidedChat';
    if (clean.contains('diag') || clean.contains('interactive_diagram')) return 'interactive_diagram';
    return 'visualExplanation';
  }

  Map<String, dynamic> toJson() {
    return {
      'topic': topic,
      'summary': summary,
      'answer': answer?.toJson(),
      'visualExplanation': visualExplanation,
      'keyTakeaway': keyTakeaway,
      'conceptOverview': conceptOverview,
      'steps': steps?.map((s) => s.toJson()).toList(),
      'keyIdea': keyIdea,
      'realWorldConnection': realWorldConnection,
      'quickCheck': quickCheck?.toJson(),
      'concepts': concepts.map((c) => c.toJson()).toList(),
      'difficulty': difficulty,
      'prerequisites': prerequisites,
      'recommended_representation': recommendedRepresentation.toJson(),
      'recommendedRepresentation': recommendedRepresentation.type,
      'visualization_type': visualizationType,
      'visualization_data': visualizationData,
      'why_this_works': whyThisWorks,
      'recommendedVisualization': recommendedVisualization,
      'reason': reason.isNotEmpty ? reason : recommendedRepresentation.reason,
      'visualization': visualization.isNotEmpty ? visualization : visualizationData,
    };
  }

  String get visualizationDisplayName {
    switch (recommendedVisualization) {
      case 'visualExplanation':
      case 'interactive_visualization':
      case 'algorithm':
        return 'Visual Explanation';
      case 'simulation':
        return 'Interactive Simulation';
      case 'conceptMap':
      case 'concept_map':
        return 'Concept Map';
      case 'workflow':
      case 'process':
        return 'Workflow Sequence';
      case 'stepByStep':
      case 'step_by_step':
        return 'Step-by-Step';
      case 'guidedChat':
      case 'guided_chat':
        return 'Guided Chat';
      case 'interactive_diagram':
        return 'Interactive Diagram';
      default:
        return 'Visual Explanation';
    }
  }

  String get formattedDifficulty {
    if (difficulty.isEmpty) return 'Medium';
    return '${difficulty[0].toUpperCase()}${difficulty.substring(1).toLowerCase()}';
  }

  Color get difficultyColor {
    switch (difficulty) {
      case 'easy':
        return AppColors.greenPrimary;
      case 'hard':
        return AppColors.coralPrimary;
      case 'medium':
      default:
        return AppColors.orangePrimary;
    }
  }

  Color get difficultyBgColor {
    switch (difficulty) {
      case 'easy':
        return AppColors.greenLight;
      case 'hard':
        return AppColors.coralLight;
      case 'medium':
      default:
        return AppColors.orangeLight;
    }
  }

  Color get difficultyBorderColor {
    switch (difficulty) {
      case 'easy':
        return AppColors.greenBorder;
      case 'hard':
        return AppColors.coralBorder;
      case 'medium':
      default:
        return AppColors.orangeBorder;
    }
  }
}

/// Convenience alias
typedef MaterialAnalysis = MaterialAnalysisResponse;
