import 'dart:async';
import 'package:AirVibe/services/weather_notification_service.dart';

class BackgroundService {
  static Timer? _weatherCheckTimer;
  static bool _isRunning = false;

  /// Bắt đầu background service kiểm tra thời tiết mỗi 3 giờ
  static void startWeatherMonitoring() {
    if (_isRunning) return;

    print('🔄 Starting background weather monitoring...');
    
    // Kiểm tra ngay lập tức
    WeatherNotificationService.checkAndNotifyWeatherConditions();
    
    // Lên lịch kiểm tra mỗi 3 giờ
    _weatherCheckTimer = Timer.periodic(
      const Duration(hours: 3),
      (timer) async {
        print('⏰ Periodic weather check...');
        await WeatherNotificationService.checkAndNotifyWeatherConditions();
      },
    );
    
    _isRunning = true;
  }

  /// Dừng background service
  static void stopWeatherMonitoring() {
    if (_weatherCheckTimer != null) {
      _weatherCheckTimer!.cancel();
      _weatherCheckTimer = null;
    }
    _isRunning = false;
    print('⏹️ Stopped background weather monitoring');
  }

  /// Kiểm tra trạng thái service
  static bool get isRunning => _isRunning;
}