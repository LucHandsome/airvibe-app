import 'package:flutter/material.dart';
import 'package:AirVibe/services/background_service.dart';
import 'package:AirVibe/services/notification_manager.dart';

class AppLifecycleHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        print('📱 App resumed - checking notifications');
        // App được mở lại, kiểm tra thời tiết
        NotificationManager.checkWeatherNow();
        BackgroundService.startWeatherMonitoring();
        break;
        
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        print('📱 App paused/detached');
        // App bị pause, có thể dừng background service tùy theo strategy
        break;
        
      case AppLifecycleState.inactive:
        print('📱 App inactive');
        break;
        
      case AppLifecycleState.hidden:
        print('📱 App hidden');
        break;
    }
  }
}