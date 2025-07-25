// lib/screens/notification_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:AirVibe/services/notification_manager.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _notificationStatus = {};
  
  bool _notificationsEnabled = true;
  bool _dailyGreetingEnabled = true;
  bool _weatherAlertsEnabled = true;
  bool _airQualityAlertsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final status = await NotificationManager.getNotificationStatus();
      final enabled = await NotificationManager.areNotificationsEnabled();
      final dailyGreeting = await NotificationManager.isDailyGreetingEnabled();
      final weatherAlerts = await NotificationManager.areWeatherAlertsEnabled();
      final airQualityAlerts = await NotificationManager.areAirQualityAlertsEnabled();

      setState(() {
        _notificationStatus = status;
        _notificationsEnabled = enabled;
        _dailyGreetingEnabled = dailyGreeting;
        _weatherAlertsEnabled = weatherAlerts;
        _airQualityAlertsEnabled = airQualityAlerts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Lỗi tải cài đặt: $e', Colors.red);
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    await NotificationManager.setNotificationsEnabled(value);
    setState(() {
      _notificationsEnabled = value;
    });
    _showSnackBar(
      value ? 'Đã bật thông báo' : 'Đã tắt thông báo',
      value ? Colors.green : Colors.orange,
    );
  }

  Future<void> _toggleDailyGreeting(bool value) async {
    await NotificationManager.setDailyGreetingEnabled(value);
    setState(() {
      _dailyGreetingEnabled = value;
    });
    _showSnackBar(
      value ? 'Đã bật chào buổi sáng' : 'Đã tắt chào buổi sáng',
      value ? Colors.green : Colors.orange,
    );
  }

  Future<void> _toggleWeatherAlerts(bool value) async {
    await NotificationManager.setWeatherAlertsEnabled(value);
    setState(() {
      _weatherAlertsEnabled = value;
    });
    _showSnackBar(
      value ? 'Đã bật cảnh báo thời tiết' : 'Đã tắt cảnh báo thời tiết',
      value ? Colors.green : Colors.orange,
    );
  }

  Future<void> _toggleAirQualityAlerts(bool value) async {
    await NotificationManager.setAirQualityAlertsEnabled(value);
    setState(() {
      _airQualityAlertsEnabled = value;
    });
    _showSnackBar(
      value ? 'Đã bật cảnh báo chất lượng không khí' : 'Đã tắt cảnh báo chất lượng không khí',
      value ? Colors.green : Colors.orange,
    );
  }

  Future<void> _testNotifications() async {
    _showSnackBar('Đang gửi test notifications...', Colors.blue);
    await NotificationManager.testAllNotifications();
    _showSnackBar('Test notifications đã được gửi!', Colors.green);
  }

  Future<void> _checkWeatherNow() async {
    _showSnackBar('Đang kiểm tra thời tiết...', Colors.blue);
    await NotificationManager.checkWeatherNow();
    _showSnackBar('Đã kiểm tra thời tiết hiện tại', Colors.green);
    await _loadSettings(); // Refresh status
  }

  Future<void> _resetSettings() async {
    final confirmed = await _showConfirmDialog(
      'Đặt lại cài đặt',
      'Bạn có chắc muốn đặt lại tất cả cài đặt notification về mặc định?',
    );
    
    if (confirmed) {
      await NotificationManager.resetToDefaults();
      await _loadSettings();
      _showSnackBar('Đã đặt lại cài đặt về mặc định', Colors.green);
    }
  }

  Future<void> _openSystemSettings() async {
    await NotificationManager.openSystemSettings();
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt Thông báo'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadSettings,
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  _buildStatusCard(),
                  
                  const SizedBox(height: 24),
                  
                  // Main Settings
                  _buildMainSettingsCard(),
                  
                  const SizedBox(height: 24),
                  
                  // Specific Settings
                  _buildSpecificSettingsCard(),
                  
                  const SizedBox(height: 24),
                  
                  // Actions
                  _buildActionsCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trạng thái Thông báo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildStatusRow('Hệ thống', 
                _notificationStatus['systemEnabled'] == true ? 'Cho phép' : 'Bị chặn',
                _notificationStatus['systemEnabled'] == true ? Colors.green : Colors.red),
            
            _buildStatusRow('Thông báo chờ', 
                '${_notificationStatus['pendingNotifications'] ?? 0}',
                Colors.blue),
            
            if (_notificationStatus['lastWeatherCheck'] != null)
              _buildStatusRow('Kiểm tra cuối', 
                  _formatDateTime(_notificationStatus['lastWeatherCheck']),
                  Colors.grey),
                  
            if (_notificationStatus['systemEnabled'] != true) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openSystemSettings,
                  icon: const Icon(Icons.settings),
                  label: const Text('Mở Cài đặt Hệ thống'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMainSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cài đặt Chính',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            SwitchListTile(
              title: const Text('Bật Thông báo'),
              subtitle: const Text('Bật/tắt tất cả thông báo từ ứng dụng'),
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
              secondary: const Icon(Icons.notifications),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Loại Thông báo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            SwitchListTile(
              title: const Text('Chào buổi sáng'),
              subtitle: const Text('Thông báo chào buổi sáng lúc 7h hàng ngày'),
              value: _dailyGreetingEnabled && _notificationsEnabled,
              onChanged: _notificationsEnabled ? _toggleDailyGreeting : null,
              secondary: const Icon(Icons.wb_sunny, color: Colors.orange),
            ),
            
            const Divider(),
            
            SwitchListTile(
              title: const Text('Cảnh báo Thời tiết'),
              subtitle: const Text('Thông báo khi thời tiết khó chịu (nắng nóng, mưa...)'),
              value: _weatherAlertsEnabled && _notificationsEnabled,
              onChanged: _notificationsEnabled ? _toggleWeatherAlerts : null,
              secondary: const Icon(Icons.cloud, color: Colors.blue),
            ),
            
            const Divider(),
            
            SwitchListTile(
              title: const Text('Cảnh báo Chất lượng không khí'),
              subtitle: const Text('Thông báo khi chất lượng không khí kém'),
              value: _airQualityAlertsEnabled && _notificationsEnabled,
              onChanged: _notificationsEnabled ? _toggleAirQualityAlerts : null,
              secondary: const Icon(Icons.air, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hành động',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _testNotifications,
                icon: const Icon(Icons.notification_add),
                label: const Text('Test Thông báo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _checkWeatherNow,
                icon: const Icon(Icons.cloud_sync),
                label: const Text('Kiểm tra Thời tiết Ngay'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _resetSettings,
                icon: const Icon(Icons.restore),
                label: const Text('Đặt lại Cài đặt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'Chưa có';
    
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} phút trước';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} giờ trước';
      } else {
        return '${difference.inDays} ngày trước';
      }
    } catch (e) {
      return 'Không xác định';
    }
  }
}