import 'package:flutter/material.dart';
import 'package:AirVibe/constants/text_styles.dart';
import 'package:AirVibe/models/air_pollution.dart';
import 'package:AirVibe/services/geocoding_service.dart';
import 'package:AirVibe/views/gradient_container.dart';

class AirQualityDetailScreen extends StatelessWidget {
  final AirPollution airPollution;
  final String lat;
  final String lon;

  const AirQualityDetailScreen({
    super.key,
    required this.airPollution,
    required this.lat,
    required this.lon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        children: [
          const SizedBox(height: 30, width: double.infinity),
          
          // Header with back button
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              Expanded(
                child: FutureBuilder<String>(
                  future: getPlaceFromCoordinates(
                    double.parse(lat), 
                    double.parse(lon)
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        'Chất lượng không khí - ${snapshot.data!.split(',').first}',
                        style: TextStyles.h2.copyWith(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      );
                    }
                    return Text(
                      'Chất lượng không khí',
                      style: TextStyles.h2.copyWith(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),

          const SizedBox(height: 40),

          // Main AQI Display
          _buildMainAQIDisplay(),

          const SizedBox(height: 40),

          // Air Quality Status
          _buildAirQualityStatus(),

          const SizedBox(height: 30),

          // Components Detail
          _buildComponentsDetail(),

          const SizedBox(height: 30),

          // Recommendations
          _buildRecommendations(),

          const SizedBox(height: 30)
        ],
      ),
    );
  }

  Widget _buildMainAQIDisplay() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: airPollution.aqiColor,
            boxShadow: [
              BoxShadow(
                color: airPollution.aqiColor.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${airPollution.aqi}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'AQI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          airPollution.qualityLevel,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: airPollution.aqiColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAirQualityStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(
                Icons.info_outline,
                color: airPollution.aqiColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Mô tả chất lượng không khí',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            airPollution.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentsDetail() {
    final components = [
      ComponentInfo('PM2.5', airPollution.components.pm2_5, 'μg/m³', 'Bụi mịn'),
      ComponentInfo('PM10', airPollution.components.pm10, 'μg/m³', 'Bụi thô'),
      ComponentInfo('O₃', airPollution.components.o3, 'μg/m³', 'Ozone'),
      ComponentInfo('NO₂', airPollution.components.no2, 'μg/m³', 'Nitrogen dioxide'),
      ComponentInfo('SO₂', airPollution.components.so2, 'μg/m³', 'Sulfur dioxide'),
      ComponentInfo('CO', airPollution.components.co, 'μg/m³', 'Carbon monoxide'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(
                Icons.analytics_outlined,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Chi tiết thành phần',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...components.map((component) => _buildComponentRow(component)),
        ],
      ),
    );
  }

  Widget _buildComponentRow(ComponentInfo component) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  component.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  component.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${component.value.toStringAsFixed(1)} ${component.unit}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: airPollution.aqiColor.withOpacity(0.15),
        border: Border.all(
          color: airPollution.aqiColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: airPollution.aqiColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Khuyến nghị sức khỏe',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            airPollution.recommendation,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class ComponentInfo {
  final String name;
  final double value;
  final String unit;
  final String description;

  ComponentInfo(this.name, this.value, this.unit, this.description);
}