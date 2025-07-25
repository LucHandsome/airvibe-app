import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart';

@immutable
class AirPollution {
  final int aqi;
  final AirComponents components;
  final String status;
  final String description;

  const AirPollution({
    required this.aqi,
    required this.components,
    required this.status,
    required this.description,
  });

  factory AirPollution.fromJson(Map<String, dynamic> json) {
    return AirPollution(
      aqi: json['aqi'] as int,
      components: AirComponents.fromJson(json['components'] as Map<String, dynamic>),
      status: json['status'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aqi': aqi,
      'components': components.toJson(),
      'status': status,
      'description': description,
    };
  }
}

@immutable
class AirComponents {
  final double co;      // Carbon monoxide (μg/m³)
  final double no;      // Nitric oxide (μg/m³)  
  final double no2;     // Nitrogen dioxide (μg/m³)
  final double o3;      // Ozone (μg/m³)
  final double so2;     // Sulphur dioxide (μg/m³)
  final double pm2_5;   // Fine particles matter (μg/m³)
  final double pm10;    // Coarse particulate matter (μg/m³)
  final double nh3;     // Ammonia (μg/m³)

  const AirComponents({
    required this.co,
    required this.no,
    required this.no2,
    required this.o3,
    required this.so2,
    required this.pm2_5,
    required this.pm10,
    required this.nh3,
  });

  factory AirComponents.fromJson(Map<String, dynamic> json) {
    return AirComponents(
      co: (json['co'] as num).toDouble(),
      no: (json['no'] as num).toDouble(),
      no2: (json['no2'] as num).toDouble(),
      o3: (json['o3'] as num).toDouble(),
      so2: (json['so2'] as num).toDouble(),
      pm2_5: (json['pm2_5'] as num).toDouble(),
      pm10: (json['pm10'] as num).toDouble(),
      nh3: (json['nh3'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'co': co,
      'no': no,
      'no2': no2,
      'o3': o3,
      'so2': so2,
      'pm2_5': pm2_5,
      'pm10': pm10,
      'nh3': nh3,
    };
  }
}

extension AirQualityHelper on AirPollution {
  /// Trả về màu tương ứng với chỉ số AQI
  Color get aqiColor {
    if (aqi <= 50) return const Color(0xFF4CAF50); // Green - Good
    if (aqi <= 100) return const Color(0xFF8BC34A); // Light Green - Fair  
    if (aqi <= 150) return const Color(0xFFFFC107); // Amber - Moderate
    if (aqi <= 200) return const Color(0xFFFF9800); // Orange - Poor
    if (aqi <= 300) return const Color(0xFFF44336); // Red - Very Poor
    return const Color(0xFF9C27B0); // Purple - Extremely Poor
  }

  /// Trả về mức độ chất lượng không khí bằng tiếng Việt
  String get qualityLevel {
    if (aqi <= 50) return 'Tốt';
    if (aqi <= 100) return 'Khá tốt';
    if (aqi <= 150) return 'Vừa phải';
    if (aqi <= 200) return 'Kém';
    if (aqi <= 300) return 'Rất kém';
    return 'Cực kỳ kém';
  }

  /// Trả về lời khuyên cho người dùng
  String get recommendation {
    if (aqi <= 50) return 'Chất lượng không khí tốt. An toàn cho mọi hoạt động ngoài trời.';
    if (aqi <= 100) return 'Chất lượng không khí khá tốt. Phù hợp cho hầu hết các hoạt động.';
    if (aqi <= 150) return 'Người nhạy cảm nên hạn chế hoạt động ngoài trời kéo dài.';
    if (aqi <= 200) return 'Mọi người nên hạn chế hoạt động ngoài trời.';
    if (aqi <= 300) return 'Tránh hoạt động ngoài trời. Đeo khẩu trang khi ra ngoài.';
    return 'Nguy hiểm! Ở trong nhà và đóng cửa sổ.';
  }
}