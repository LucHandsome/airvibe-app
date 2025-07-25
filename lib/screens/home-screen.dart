import 'package:AirVibe/screens/health_activities_screen.dart';
import 'package:AirVibe/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AirVibe/constants/app_colors.dart';
import 'package:AirVibe/screens/forecast_screen.dart';
import 'package:AirVibe/screens/search-screen.dart';
import 'package:AirVibe/screens/weather_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentPageIndex = 0;

  final _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined, color: Colors.white),
      selectedIcon: Icon(Icons.home, color: Colors.white),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.search_outlined, color: Colors.white),
      selectedIcon: Icon(Icons.search, color: Colors.white),
      label: 'Search',
    ),
    NavigationDestination(
      icon: Icon(Icons.wb_sunny_outlined, color: Colors.white),
      selectedIcon: Icon(Icons.wb_sunny, color: Colors.white),
      label: 'Forecast',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined, color: Colors.white),
      selectedIcon: Icon(Icons.settings, color: Colors.white),
      label: 'Activities',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outlined, color: Colors.white),
      selectedIcon: Icon(Icons.person, color: Colors.white),
      label: 'Settings',
    ),
  ];

  final _screen = [
    const WeatherScreen(), 
    const ScreenSearch(),
    const ForecastScreen(),  
    const HealthActivitiesScreen(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screen[_currentPageIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: const NavigationBarThemeData(
          backgroundColor: Color(0xFF1E3A8A),
        ),
        child: NavigationBar(
          destinations: _destinations,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          selectedIndex: _currentPageIndex,
          indicatorColor: Colors.transparent,
          onDestinationSelected: (index) {
            setState(() {
              _currentPageIndex = index;
            });
          },
        ),
      ),
    );
  }
}