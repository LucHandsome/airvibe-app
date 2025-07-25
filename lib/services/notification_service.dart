// lib/services/notification_service.dart - FULL VERSION
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'test',
      'Test Notifications',
      channelDescription: 'Test notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      999,
      '🌅 Test: Chào buổi sáng!',
      'Đây là test notification cho chào buổi sáng',
      notificationDetails,
    );
  }

  static bool _isInitialized = false;

  // Notification IDs
  static const int dailyGreetingId = 1;
  static const int airQualityId = 2;
  static const int weatherAlertId = 3;

  /// Khởi tạo notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

      // Android initialization
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = true;
      print('✅ NotificationService initialized successfully');
    } catch (e) {
      print('❌ Error initializing NotificationService: $e');
      _isInitialized = false;
    }
  }

  /// Xử lý khi user tap vào notification
  static void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notification tapped: ${response.payload}');
    // TODO: Navigate to specific screen based on payload
  }

  /// Request permission
  static Future<bool> requestPermission() async {
    try {
      // Request basic notification permission
      if (await Permission.notification.isDenied) {
        final status = await Permission.notification.request();
        if (status != PermissionStatus.granted) {
          print('❌ Notification permission denied');
          return false;
        }
      }

      // For Android 13+ (API 33+), request POST_NOTIFICATIONS permission
      final androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? androidResult =
            await androidImplementation.requestNotificationsPermission();
        print('✅ Android notification permission: $androidResult');
        return androidResult ?? true;
      }

      return true;
    } catch (e) {
      print('❌ Error requesting permission: $e');
      return false;
    }
  }

  /// Schedule daily greeting notification (7 AM every day)
  static Future<void> scheduleDailyGreeting() async {
    try {
      if (!_isInitialized) await initialize();

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'daily_greeting',
        'Chào buổi sáng',
        channelDescription: 'Thông báo chào buổi sáng hàng ngày',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      // Schedule for 7 AM every day
      await _notifications.zonedSchedule(
        dailyGreetingId,
        '🌅 Chào buổi sáng!',
        'Hãy kiểm tra thời tiết hôm nay để chuẩn bị tốt nhất cho ngày mới!',
        _nextInstanceOf7AM(),
        notificationDetails,
        androidScheduleMode:
            AndroidScheduleMode.exactAllowWhileIdle, // ✅ mới bắt buộc
        matchDateTimeComponents:
            DateTimeComponents.time, // ✅ giữ lại để lặp mỗi ngày
        payload: 'daily_greeting',
      );

      print('✅ Daily greeting scheduled for 7 AM');
    } catch (e) {
      print('❌ Error scheduling daily greeting: $e');
    }
  }

  /// Calculate next 7 AM
  static tz.TZDateTime _nextInstanceOf7AM() {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      7, // 7 AM
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Show air quality notification
  static Future<void> showAirQualityNotification({
    required int aqi,
    required String level,
    required String description,
    required String advice,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      // Chỉ thông báo khi chất lượng không khí không tốt (AQI >= 3)
      if (aqi < 3) return;

      String title;
      String body;

      switch (aqi) {
        case 3:
          title = '⚠️ Chất lượng không khí trung bình';
          break;
        case 4:
          title = '🚨 Chất lượng không khí kém';
          break;
        case 5:
          title = '☠️ Chất lượng không khí rất kém';
          break;
        default:
          return;
      }

      body = '😷 $description\n💡 $advice';

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'air_quality',
        'Chất lượng không khí',
        channelDescription: 'Cảnh báo về chất lượng không khí',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Colors.orange,
        ledColor: Colors.orange,
        ledOnMs: 1000,
        ledOffMs: 500,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _notifications.show(
        airQualityId,
        title,
        body,
        notificationDetails,
        payload: 'air_quality',
      );

      print('✅ Air quality notification sent: AQI $aqi');
    } catch (e) {
      print('❌ Error showing air quality notification: $e');
    }
  }

  /// Show weather alert notification
  static Future<void> showWeatherAlert({
    required double temperature,
    required double feelsLike,
    required int humidity,
    required String weatherMain,
    required String description,
    required int uvIndex,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      String? title;
      String? body;

      // Kiểm tra các điều kiện thời tiết đáng chú ý
      if (temperature >= 35 || feelsLike >= 38) {
        title = '🌡️ Cảnh báo nắng nóng';
        body =
            'Nhiệt độ ${temperature.toInt()}°C (cảm giác ${feelsLike.toInt()}°C)\n'
            '☀️ Thoa kem chống nắng\n'
            '💧 Uống nhiều nước\n'
            '👕 Mặc quần áo thoáng mát';
      } else if (weatherMain.toLowerCase().contains('rain') ||
          description.contains('mưa')) {
        title = '🌧️ Cảnh báo mưa';
        body = '$description\n'
            '☂️ Mang theo ô\n'
            '🧥 Mặc áo khoác\n'
            '👟 Đi giày chống trượt';
      } else if (weatherMain.toLowerCase().contains('thunderstorm') ||
          description.contains('giông')) {
        title = '⛈️ Cảnh báo giông bão';
        body = '$description\n'
            '🏠 Hạn chế ra ngoài\n'
            '⚡ Tránh xa cây cao\n'
            '📱 Theo dõi thời tiết';
      } else if (humidity >= 85) {
        title = '💧 Độ ẩm cao';
        body = 'Độ ẩm ${humidity}% - Thời tiết oi bức\n'
            '👕 Mặc quần áo cotton\n'
            '💨 Tìm nơi thoáng mát\n'
            '💧 Bổ sung nước thường xuyên';
      } else if (uvIndex >= 8) {
        title = '☀️ Tia UV cao';
        body = 'Chỉ số UV: $uvIndex - Rất cao\n'
            '🕶️ Đeo kính râm\n'
            '🧴 Thoa kem chống nắng SPF 30+\n'
            '👒 Đội mũ rộng vành';
      }

      // Chỉ gửi notification nếu có cảnh báo
      if (title == null || body == null) return;

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'weather_alert',
        'Cảnh báo thời tiết',
        channelDescription: 'Cảnh báo và lời khuyên về thời tiết',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Colors.blue,
        ledColor: Colors.blue,
        ledOnMs: 1000,
        ledOffMs: 500,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _notifications.show(
        weatherAlertId,
        title,
        body,
        notificationDetails,
        payload: 'weather_alert',
      );

      print('✅ Weather alert sent: $title');
    } catch (e) {
      print('❌ Error showing weather alert: $e');
    }
  }

  /// Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      print('✅ Cancelled notification ID: $id');
    } catch (e) {
      print('❌ Error cancelling notification: $e');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      print('✅ Cancelled all notifications');
    } catch (e) {
      print('❌ Error cancelling all notifications: $e');
    }
  }

  /// Get pending notifications
  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      print('❌ Error getting pending notifications: $e');
      return [];
    }
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    try {
      final androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? isEnabled =
            await androidImplementation.areNotificationsEnabled();
        return isEnabled ?? false;
      }

      return true; // Default for iOS or if check fails
    } catch (e) {
      print('❌ Error checking notification status: $e');
      return false;
    }
  }

  /// Open notification settings
  static Future<void> openNotificationSettings() async {
    try {
      final androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    } catch (e) {
      print('❌ Error opening notification settings: $e');
    }
  }
}
