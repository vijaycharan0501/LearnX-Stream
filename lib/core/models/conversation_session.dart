import '../../features/material_input/models/material_analysis_models.dart';

/// Representation of an AI learning exchange in the single workspace
class ChatExchange {
  final String question;
  final MaterialAnalysisResponse analysis;
  final DateTime timestamp;

  const ChatExchange({
    required this.question,
    required this.analysis,
    required this.timestamp,
  });
}

/// Representation of a conversation session with pinned and recent support
class ConversationSession {
  final String id;
  String title;
  bool isPinned;
  DateTime updatedAt;
  final List<ChatExchange> exchanges;
  String? documentName;
  MaterialAnalysisResponse? documentAnalysis;

  ConversationSession({
    required this.id,
    required this.title,
    this.isPinned = false,
    required this.updatedAt,
    List<ChatExchange>? exchanges,
    this.documentName,
    this.documentAnalysis,
  }) : exchanges = exchanges ?? [];
}
