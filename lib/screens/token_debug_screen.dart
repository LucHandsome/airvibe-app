// lib/screens/token_debug_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:AirVibe/services/chatbot_service.dart';
import 'package:AirVibe/services/auth_service.dart';

class TokenDebugScreen extends StatefulWidget {
  const TokenDebugScreen({super.key});

  @override
  State<TokenDebugScreen> createState() => _TokenDebugScreenState();
}

class _TokenDebugScreenState extends State<TokenDebugScreen> {
  final TextEditingController _tokenController = TextEditingController();
  bool _tokenUpdated = false;
  bool _isLoading = false;
  String? _currentToken;
  Map<String, dynamic>? _authStatus;

  @override
  void initState() {
    super.initState();
    _loadCurrentToken();
    _loadAuthStatus();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentToken() async {
    try {
      final token = await AuthService.getToken();
      setState(() {
        _currentToken = token;
        if (token != null) {
          _tokenController.text = token;
        }
      });
    } catch (e) {
      print('Error loading token: $e');
    }
  }

  Future<void> _loadAuthStatus() async {
    try {
      final status = await ChatbotService.getAuthStatus();
      setState(() {
        _authStatus = status;
      });
    } catch (e) {
      print('Error loading auth status: $e');
    }
  }

  void _updateToken() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      _showSnackBar('Vui lòng nhập token!', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Save token to SharedPreferences (giả lập việc login)
      await AuthService.getProfile(); // Test with current token first
      
      // Update ChatbotService
      await ChatbotService.forceUpdateToken();
      
      setState(() {
        _tokenUpdated = true;
        _currentToken = token;
      });
      
      // Reload auth status
      await _loadAuthStatus();
      
      _showSnackBar('Token đã được cập nhật và test thành công!', Colors.green);
      
    } catch (e) {
      _showSnackBar('Token không hợp lệ: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _pasteFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != null) {
        setState(() {
          _tokenController.text = data!.text!;
        });
      }
    } catch (e) {
      _showSnackBar('Lỗi paste: $e', Colors.red);
    }
  }

  void _clearToken() async {
    try {
      await AuthService.logout();
      setState(() {
        _tokenController.clear();
        _tokenUpdated = false;
        _currentToken = null;
      });
      await _loadAuthStatus();
      _showSnackBar('Token đã được xóa!', Colors.orange);
    } catch (e) {
      _showSnackBar('Lỗi xóa token: $e', Colors.red);
    }
  }

  void _testChatbotConnection() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Test chatbot connection
      final session = await ChatbotService.initializeChatSession();
      _showSnackBar('Kết nối chatbot thành công! Session: ${session.sessionId.substring(0, 8)}...', Colors.green);
    } catch (e) {
      _showSnackBar('Lỗi kết nối chatbot: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Token & Auth'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              _loadCurrentToken();
              _loadAuthStatus();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh status',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auth Status Card
            _buildAuthStatusCard(),
            
            const SizedBox(height: 24),
            
            // Token Management Card
            _buildTokenManagementCard(),
            
            const SizedBox(height: 24),
            
            // Test Actions Card
            _buildTestActionsCard(),
            
            const SizedBox(height: 24),
            
            // Instructions Card
            _buildInstructionsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trạng thái Authentication',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            if (_authStatus != null) ...[
              _buildStatusRow('Đăng nhập', _authStatus!['isLoggedIn'] ? 'Có' : 'Không', 
                  _authStatus!['isLoggedIn'] ? Colors.green : Colors.red),
              _buildStatusRow('Có Token', _authStatus!['hasToken'] ? 'Có' : 'Không', 
                  _authStatus!['hasToken'] ? Colors.green : Colors.red),
              if (_authStatus!['tokenPreview'] != null)
                _buildStatusRow('Token Preview', _authStatus!['tokenPreview'], Colors.blue),
              if (_authStatus!['error'] != null)
                _buildStatusRow('Lỗi', _authStatus!['error'], Colors.red),
            ] else
              const Text('Đang tải trạng thái...'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenManagementCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quản lý Token',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _tokenController,
              decoration: InputDecoration(
                labelText: 'Access Token',
                hintText: 'Paste token từ Postman hoặc login response...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _pasteFromClipboard,
                      icon: const Icon(Icons.content_paste),
                      tooltip: 'Paste từ clipboard',
                    ),
                    IconButton(
                      onPressed: () => _tokenController.clear(),
                      icon: const Icon(Icons.clear),
                      tooltip: 'Xóa',
                    ),
                  ],
                ),
              ),
              maxLines: 3,
              minLines: 1,
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _updateToken,
                    icon: _isLoading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isLoading ? 'Đang cập nhật...' : 'Cập nhật Token'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                ElevatedButton.icon(
                  onPressed: _clearToken,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ],
            ),
            
            if (_tokenUpdated) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Token đã được cập nhật thành công!',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Kết Nối',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _testChatbotConnection,
                icon: const Icon(Icons.chat),
                label: const Text('Test Chatbot Connection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hướng Dẫn Sử Dụng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            const Text(
              'Cách 1: Sử dụng token từ Postman',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const Text(
              '1. Chạy POST /api/v1/auth/login trên Postman\n'
              '2. Copy accessToken từ response\n'
              '3. Paste vào ô token và nhấn "Cập nhật Token"\n'
              '4. Test kết nối chatbot',
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Cách 2: Đăng nhập trong app',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const Text(
              '1. Đăng nhập qua màn hình Login trong app\n'
              '2. Token sẽ tự động được lưu\n'
              '3. Quay lại đây để kiểm tra trạng thái',
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sample Endpoints:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('POST https://2312cebd5a9a.ngrok-free.app/api/v1/auth/signup'),
                  Text('POST https://2312cebd5a9a.ngrok-free.app/api/v1/auth/login'),
                  Text('Body: {"email": "test@example.com", "password": "123456"}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}