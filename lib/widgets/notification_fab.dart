import 'package:flutter/material.dart';
import 'package:AirVibe/screens/notification_settings_screen.dart';

class NotificationFAB extends StatelessWidget {
  const NotificationFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NotificationSettingsScreen(),
          ),
        );
      },
      backgroundColor: const Color(0xFF1E3A8A),
      child: const Icon(Icons.notifications, color: Colors.white),
    );
  }
}