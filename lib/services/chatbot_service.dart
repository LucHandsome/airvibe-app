// lib/services/chatbot_service.dart
import 'package:dio/dio.dart';
import 'package:AirVibe/models/chatbot.dart';
import 'package:AirVibe/services/geolocator.dart';
import 'package:AirVibe/services/auth_service.dart'; // Import AuthService

class ChatbotService {
  static const String baseUrl = 'https://ca92582b6720.ngrok-free.app/api/v1/chatbot';
  
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    ),
  );

  /// Lấy token từ AuthService và cập nhật headers
  static Future<void> _updateAuthHeaders() async {
    try {
      final token = await AuthService.getToken();
      if (token != null && token.isNotEmpty) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
        print('🔑 [DEBUG] Token updated in ChatbotService: ${token.substring(0, 30)}...');
      } else {
        _dio.options.headers.remove('Authorization');
        print('⚠️ [DEBUG] No token found, removed Authorization header');
      }
    } catch (e) {
      print('🚨 [ERROR] Failed to update auth headers: $e');
      _dio.options.headers.remove('Authorization');
    }
  }

  /// Kiểm tra xem user đã đăng nhập chưa
  static Future<bool> _checkAuthStatus() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn) {
        throw Exception('User chưa đăng nhập. Vui lòng đăng nhập trước khi sử dụng chatbot.');
      }
      return true;
    } catch (e) {
      print('🚨 [AUTH ERROR] $e');
      throw e;
    }
  }

  /// Tạo session chat mới
  static Future<ChatSession> createNewSession() async {
    try {
      print('🤖 [DEBUG] Creating new chat session...');
      
      // Kiểm tra auth và cập nhật token
      await _checkAuthStatus();
      await _updateAuthHeaders();
      
      print('🤖 [DEBUG] URL: $baseUrl/session/new');
      print('🤖 [DEBUG] Headers: ${_dio.options.headers}');
      
      final response = await _dio.post('$baseUrl/session/new');
      
      print('🤖 [DEBUG] Response status: ${response.statusCode}');
      print('🤖 [DEBUG] Response data: ${response.data}');
      
      if (response.statusCode == 200 && response.data['success']) {
        print('🤖 [DEBUG] Session created successfully');
        return ChatSession.fromJson(response.data);
      } else {
        print('🤖 [ERROR] Failed to create session: ${response.data}');
        throw Exception('Failed to create chat session: ${response.data}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('🚨 [AUTH ERROR] Token expired or invalid');
        // Thử refresh token
        final refreshResult = await AuthService.refreshToken();
        if (refreshResult['success']) {
          print('🔄 [DEBUG] Token refreshed, retrying...');
          return await createNewSession(); // Retry
        } else {
          throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
        }
      } else {
        print('🤖 [ERROR] Dio error in createNewSession: $e');
        throw Exception('Lỗi kết nối server: ${e.message}');
      }
    } catch (e) {
      print('🤖 [ERROR] Exception in createNewSession: $e');
      throw Exception('Error creating chat session: $e');
    }
  }

  /// Đặt vị trí mặc định cho session
  static Future<bool> setDefaultLocation(String sessionId) async {
    try {
      print('🤖 [DEBUG] Setting default location for session: $sessionId');
      
      // Cập nhật auth headers
      await _updateAuthHeaders();
      
      // Lấy vị trí hiện tại
      final location = await getLocation();
      print('🤖 [DEBUG] Got location: ${location.latitude}, ${location.longitude}');
      
      final body = {
        'location': {
          'coordinates': {
            'lat': location.latitude,
            'lon': location.longitude,
          },
          'country': 'VN',
        },
      };

      print('🤖 [DEBUG] Setting location with body: $body');
      
      final response = await _dio.post(
        '$baseUrl/session/$sessionId/location',
        data: body,
      );

      print('🤖 [DEBUG] Location response: ${response.statusCode} - ${response.data}');

      return response.statusCode == 200 && response.data['success'];
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('🚨 [AUTH ERROR] Token expired in setDefaultLocation');
        final refreshResult = await AuthService.refreshToken();
        if (refreshResult['success']) {
          return await setDefaultLocation(sessionId); // Retry
        }
      }
      print('🤖 [ERROR] Error setting default location: $e');
      return false;
    } catch (e) {
      print('🤖 [ERROR] Error setting default location: $e');
      return false;
    }
  }

  /// Gửi tin nhắn chat
  static Future<ChatResponse> sendMessage(String sessionId, String message) async {
    try {
      // Cập nhật auth headers
      await _updateAuthHeaders();
      
      final body = {
        'message': message,
        'sessionId': sessionId,
      };

      print('💬 [DEBUG] Sending message: $message');
      print('💬 [DEBUG] Session ID: $sessionId');

      final response = await _dio.post(
        '$baseUrl/chat',
        data: body,
      );

      print('💬 [DEBUG] Message response: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200 && response.data['success']) {
        return ChatResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to send message: ${response.data}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('🚨 [AUTH ERROR] Token expired in sendMessage');
        final refreshResult = await AuthService.refreshToken();
        if (refreshResult['success']) {
          return await sendMessage(sessionId, message); // Retry
        } else {
          throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
        }
      } else {
        print('💬 [ERROR] Dio error in sendMessage: $e');
        throw Exception('Lỗi gửi tin nhắn: ${e.message}');
      }
    } catch (e) {
      print('💬 [ERROR] Error sending message: $e');
      throw Exception('Error sending message: $e');
    }
  }

  /// Lấy lịch sử chat
  static Future<ChatHistory> getChatHistory(String sessionId) async {
    try {
      // Cập nhật auth headers
      await _updateAuthHeaders();
      
      final response = await _dio.get('$baseUrl/session/$sessionId/history');

      if (response.statusCode == 200 && response.data['success']) {
        return ChatHistory.fromJson(response.data);
      } else {
        throw Exception('Failed to get chat history: ${response.data}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('🚨 [AUTH ERROR] Token expired in getChatHistory');
        final refreshResult = await AuthService.refreshToken();
        if (refreshResult['success']) {
          return await getChatHistory(sessionId); // Retry
        } else {
          throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
        }
      } else {
        throw Exception('Lỗi lấy lịch sử chat: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error getting chat history: $e');
    }
  }

  /// Khởi tạo session đầy đủ (tạo session + set location)
  static Future<ChatSession> initializeChatSession() async {
    try {
      print('🤖 [DEBUG] Initializing chat session...');
      
      // Kiểm tra auth trước
      await _checkAuthStatus();
      
      // Tạo session mới
      final session = await createNewSession();
      print('🤖 [DEBUG] Session created with ID: ${session.sessionId}');
      
      // Set location mặc định
      final locationSet = await setDefaultLocation(session.sessionId);
      if (locationSet) {
        print('🤖 [DEBUG] Default location set successfully');
      } else {
        print('⚠️ [WARNING] Failed to set default location, but session is still usable');
      }
      
      return session;
    } catch (e) {
      print('🤖 [ERROR] Error initializing chat session: $e');
      throw Exception('Error initializing chat session: $e');
    }
  }

  /// Force update token (useful for debugging)
  static Future<void> forceUpdateToken() async {
    await _updateAuthHeaders();
  }

  /// Get current auth status
  static Future<Map<String, dynamic>> getAuthStatus() async {
    try {
      final token = await AuthService.getToken();
      final isLoggedIn = await AuthService.isLoggedIn();
      
      return {
        'isLoggedIn': isLoggedIn,
        'hasToken': token != null,
        'tokenPreview': token != null ? '${token.substring(0, 10)}...' : null,
      };
    } catch (e) {
      return {
        'isLoggedIn': false,
        'hasToken': false,
        'error': e.toString(),
      };
    }
  }
}