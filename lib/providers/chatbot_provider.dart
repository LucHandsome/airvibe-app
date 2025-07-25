// lib/providers/chatbot_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AirVibe/models/chatbot.dart';
import 'package:AirVibe/services/chatbot_service.dart';

// Provider tự động tạo session khi được gọi
final autoInitChatSessionProvider = FutureProvider<ChatSession>((ref) async {
  return await ChatbotService.initializeChatSession();
});

// Provider cho chat session hiện tại (chỉ dùng khi cần manually control)
final chatSessionProvider = StateNotifierProvider<ChatSessionNotifier, AsyncValue<ChatSession?>>((ref) {
  return ChatSessionNotifier();
});

// Provider cho danh sách tin nhắn
final chatMessagesProvider = StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
  return ChatMessagesNotifier();
});

// Provider cho trạng thái đang gửi tin nhắn
final isTypingProvider = StateProvider<bool>((ref) => false);

class ChatSessionNotifier extends StateNotifier<AsyncValue<ChatSession?>> {
  ChatSessionNotifier() : super(const AsyncValue.data(null));

  Future<void> createNewSession() async {
    state = const AsyncValue.loading();
    try {
      final session = await ChatbotService.initializeChatSession();
      state = AsyncValue.data(session);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void clearSession() {
    state = const AsyncValue.data(null);
  }
}

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier() : super([]);

  void addUserMessage(String message) {
    final userMessage = ChatMessage.userMessage(message);
    state = [...state, userMessage];
  }

  void addBotResponse(String response, List<String> suggestedQuestions) {
    if (state.isNotEmpty) {
      final lastMessage = state.last;
      if (lastMessage.isUser) {
        final botMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: response,
          isUser: false,
          timestamp: DateTime.now(),
          suggestedQuestions: suggestedQuestions,
        );
        state = [...state, botMessage];
      }
    }
  }

  void loadChatHistory(List<ChatMessage> history) {
    // Chuyển đổi lịch sử thành format hiển thị (user message + bot response)
    List<ChatMessage> formattedMessages = [];
    
    for (final historyItem in history.reversed) {
      // Thêm tin nhắn của user
      formattedMessages.add(ChatMessage.userMessage(historyItem.message));
      
      // Thêm phản hồi của bot
      if (historyItem.response != null) {
        formattedMessages.add(ChatMessage(
          id: historyItem.id,
          message: historyItem.response!,
          isUser: false,
          timestamp: historyItem.timestamp,
        ));
      }
    }
    
    state = formattedMessages;
  }

  void clearMessages() {
    state = [];
  }

  Future<void> sendMessage(String sessionId, String message) async {
    try {
      addUserMessage(message);
      final response = await ChatbotService.sendMessage(sessionId, message);
      addBotResponse(response.response, response.suggestedQuestions);
    } catch (e) {
      addBotResponse('Xin lỗi, tôi gặp sự cố kỹ thuật. Vui lòng thử lại sau.', []);
    }
  }
}