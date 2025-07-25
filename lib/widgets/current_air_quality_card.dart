import 'package:AirVibe/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AirVibe/constants/text_styles.dart';
import 'package:AirVibe/models/air_pollution.dart';
import 'package:AirVibe/providers/air_pollution_provider.dart';
import 'package:AirVibe/screens/air_quality_detail_screen.dart';
import 'package:AirVibe/services/api_helper.dart';

class CurrentAirQualityCard extends ConsumerWidget {
  const CurrentAirQualityCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final airPollutionData = ref.watch(currentAirPollutionProvider);

    return airPollutionData.when(
      data: (airPollution) => _buildAirQualityCard(context, airPollution),
      error: (error, stackTrace) => _buildErrorCard(),
      loading: () => _buildLoadingCard(),
    );
  }

  Widget _buildAirQualityCard(BuildContext context, AirPollution airPollution) {
    return InkWell(
      onTap: () => _navigateToDetail(context, airPollution),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.1),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // AQI Circle
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: airPollution.aqiColor,
              ),
              child: Center(
                child: Text(
                  '${airPollution.aqi}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AQI ${airPollution.aqi}',
                    style: TextStyles.h2.copyWith(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    airPollution.qualityLevel,
                    style: TextStyle(
                      fontSize: 14,
                      color: airPollution.aqiColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chạm để xem chi tiết',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withOpacity(0.3),
            ),
            child: const Center(
              child: LoadingWidget(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đang tải chỉ số không khí...',
                  style: TextStyles.h2.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vui lòng chờ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.red.withOpacity(0.1),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.3),
            ),
            child: const Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Không thể tải chỉ số không khí',
                  style: TextStyles.h2.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vui lòng thử lại sau',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, AirPollution airPollution) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AirQualityDetailScreen(
          airPollution: airPollution,
          lat: ApiHelper.lat.toString(),
          lon: ApiHelper.lon.toString(),
        ),
      ),
    );
  }
}