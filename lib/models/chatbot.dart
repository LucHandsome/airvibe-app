// lib/models/chatbot.dart
import 'package:flutter/foundation.dart' show immutable;

@immutable
class ChatSession {
  final String sessionId;
  final String userId;
  final String welcomeMessage;
  final List<String> suggestedQuestions;
  final List<String> capabilities;

  const ChatSession({
    required this.sessionId,
    required this.userId,
    required this.welcomeMessage,
    required this.suggestedQuestions,
    required this.capabilities,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return ChatSession(
      sessionId: data['sessionId'] ?? '',
      userId: data['userId'] ?? '',
      welcomeMessage: data['welcomeMessage'] ?? '',
      suggestedQuestions: List<String>.from(data['suggestedQuestions'] ?? []),
      capabilities: List<String>.from(data['capabilities'] ?? []),
    );
  }
}

@immutable
class ChatMessage {
  final String id;
  final String message;
  final String? response;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? suggestedQuestions;

  const ChatMessage({
    required this.id,
    required this.message,
    this.response,
    required this.isUser,
    required this.timestamp,
    this.suggestedQuestions,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      message: json['message'] ?? '',
      response: json['response'],
      isUser: false,
      timestamp: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Factory cho tin nhắn của user
  factory ChatMessage.userMessage(String message) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  // Factory cho tin nhắn phản hồi từ bot
  ChatMessage copyWithBotResponse(String response, List<String>? suggestions) {
    return ChatMessage(
      id: id,
      message: message,
      response: response,
      isUser: false,
      timestamp: timestamp,
      suggestedQuestions: suggestions,
    );
  }
}

@immutable
class ChatResponse {
  final String response;
  final String intent;
  final double confidence;
  final List<String> suggestedQuestions;
  final String sessionId;

  const ChatResponse({
    required this.response,
    required this.intent,
    required this.confidence,
    required this.suggestedQuestions,
    required this.sessionId,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return ChatResponse(
      response: data['response'] ?? '',
      intent: data['intent'] ?? '',
      confidence: data['confidence']?.toDouble() ?? 0.0,
      suggestedQuestions: List<String>.from(data['suggestedQuestions'] ?? []),
      sessionId: data['sessionId'] ?? '',
    );
  }
}

@immutable
class ChatHistory {
  final List<ChatMessage> messages;
  final String sessionId;
  final String userId;
  final int total;
  final bool hasMore;

  const ChatHistory({
    required this.messages,
    required this.sessionId,
    required this.userId,
    required this.total,
    required this.hasMore,
  });

  factory ChatHistory.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return ChatHistory(
      messages: (data['chatHistory'] as List)
          .map((item) => ChatMessage.fromJson(item))
          .toList(),
      sessionId: data['sessionId'] ?? '',
      userId: data['userId'] ?? '',
      total: data['total'] ?? 0,
      hasMore: data['hasMore'] ?? false,
    );
  }
}