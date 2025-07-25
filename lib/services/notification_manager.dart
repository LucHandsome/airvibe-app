// lib/services/notification_manager.dart
import 'package:AirVibe/services/notification_service.dart';
import 'package:AirVibe/services/weather_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class NotificationManager {
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyDailyGreetingEnabled = 'daily_greeting_enabled';
  static const String _keyWeatherAlertsEnabled = 'weather_alerts_enabled';
  static const String _keyAirQualityAlertsEnabled = 'air_quality_alerts_enabled';
  static const String _keyLastWeatherCheck = 'last_weather_check';

  /// Khởi tạo toàn bộ hệ thống notification
  static Future<void> initialize() async {
    try {
      print('🔔 Initializing Notification Manager...');
      
      // Initialize notification service
      await NotificationService.initialize();
      
      // Request permission
      final hasPermission = await NotificationService.requestPermission();
      if (!hasPermission) {
        print('⚠️ Notification permission denied');
        return;
      }

      // Load user preferences
      await _loadPreferences();
      
      // Setup daily greeting if enabled
      final dailyEnabled = await isDailyGreetingEnabled();
      if (dailyEnabled) {
        await NotificationService.scheduleDailyGreeting();
      }

      // Start weather monitoring if enabled
      final weatherEnabled = await areWeatherAlertsEnabled();
      if (weatherEnabled) {
        await _startWeatherMonitoring();
      }

      print('✅ Notification Manager initialized successfully');
    } catch (e) {
      print('❌ Error initializing Notification Manager: $e');
    }
  }

  /// Load user preferences from SharedPreferences
  static Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Set default values if not exists
    if (!prefs.containsKey(_keyNotificationsEnabled)) {
      await prefs.setBool(_keyNotificationsEnabled, true);
    }
    if (!prefs.containsKey(_keyDailyGreetingEnabled)) {
      await prefs.setBool(_keyDailyGreetingEnabled, true);
    }
    if (!prefs.containsKey(_keyWeatherAlertsEnabled)) {
      await prefs.setBool(_keyWeatherAlertsEnabled, true);
    }
    if (!prefs.containsKey(_keyAirQualityAlertsEnabled)) {
      await prefs.setBool(_keyAirQualityAlertsEnabled, true);
    }
  }

  /// Start weather monitoring
  static Future<void> _startWeatherMonitoring() async {
    // Kiểm tra lần cuối
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getString(_keyLastWeatherCheck);
    final now = DateTime.now();
    
    // Chỉ kiểm tra nếu đã qua 1 giờ từ lần cuối
    if (lastCheck != null) {
      final lastCheckTime = DateTime.parse(lastCheck);
      final difference = now.difference(lastCheckTime).inHours;
      if (difference < 1) {
        print('⏭️ Weather check skipped (checked ${difference}h ago)');
        return;
      }
    }

    // Kiểm tra thời tiết và gửi notification nếu cần
    await WeatherNotificationService.checkAndNotifyWeatherConditions();
    
    // Lưu thời gian kiểm tra
    await prefs.setString(_keyLastWeatherCheck, now.toIso8601String());
  }

  // === NOTIFICATION SETTINGS ===

  /// Enable/disable all notifications
  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, enabled);
    
    if (!enabled) {
      await NotificationService.cancelAllNotifications();
    } else {
      await initialize(); // Re-initialize if enabling
    }
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  /// Enable/disable daily greeting
  static Future<void> setDailyGreetingEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDailyGreetingEnabled, enabled);
    
    if (enabled) {
      await NotificationService.scheduleDailyGreeting();
    } else {
      await NotificationService.cancelNotification(NotificationService.dailyGreetingId);
    }
  }

  /// Check if daily greeting is enabled
  static Future<bool> isDailyGreetingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDailyGreetingEnabled) ?? true;
  }

  /// Enable/disable weather alerts
  static Future<void> setWeatherAlertsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyWeatherAlertsEnabled, enabled);
    
    if (!enabled) {
      await NotificationService.cancelNotification(NotificationService.weatherAlertId);
    }
  }

  /// Check if weather alerts are enabled
  static Future<bool> areWeatherAlertsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyWeatherAlertsEnabled) ?? true;
  }

  /// Enable/disable air quality alerts
  static Future<void> setAirQualityAlertsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAirQualityAlertsEnabled, enabled);
    
    if (!enabled) {
      await NotificationService.cancelNotification(NotificationService.airQualityId);
    }
  }

  /// Check if air quality alerts are enabled
  static Future<bool> areAirQualityAlertsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAirQualityAlertsEnabled) ?? true;
  }

  // === MANUAL ACTIONS ===

  /// Trigger weather check manually
  static Future<void> checkWeatherNow() async {
    final weatherEnabled = await areWeatherAlertsEnabled();
    final airQualityEnabled = await areAirQualityAlertsEnabled();
    
    if (weatherEnabled || airQualityEnabled) {
      await WeatherNotificationService.checkAndNotifyWeatherConditions();
      
      // Update last check time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastWeatherCheck, DateTime.now().toIso8601String());
    }
  }

  /// Test all notification types
  static Future<void> testAllNotifications() async {
    print('🧪 Testing all notifications...');
    
    // Test daily greeting
    await NotificationService.showTestNotification();

    await Future.delayed(const Duration(seconds: 2));

    // Test weather and air quality
    await WeatherNotificationService.testNotifications();
  }

  /// Get notification status summary
  static Future<Map<String, dynamic>> getNotificationStatus() async {
    final lastCheckPrefs = await SharedPreferences.getInstance();
    final lastCheck = lastCheckPrefs.getString(_keyLastWeatherCheck);
    
    return {
      'enabled': await areNotificationsEnabled(),
      'dailyGreeting': await isDailyGreetingEnabled(),
      'weatherAlerts': await areWeatherAlertsEnabled(),
      'airQualityAlerts': await areAirQualityAlertsEnabled(),
      'lastWeatherCheck': lastCheck,
      'systemEnabled': await NotificationService.areNotificationsEnabled(),
      'pendingNotifications': (await NotificationService.getPendingNotifications()).length,
    };
  }

  /// Reset all notification settings to default
  static Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyNotificationsEnabled);
    await prefs.remove(_keyDailyGreetingEnabled);
    await prefs.remove(_keyWeatherAlertsEnabled);
    await prefs.remove(_keyAirQualityAlertsEnabled);
    await prefs.remove(_keyLastWeatherCheck);
    
    await NotificationService.cancelAllNotifications();
    await initialize();
  }

  /// Open system notification settings
  static Future<void> openSystemSettings() async {
    await NotificationService.openNotificationSettings();
  }
}