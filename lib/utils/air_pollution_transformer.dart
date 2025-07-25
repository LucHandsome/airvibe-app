// lib/utils/air_pollution_transformer.dart
import '../models/air_pollution.dart';
import 'aqi_calculator.dart'; // Import calculator

class AirPollutionTransformer {
  /// Transform dữ liệu từ BE response sang AirPollution model
  static AirPollution fromBackendResponse(Map<String, dynamic> backendData) {
    // Kiểm tra success và có data không
    if (!backendData['success'] || backendData['data'] == null) {
      throw Exception('Invalid backend response');
    }

    final data = backendData['data'];
    final current = data['current'];
    final aqi = current['aqi'];
    final components = current['components'];

    // Transform components
    final transformedComponents = AirComponents(
      co: _parseDouble(components['co']?['value'], fallback: 0.0),
      no: 0.0, // BE không có field này, set default
      no2: _parseDouble(components['no2']?['value'], fallback: 0.0),
      o3: _parseDouble(components['o3']?['value'], fallback: 0.0),
      so2: _parseDouble(components['so2']?['value'], fallback: 0.0),
      pm2_5: _parseDouble(components['pm2_5']?['value'], fallback: 0.0),
      pm10: _parseDouble(components['pm10']?['value'], fallback: 0.0),
      nh3: 0.0, // BE không có field này, set default
    );

    // Tính AQI từ từng component và lấy max
    final pm25Aqi = AQICalculator.calculateAQIFromPM25(transformedComponents.pm2_5);
    final pm10Aqi = AQICalculator.calculateAQIFromPM10(transformedComponents.pm10);
    final o3Aqi = AQICalculator.calculateAQIFromO3(transformedComponents.o3);
    final so2Aqi = AQICalculator.calculateAQIFromSO2(transformedComponents.so2);
    final no2Aqi = AQICalculator.calculateAQIFromNO2(transformedComponents.no2);
    
    // AQI overall = max của tất cả components
    final calculatedAqi = [pm25Aqi, pm10Aqi, o3Aqi, so2Aqi, no2Aqi].reduce((a, b) => a > b ? a : b);

    return AirPollution(
      aqi: calculatedAqi, // ← Dùng AQI tính toán thay vì aqi['index']
      components: transformedComponents,
      status: aqi['level'] ?? 'Unknown',
      description: aqi['description'] ?? 'Không có thông tin',
    );
  }

  /// Safely parse double values
  static double _parseDouble(dynamic value, {double fallback = 0.0}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  /// Transform từ AirPollution model thành format FE mong muốn (nếu cần)
  static Map<String, dynamic> toFrontendFormat(AirPollution airPollution) {
    return {
      'aqi': airPollution.aqi,
      'components': {
        'co': airPollution.components.co,
        'no': airPollution.components.no,
        'no2': airPollution.components.no2,
        'o3': airPollution.components.o3,
        'so2': airPollution.components.so2,
        'pm2_5': airPollution.components.pm2_5,
        'pm10': airPollution.components.pm10,
        'nh3': airPollution.components.nh3,
      },
      'status': airPollution.status,
      'description': airPollution.description,
    };
  }
}