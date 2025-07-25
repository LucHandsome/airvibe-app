// lib/screens/chat_screen.dart
import 'package:AirVibe/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AirVibe/providers/chatbot_provider.dart';
import 'package:AirVibe/models/chatbot.dart';
import 'package:AirVibe/views/gradient_container.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _sessionId;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _sessionId == null) return;

    _messageController.clear();
    ref.read(isTypingProvider.notifier).state = true;

    await ref.read(chatMessagesProvider.notifier).sendMessage(_sessionId!, message);
    
    ref.read(isTypingProvider.notifier).state = false;
    
    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _sendSuggestedQuestion(String question) {
    _messageController.text = question;
    _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    final chatSession = ref.watch(autoInitChatSessionProvider);
    final messages = ref.watch(chatMessagesProvider);
    final isTyping = ref.watch(isTypingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Trợ lý thời tiết',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(), // Nút thoát
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(chatMessagesProvider.notifier).clearMessages();
              ref.invalidate(autoInitChatSessionProvider);
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới cuộc trò chuyện',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'clear':
                  ref.read(chatMessagesProvider.notifier).clearMessages();
                  ref.invalidate(autoInitChatSessionProvider);
                  break;
                case 'close':
                  ref.read(chatMessagesProvider.notifier).clearMessages();
                  ref.invalidate(autoInitChatSessionProvider);
                  Navigator.of(context).pop();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 8),
                    Text('Xóa cuộc trò chuyện'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'close',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app),
                    SizedBox(width: 8),
                    Text('Thoát'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      // Thay GradientContainer bằng Container với gradient
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A), // Blue-900
              Color(0xFF3B82F6), // Blue-500
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100), // Space for AppBar
            
            Expanded(
              child: chatSession.when(
                data: (session) {
                  _sessionId = session.sessionId;
                  
                  if (messages.isEmpty) {
                    return _buildWelcomeScreen(session);
                  }
                  return _buildChatContent(messages, session.suggestedQuestions, isTyping);
                },
                loading: () => const Center(
                  child: LoadingWidget(),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Lỗi kết nối: ${error.toString()}',
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(autoInitChatSessionProvider),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Message input - không padding
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen(ChatSession session) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16), // Chỉ horizontal padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.smart_toy, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'AI Trợ lý thời tiết',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  session.welcomeMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          const Text(
            'Câu hỏi gợi ý:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 12),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: session.suggestedQuestions.length,
            itemBuilder: (context, index) {
              final question = session.suggestedQuestions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => _sendSuggestedQuestion(question),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16), // Tăng padding
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            question,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14, // Tăng font size
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white54,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20), // Bottom spacing
        ],
      ),
    );
  }

  Widget _buildChatContent(List<ChatMessage> messages, List<String> suggestions, bool isTyping) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: messages.length + (isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == messages.length && isTyping) {
                return _buildTypingIndicator();
              }
              
              final message = messages[index];
              return _buildMessageBubble(message);
            },
          ),
        ),
        
        // Suggested questions (chỉ hiển thị khi có và không đang typing)
        if (messages.isNotEmpty && 
            messages.last.suggestedQuestions != null && 
            messages.last.suggestedQuestions!.isNotEmpty &&
            !isTyping)
          _buildSuggestedQuestions(messages.last.suggestedQuestions!),
          
        const SizedBox(height: 8), // Spacing trước message input
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: message.isUser 
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.white.withOpacity(0.2),
                ),
              ),
              child: Text(
                message.message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.blue, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Text(
              'Đang soạn tin...',
              style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedQuestions(List<String> suggestions) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated( // Thay ListView.builder bằng ListView.separated
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return InkWell(
            onTap: () => _sendSuggestedQuestion(suggestion),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Center( // Thêm Center
                child: Text(
                  suggestion,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 1, // Giới hạn 1 line
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      width: double.infinity, // Full width
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), // Giảm padding top
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2))),
      ),
      child: SafeArea( // Thêm SafeArea cho bottom
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: _sendMessage,
              borderRadius: BorderRadius.circular(25),
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}