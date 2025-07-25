import 'package:AirVibe/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AirVibe/screens/home-screen.dart';
import 'package:AirVibe/screens/onboarding_screen.dart';
import 'package:AirVibe/screens/auth/login_screen.dart';
import 'package:AirVibe/services/onboarding_service.dart';
import 'package:AirVibe/services/auth_service.dart';
import 'package:AirVibe/services/notification_manager.dart';
import 'package:AirVibe/services/background_service.dart';

void main() async {
  // Đảm bảo WidgetsBinding được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Khởi tạo notification system
    print('🔔 Initializing notification system...');
    await NotificationManager.initialize();
    print('✅ Notification system initialized');
  } catch (e) {
    print('❌ Failed to initialize notifications: $e');
    // Không dừng app nếu notification init failed
  }
  
  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    
    // Add lifecycle observer
    WidgetsBinding.instance.addObserver(this);
    
    // Start background weather monitoring after app is fully loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeBackgroundServices();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BackgroundService.stopWeatherMonitoring();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        print('📱 App resumed - checking notifications and weather');
        _handleAppResumed();
        break;
        
      case AppLifecycleState.paused:
        print('📱 App paused');
        // App đi vào background, giữ monitoring running
        break;
        
      case AppLifecycleState.detached:
        print('📱 App detached');
        BackgroundService.stopWeatherMonitoring();
        break;
        
      case AppLifecycleState.inactive:
        print('📱 App inactive');
        break;
        
      case AppLifecycleState.hidden:
        print('📱 App hidden');
        break;
    }
  }

  Future<void> _initializeBackgroundServices() async {
    try {
      // Chỉ start background service nếu notifications được enable
      final notificationsEnabled = await NotificationManager.areNotificationsEnabled();
      if (notificationsEnabled) {
        BackgroundService.startWeatherMonitoring();
        print('✅ Background weather monitoring started');
      } else {
        print('⏭️ Notifications disabled - skipping background monitoring');
      }
    } catch (e) {
      print('❌ Error initializing background services: $e');
    }
  }

  Future<void> _handleAppResumed() async {
    try {
      // Kiểm tra weather conditions khi app được mở lại
      final notificationsEnabled = await NotificationManager.areNotificationsEnabled();
      if (notificationsEnabled) {
        // Check weather ngay lập tức (không spam notifications)
        await NotificationManager.checkWeatherNow();
        
        // Restart background monitoring nếu chưa running
        if (!BackgroundService.isRunning) {
          BackgroundService.startWeatherMonitoring();
        }
      }
    } catch (e) {
      print('❌ Error handling app resume: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Air Vibe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto', // Hoặc font custom của bạn
        useMaterial3: true,
        // Thêm color scheme cho notifications
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          brightness: Brightness.light,
        ),
      ),
      home: const AppInitializer(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppInitialState>(
      future: _determineInitialState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        
        final state = snapshot.data ?? AppInitialState.onboarding;
        
        switch (state) {
          case AppInitialState.onboarding:
            return const OnboardingScreen();
          case AppInitialState.login:
            return const LoginScreen();
          case AppInitialState.home:
            return const HomeScreen();
        }
      },
    );
  }

  Future<AppInitialState> _determineInitialState() async {
    try {
      // Đảm bảo splash screen hiển thị ít nhất 1.5 giây
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Check onboarding first
      final hasSeenOnboarding = await OnboardingService.hasSeenOnboarding();
      if (!hasSeenOnboarding) {
        return AppInitialState.onboarding;
      }
      
      // Check authentication status
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn) {
        return AppInitialState.login;
      }
      
      // Nếu đã đăng nhập, kiểm tra token có còn hợp lệ không
      final token = await AuthService.getToken();
      if (token != null) {
        // Thử refresh token để đảm bảo token còn hợp lệ
        final refreshResult = await AuthService.refreshToken();
        if (!refreshResult['success']) {
          // Token hết hạn, cần đăng nhập lại
          return AppInitialState.login;
        }
      }
      
      // Nếu user đã đăng nhập, setup notifications cho user đó
      await _setupUserNotifications();
      
      return AppInitialState.home;
    } catch (e) {
      // Nếu có lỗi, đưa về onboarding
      debugPrint('Error determining initial state: $e');
      return AppInitialState.onboarding;
    }
  }

  Future<void> _setupUserNotifications() async {
    try {
      print('👤 Setting up user-specific notifications...');
      
      // Kiểm tra xem user có muốn notifications không
      final notificationsEnabled = await NotificationManager.areNotificationsEnabled();
      if (!notificationsEnabled) {
        print('⏭️ User has disabled notifications');
        return;
      }

      // Setup daily greeting nếu user đã bật
      final dailyGreetingEnabled = await NotificationManager.isDailyGreetingEnabled();
      if (dailyGreetingEnabled) {
        // Re-schedule daily greeting (case user reinstall app or change device time)
        await NotificationManager.setDailyGreetingEnabled(true);
        print('✅ Daily greeting re-scheduled');
      }

      // Kiểm tra weather ngay lập tức nếu user muốn weather alerts
      final weatherAlertsEnabled = await NotificationManager.areWeatherAlertsEnabled();
      if (weatherAlertsEnabled) {
        // Check weather conditions on app start
        await NotificationManager.checkWeatherNow();
        print('✅ Initial weather check completed');
      }

      print('✅ User notifications setup completed');
    } catch (e) {
      print('❌ Error setting up user notifications: $e');
      // Không throw error để không block app startup
    }
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo với animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 20 * value,
                            offset: Offset(0, 10 * value),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.air,
                        size: 60,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // App Name với fade in animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: const Text(
                        'Air Vibe',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 8),
              
              // Tagline với delay animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1200),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: const Text(
                      'Your smart air companion',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 60),
              
              // Loading Indicator với pulse animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1.0),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // Loading text với các trạng thái khác nhau
              const _LoadingTextAnimator(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingTextAnimator extends StatefulWidget {
  const _LoadingTextAnimator();

  @override
  State<_LoadingTextAnimator> createState() => _LoadingTextAnimatorState();
}

class _LoadingTextAnimatorState extends State<_LoadingTextAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  
  final List<String> _loadingTexts = [
    'Initializing...',
    'Setting up notifications...',
    'Checking weather data...',
    'Almost ready...',
  ];
  
  int _currentTextIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _startTextRotation();
  }

  void _startTextRotation() async {
    for (int i = 0; i < _loadingTexts.length; i++) {
      setState(() {
        _currentTextIndex = i;
      });
      
      _controller.forward();
      await Future.delayed(const Duration(milliseconds: 400));
      
      if (i < _loadingTexts.length - 1) {
        _controller.reverse();
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Text(
            _loadingTexts[_currentTextIndex],
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white54,
              fontWeight: FontWeight.w300,
            ),
          ),
        );
      },
    );
  }
}

enum AppInitialState {
  onboarding,
  login,
  home,
}