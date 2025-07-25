// lib/services/weather_notification_service.dart
import 'package:dio/dio.dart';
import 'package:AirVibe/services/notification_service.dart';
import 'package:AirVibe/services/geolocator.dart';

class WeatherNotificationService {
  static const String baseUrl = 'https://ca92582b6720.ngrok-free.app';
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    ),
  );

  /// Kiểm tra và gửi notification dựa trên thời tiết hiện tại
  static Future<void> checkAndNotifyWeatherConditions() async {
    try {
      print('🌤️ Checking weather conditions for notifications...');
      
      // Lấy vị trí hiện tại
      final location = await getLocation();
      final lat = location.latitude;
      final lon = location.longitude;

      // Gọi đồng thời cả 2 API
      final responses = await Future.wait([
        _getWeatherData(lat, lon),
        _getAirPollutionData(lat, lon),
      ]);

      final weatherData = responses[0];
      final airPollutionData = responses[1];

      // Xử lý dữ liệu thời tiết
      if (weatherData != null) {
        await _processWeatherData(weatherData);
      }

      // Xử lý dữ liệu chất lượng không khí
      if (airPollutionData != null) {
        await _processAirPollutionData(airPollutionData);
      }

      print('✅ Weather notification check completed');
    } catch (e) {
      print('❌ Error checking weather conditions: $e');
    }
  }

  /// Lấy dữ liệu thời tiết hiện tại
  static Future<Map<String, dynamic>?> _getWeatherData(double lat, double lon) async {
    try {
      final response = await _dio.get('$baseUrl/api/v1/weather/current/$lat/$lon');
      
      if (response.statusCode == 200 && response.data['success']) {
        return response.data['data'];
      }
    } catch (e) {
      print('❌ Error fetching weather data: $e');
    }
    return null;
  }

  /// Lấy dữ liệu chất lượng không khí
  static Future<Map<String, dynamic>?> _getAirPollutionData(double lat, double lon) async {
    try {
      final response = await _dio.get('$baseUrl/api/v1/weather/air-pollution/current/$lat/$lon');
      
      if (response.statusCode == 200 && response.data['success']) {
        return response.data['data'];
      }
    } catch (e) {
      print('❌ Error fetching air pollution data: $e');
    }
    return null;
  }

  /// Xử lý và gửi notification cho thời tiết
  static Future<void> _processWeatherData(Map<String, dynamic> data) async {
    try {
      final current = data['current'];
      final location = data['location'];
      
      final temperature = current['temperature']?.toDouble() ?? 0.0;
      final feelsLike = current['feelsLike']?.toDouble() ?? 0.0;
      final humidity = current['humidity']?.toInt() ?? 0;
      final uvIndex = current['uvIndex']?.toInt() ?? 0;
      final weatherMain = current['weather']['main'] ?? '';
      final description = current['weather']['description'] ?? '';

      print('🌡️ Weather: ${temperature}°C, feels like ${feelsLike}°C');
      print('🌤️ Condition: $weatherMain - $description');
      print('💧 Humidity: ${humidity}%, UV: $uvIndex');

      // Gửi notification nếu cần thiết
      await NotificationService.showWeatherAlert(
        temperature: temperature,
        feelsLike: feelsLike,
        humidity: humidity,
        weatherMain: weatherMain,
        description: description,
        uvIndex: uvIndex,
      );

    } catch (e) {
      print('❌ Error processing weather data: $e');
    }
  }

  /// Xử lý và gửi notification cho chất lượng không khí
  static Future<void> _processAirPollutionData(Map<String, dynamic> data) async {
    try {
      final current = data['current'];
      final aqi = current['aqi'];
      
      final aqiIndex = aqi['index']?.toInt() ?? 1;
      final aqiLevel = aqi['level'] ?? 'Unknown';
      final aqiDescription = aqi['description'] ?? '';
      final advice = current['advice'] ?? '';

      print('🌬️ AQI: $aqiIndex ($aqiLevel)');
      print('📝 Description: $aqiDescription');
      print('💡 Advice: $advice');

      // Gửi notification nếu AQI không tốt
      await NotificationService.showAirQualityNotification(
        aqi: aqiIndex,
        level: aqiLevel,
        description: aqiDescription,
        advice: advice,
      );

      // Log các thành phần chi tiết
      final components = current['components'];
      if (components != null) {
        final pm25 = components['pm2_5']?['value'] ?? 0;
        final pm10 = components['pm10']?['value'] ?? 0;
        print('🔬 PM2.5: ${pm25}μg/m³, PM10: ${pm10}μg/m³');
      }

    } catch (e) {
      print('❌ Error processing air pollution data: $e');
    }
  }

  /// Kiểm tra thời tiết trong khoảng thời gian định kỳ
  static Future<void> startPeriodicWeatherCheck() async {
    print('🔄 Starting periodic weather check...');
    
    // Kiểm tra ngay lập tức
    await checkAndNotifyWeatherConditions();
    
    // Lên lịch kiểm tra mỗi 3 giờ
    // Trong thực tế, bạn có thể sử dụng background service hoặc WorkManager
    // Đây chỉ là ví dụ đơn giản
  }

  /// Dừng kiểm tra định kỳ
  static void stopPeriodicWeatherCheck() {
    print('⏹️ Stopping periodic weather check...');
    // Implementation depends on how you schedule the periodic checks
  }

  /// Test notification ngay lập tức
  static Future<void> testNotifications() async {
    print('🧪 Testing notifications...');
    
    // Test weather alert
    await NotificationService.showWeatherAlert(
      temperature: 36.0,
      feelsLike: 42.0,
      humidity: 90,
      weatherMain: 'Clear',
      description: 'trời nắng',
      uvIndex: 10,
    );

    await Future.delayed(const Duration(seconds: 2));

    // Test air quality alert
    await NotificationService.showAirQualityNotification(
      aqi: 4,
      level: 'Poor',
      description: 'Chất lượng không khí kém',
      advice: 'Nên đeo khẩu trang khi ra ngoài',
    );

    print('✅ Test notifications sent');
  }

  /// Lấy thống kê thời tiết (để hiển thị trong app)
  static Future<Map<String, dynamic>?> getWeatherSummary() async {
    try {
      final location = await getLocation();
      final weatherData = await _getWeatherData(location.latitude, location.longitude);
      final airPollutionData = await _getAirPollutionData(location.latitude, location.longitude);

      return {
        'weather': weatherData,
        'airPollution': airPollutionData,
        'lastChecked': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ Error getting weather summary: $e');
      return null;
    }
  }
}