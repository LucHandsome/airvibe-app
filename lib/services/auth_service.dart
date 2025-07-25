  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import 'package:shared_preferences/shared_preferences.dart';

  class AuthService {
    // Base URL - đặt đúng URL backend của bạn
    static const String _baseUrl = 'https://ca92582b6720.ngrok-free.app/api/v1/auth';
    
    // Headers chung
    static const Map<String, String> _headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true', // Bỏ qua warning của ngrok
    };

    // Lưu token vào SharedPreferences
    static Future<void> _saveToken(String token) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    }

    // Lấy token từ SharedPreferences
    static Future<String?> getToken() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    }

    // Xóa token
    static Future<void> _removeToken() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    }

    // Sign Up
    static Future<Map<String, dynamic>> signUp({
      required String name,
      required String email,
      required String password,
    }) async {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/signup'),
          headers: _headers,
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
          }),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          return {
            'success': true,
            'data': responseData,
            'message': 'Đăng ký thành công! Vui lòng kiểm tra email để xác thực.',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Đăng ký thất bại',
          };
        }
      } catch (e) {
        return {
          'success': false,
          'message': 'Lỗi kết nối: ${e.toString()}',
        };
      }
    }

    // Verify Sign Up
    static Future<Map<String, dynamic>> verifySignUp({
      required String email,
      required String otp,
    }) async {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/verify-signup'),
          headers: _headers,
          body: jsonEncode({
            'email': email,
            'otp': otp,
          }),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          // Backend trả về 'accessToken' 
          if (responseData['accessToken'] != null) {
            await _saveToken(responseData['accessToken']);
            print('💾 Token saved from verify signup: ${responseData['accessToken'].substring(0, 30)}...');
          }
          
          return {
            'success': true,
            'data': responseData,
            'message': responseData['message'] ?? 'Xác thực thành công!',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Mã OTP không đúng',
          };
        }
      } catch (e) {
        return {
          'success': false,
          'message': 'Lỗi kết nối: ${e.toString()}',
        };
      }
    }

    // Login
    static Future<Map<String, dynamic>> login({
      required String email,
      required String password,
      String role = 'user',
    }) async {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/login'),
          headers: _headers,
          body: jsonEncode({
            'email': email,
            'password': password,
            'role': role,
          }),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          // Backend trả về 'accessToken' thay vì 'token'
          if (responseData['accessToken'] != null) {
            await _saveToken(responseData['accessToken']);
          }

          return {
            'success': true,
            'data': responseData,
            'message': responseData['message'] ?? 'Đăng nhập thành công!',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Email hoặc mật khẩu không đúng',
          };
        }
      } catch (e) {
        return {
          'success': false,
          'message': 'Lỗi kết nối: ${e.toString()}',
        };
      }
    }

    // Login with Google
    static Future<Map<String, dynamic>> loginWithGoogle() async {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/login-google'),
          headers: _headers,
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return {
            'success': true,
            'data': responseData,
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Đăng nhập Google thất bại',
          };
        }
      } catch (e) {
        return {
          'success': false,
          'message': 'Lỗi kết nối: ${e.toString()}',
        };
      }
    }

    // Forgot Password
    static Future<Map<String, dynamic>> forgotPassword({
      required String email,
    }) async {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/forgot-password'),
          headers: _headers,
          body: jsonEncode({
            'email': email,
          }),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return {
            'success': true,
            'data': responseData,
            'message': 'Mã xác thực đã được gửi đến email của bạn!',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Email không tồn tại',
          };
        }
      } catch (e) {
        return {
          'success': false,
          'message': 'Lỗi kết nối: ${e.toString()}',
        };
      }
    }

    // Reset Password
    static Future<Map<String, dynamic>> resetPassword({
      required String userId,
      required String password,
    }) async {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/reset-password/$userId'),
          headers: _headers,
          body: jsonEncode({
            'password': password,
          }),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return {
            'success': true,
            'data': responseData,
            'message': 'Đặt lại mật khẩu thành công!',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Đặt lại mật khẩu thất bại',
          };
        }
      } catch (e) {
        return {
          'success': false,
          'message': 'Lỗi kết nối: ${e.toString()}',
        };
      }
    }

    // Resend OTP
    static Future<Map<String, dynamic>> resendOTP({
      required String email,
    }) async {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/resent-otp'),
          headers: _headers,
          body: jsonEncode({
            'email': email,
          }),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return {
            'success': true,
            'data': responseData,
            'message': 'Mã OTP mới đã được gửi!',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Gửi lại OTP thất bại',
          };
        }
      } catch (e) {
        return {
          'success': false,
          'message': 'Lỗi kết nối: ${e.toString()}',
        };
      }
    }

    // Refresh Token
    static Future<Map<String, dynamic>> refreshToken() async {
      try {
        final token = await getToken();
        
        final response = await http.post(
          Uri.parse('$_baseUrl/refresh-token'),
          headers: {
            ..._headers,
            if (token != null) 'Authorization': 'Bearer $token',
          },
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          // Lưu token mới
          if (responseData['token'] != null) {
            await _saveToken(responseData['token']);
          }

          return {
            'success': true,
            'data': responseData,
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Refresh token thất bại',
          };
        }
      } catch (e) {
        return {
          'success': false,
          'message': 'Lỗi kết nối: ${e.toString()}',
        };
      }
    }

    // Logout
    static Future<Map<String, dynamic>> logout() async {
      try {
        final token = await getToken();
        
        final response = await http.post(
          Uri.parse('$_baseUrl/logout'),
          headers: {
            ..._headers,
            if (token != null) 'Authorization': 'Bearer $token',
          },
        );

        // Xóa token local dù API có thành công hay không
        await _removeToken();

        if (response.statusCode == 200) {
          return {
            'success': true,
            'message': 'Đăng xuất thành công!',
          };
        } else {
          // Vẫn trả về success vì đã xóa token local
          return {
            'success': true,
            'message': 'Đăng xuất thành công!',
          };
        }
      } catch (e) {
        // Vẫn xóa token local khi có lỗi
        await _removeToken();
        return {
          'success': true,
          'message': 'Đăng xuất thành công!',
        };
      }
    }

    // Get Profile (cần token)
    static Future<Map<String, dynamic>> getProfile() async {
      try {
        final token = await getToken();
        
        if (token == null) {
          return {
            'success': false,
            'message': 'Chưa đăng nhập',
          };
        }

        final response = await http.get(
          Uri.parse('$_baseUrl/profile'),
          headers: {
            ..._headers,
            'Authorization': 'Bearer $token',
          },
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return {
            'success': true,
            'data': responseData,
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Lấy thông tin thất bại',
          };
        }
      } catch (e) {
        return {
          'success': false,
          'message': 'Lỗi kết nối: ${e.toString()}',
        };
      }
    }

    // Update Profile (cần token)
    static Future<Map<String, dynamic>> updateProfile({
      String? name,
      String? email,
      String? phone,
      // Thêm các field khác nếu cần
    }) async {
      try {
        final token = await getToken();
        
        if (token == null) {
          return {
            'success': false,
            'message': 'Chưa đăng nhập',
          };
        }

        Map<String, dynamic> body = {};
        if (name != null) body['name'] = name;
        if (email != null) body['email'] = email;
        if (phone != null) body['phone'] = phone;

        final response = await http.post(
          Uri.parse('$_baseUrl/update-profile'),
          headers: {
            ..._headers,
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return {
            'success': true,
            'data': responseData,
            'message': 'Cập nhật thông tin thành công!',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Cập nhật thất bại',
          };
        }
      } catch (e) {
        return {
          'success': false,
          'message': 'Lỗi kết nối: ${e.toString()}',
        };
      }
    }

    // Kiểm tra trạng thái đăng nhập
    static Future<bool> isLoggedIn() async {
      final token = await getToken();
      return token != null;
    }
  }