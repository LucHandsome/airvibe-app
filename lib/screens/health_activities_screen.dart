import 'package:AirVibe/screens/token_debug_screen.dart';
import 'package:AirVibe/services/api_helper.dart';
import 'package:AirVibe/services/geocoding_service.dart';
import 'package:AirVibe/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:AirVibe/providers/health_activities_provider.dart';
import 'package:AirVibe/models/health_activities.dart';
import 'package:AirVibe/views/gradient_container.dart';
import 'package:AirVibe/constants/text_styles.dart';
import 'package:AirVibe/screens/chat_screen.dart';

class HealthActivitiesScreen extends ConsumerWidget {
  const HealthActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthActivitiesData = ref.watch(currentHealthActivitiesProvider);

    return Scaffold(
      body: Stack(
        children: [
          healthActivitiesData.when(
            data: (healthActivities) =>
                _buildHealthActivitiesContent(healthActivities),
            error: (error, stackTrace) => _buildErrorContent(),
            loading: () => _buildLoadingContent(),
          ),

          // Floating Chatbot Button
          Positioned(
            right: 10,
            bottom: 20,
            child: _buildChatbotButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const TokenDebugScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bug_report, color: Colors.orange, size: 16),
            const SizedBox(width: 4),
            const Text(
              'Debug Token',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatbotButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ChatScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        width: 150,
        height: 150,
        child: Lottie.asset(
          'assets/lottie/chatbot.json',
          width: 150,
          height: 150,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildHealthActivitiesContent(HealthActivities healthActivities) {
    return GradientContainer(
      children: [
        const SizedBox(height: 30, width: double.infinity),

        // Header
        Text(
          'Sức khỏe & Hoạt động',
          style: TextStyles.h1,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 10),

        FutureBuilder(
          future: getPlaceFromCoordinates(ApiHelper.lat, ApiHelper.lon),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget();
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const Text('Không xác định địa điểm',
                  style: TextStyles.h1);
            } else {
              return Text(snapshot.data!,
                  style: TextStyles.h1, textAlign: TextAlign.center);
            }
          },
        ),

        const SizedBox(height: 30),

        // Health Section
        _buildHealthSection(healthActivities.health),

        const SizedBox(height: 20),

        // Activities Section
        _buildActivitiesSection(healthActivities.activities),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHealthSection(HealthData health) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                'Sức khỏe',
                style: TextStyles.h2.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Health Items Grid
          _buildHealthItemCard('Bệnh viêm khớp', health.arthritis),
          const SizedBox(height: 8),
          _buildHealthItemCard('Cảm lạnh', health.commonCold),
          const SizedBox(height: 8),
          _buildHealthItemCard('Hen suyễn', health.asthma),
          const SizedBox(height: 8),
          _buildHealthItemCard('Dị ứng', health.allergies),
        ],
      ),
    );
  }

  Widget _buildActivitiesSection(ActivitiesData activities) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_run, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                'Hoạt động ngoài trời',
                style: TextStyles.h2.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Outdoor Activities
          _buildActivityItemCard(
              'Câu cá', activities.outdoor.fishing, Icons.phishing),
          const SizedBox(height: 8),
          _buildActivityItemCard(
              'Chạy bộ', activities.outdoor.running, Icons.directions_run),
          const SizedBox(height: 8),
          _buildActivityItemCard(
              'Đạp xe', activities.outdoor.cycling, Icons.directions_bike),
          const SizedBox(height: 8),
          _buildActivityItemCard(
              'Đi bộ đường dài', activities.outdoor.hiking, Icons.hiking),

          const SizedBox(height: 20),

          // Travel Section
          Row(
            children: [
              Icon(Icons.directions_car, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                'Đi lại và di chuyển',
                style: TextStyles.h2.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildActivityItemCard(
              'Du lịch hàng không', activities.travel.airTravel, Icons.flight),
          const SizedBox(height: 8),
          _buildActivityItemCard(
              'Lái xe', activities.travel.driving, Icons.directions_car),
        ],
      ),
    );
  }

  Widget _buildHealthItemCard(String title, HealthItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: item.levelColor.withOpacity(0.1),
        border: Border.all(color: item.levelColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.levelColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.level,
                  style: TextStyle(
                    color: item.levelColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item.score}',
            style: TextStyle(
              color: item.levelColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItemCard(
      String title, ActivityItem item, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: item.levelColor.withOpacity(0.1),
        border: Border.all(color: item.levelColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: item.levelColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.level,
                  style: TextStyle(
                    color: item.levelColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: item.levelColor.withOpacity(0.2),
            ),
            child: Text(
              '${item.score}/5',
              style: TextStyle(
                color: item.levelColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return GradientContainer(
      children: [
        const SizedBox(height: 30, width: double.infinity),
        Text(
          'Sức khỏe & Hoạt động',
          style: TextStyles.h1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 100),
        const Center(
          child: LoadingWidget(),
        ),
      ],
    );
  }

  Widget _buildErrorContent() {
    return GradientContainer(
      children: [
        const SizedBox(height: 30, width: double.infinity),
        Text(
          'Sức khỏe & Hoạt động',
          style: TextStyles.h1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 100),
        const Center(
          child: Text(
            'Không thể tải thông tin sức khỏe',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
