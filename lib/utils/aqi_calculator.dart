// lib/utils/aqi_calculator.dart
import 'dart:math' as math;

class AQICalculator {
  /// Tính AQI từ PM2.5 theo chuẩn US EPA
  static int calculateAQIFromPM25(double pm25) {
    // AQI breakpoints cho PM2.5 (µg/m³)
    final breakpoints = [
      {'cLow': 0.0, 'cHigh': 12.0, 'iLow': 0, 'iHigh': 50},      // Good
      {'cLow': 12.1, 'cHigh': 35.4, 'iLow': 51, 'iHigh': 100},   // Moderate  
      {'cLow': 35.5, 'cHigh': 55.4, 'iLow': 101, 'iHigh': 150},  // USG
      {'cLow': 55.5, 'cHigh': 150.4, 'iLow': 151, 'iHigh': 200}, // Unhealthy
      {'cLow': 150.5, 'cHigh': 250.4, 'iLow': 201, 'iHigh': 300}, // Very Unhealthy
      {'cLow': 250.5, 'cHigh': 350.4, 'iLow': 301, 'iHigh': 400}, // Hazardous
      {'cLow': 350.5, 'cHigh': 500.4, 'iLow': 401, 'iHigh': 500}, // Hazardous
    ];

    // Tìm breakpoint phù hợp
    for (var bp in breakpoints) {
      if (pm25 >= bp['cLow']! && pm25 <= bp['cHigh']!) {
        // Công thức tính AQI
        final iLow = bp['iLow']! as int;
        final iHigh = bp['iHigh']! as int;
        final cLow = bp['cLow']! as double;
        final cHigh = bp['cHigh']! as double;
        
        final aqi = ((iHigh - iLow) / (cHigh - cLow)) * (pm25 - cLow) + iLow;
        return aqi.round();
      }
    }

    // Nếu vượt quá 500, trả về 500
    return pm25 > 500.4 ? 500 : 0;
  }

  /// Tính AQI từ tất cả components và lấy max
  static int calculateAQIFromAllComponents(Map<String, double> components) {
    int maxAqi = 0;
    
    // AQI từ PM2.5
    if (components['pm2_5'] != null) {
      maxAqi = math.max(maxAqi, calculateAQIFromPM25(components['pm2_5']!));
    }
    
    // AQI từ PM10 
    if (components['pm10'] != null) {
      maxAqi = math.max(maxAqi, calculateAQIFromPM10(components['pm10']!));
    }
    
    // AQI từ O3
    if (components['o3'] != null) {
      maxAqi = math.max(maxAqi, calculateAQIFromO3(components['o3']!));
    }

    return maxAqi;
  }

  /// Tính AQI từ PM10
  static int calculateAQIFromPM10(double pm10) {
    final breakpoints = [
      {'cLow': 0.0, 'cHigh': 54.0, 'iLow': 0, 'iHigh': 50},
      {'cLow': 55.0, 'cHigh': 154.0, 'iLow': 51, 'iHigh': 100},
      {'cLow': 155.0, 'cHigh': 254.0, 'iLow': 101, 'iHigh': 150},
      {'cLow': 255.0, 'cHigh': 354.0, 'iLow': 151, 'iHigh': 200},
      {'cLow': 355.0, 'cHigh': 424.0, 'iLow': 201, 'iHigh': 300},
      {'cLow': 425.0, 'cHigh': 604.0, 'iLow': 301, 'iHigh': 500},
    ];

    for (var bp in breakpoints) {
      if (pm10 >= bp['cLow']! && pm10 <= bp['cHigh']!) {
        final iLow = bp['iLow']! as int;
        final iHigh = bp['iHigh']! as int;
        final cLow = bp['cLow']! as double;
        final cHigh = bp['cHigh']! as double;
        
        final aqi = ((iHigh - iLow) / (cHigh - cLow)) * (pm10 - cLow) + iLow;
        return aqi.round();
      }
    }
    return pm10 > 604 ? 500 : 0;
  }

  /// Tính AQI từ O3
  static int calculateAQIFromO3(double o3) {
    final breakpoints = [
      {'cLow': 0.0, 'cHigh': 124.0, 'iLow': 0, 'iHigh': 50},
      {'cLow': 125.0, 'cHigh': 164.0, 'iLow': 51, 'iHigh': 100},
      {'cLow': 165.0, 'cHigh': 204.0, 'iLow': 101, 'iHigh': 150},
      {'cLow': 205.0, 'cHigh': 404.0, 'iLow': 151, 'iHigh': 200},
      {'cLow': 405.0, 'cHigh': 604.0, 'iLow': 201, 'iHigh': 300},
    ];

    for (var bp in breakpoints) {
      if (o3 >= bp['cLow']! && o3 <= bp['cHigh']!) {
        final iLow = bp['iLow']! as int;
        final iHigh = bp['iHigh']! as int;
        final cLow = bp['cLow']! as double;
        final cHigh = bp['cHigh']! as double;
        
        final aqi = ((iHigh - iLow) / (cHigh - cLow)) * (o3 - cLow) + iLow;
        return aqi.round();
      }
    }
    return o3 > 604 ? 300 : 0;
  }

  /// Tính AQI từ SO2
  static int calculateAQIFromSO2(double so2) {
    final breakpoints = [
      {'cLow': 0.0, 'cHigh': 35.0, 'iLow': 0, 'iHigh': 50},
      {'cLow': 36.0, 'cHigh': 75.0, 'iLow': 51, 'iHigh': 100},
      {'cLow': 76.0, 'cHigh': 185.0, 'iLow': 101, 'iHigh': 150},
      {'cLow': 186.0, 'cHigh': 304.0, 'iLow': 151, 'iHigh': 200},
      {'cLow': 305.0, 'cHigh': 604.0, 'iLow': 201, 'iHigh': 300},
    ];

    for (var bp in breakpoints) {
      if (so2 >= bp['cLow']! && so2 <= bp['cHigh']!) {
        final iLow = bp['iLow']! as int;
        final iHigh = bp['iHigh']! as int;
        final cLow = bp['cLow']! as double;
        final cHigh = bp['cHigh']! as double;
        
        final aqi = ((iHigh - iLow) / (cHigh - cLow)) * (so2 - cLow) + iLow;
        return aqi.round();
      }
    }
    return so2 > 604 ? 300 : 0;
  }

  /// Tính AQI từ NO2
  static int calculateAQIFromNO2(double no2) {
    final breakpoints = [
      {'cLow': 0.0, 'cHigh': 53.0, 'iLow': 0, 'iHigh': 50},
      {'cLow': 54.0, 'cHigh': 100.0, 'iLow': 51, 'iHigh': 100},
      {'cLow': 101.0, 'cHigh': 360.0, 'iLow': 101, 'iHigh': 150},
      {'cLow': 361.0, 'cHigh': 649.0, 'iLow': 151, 'iHigh': 200},
      {'cLow': 650.0, 'cHigh': 1249.0, 'iLow': 201, 'iHigh': 300},
    ];

    for (var bp in breakpoints) {
      if (no2 >= bp['cLow']! && no2 <= bp['cHigh']!) {
        final iLow = bp['iLow']! as int;
        final iHigh = bp['iHigh']! as int;
        final cLow = bp['cLow']! as double;
        final cHigh = bp['cHigh']! as double;
        
        final aqi = ((iHigh - iLow) / (cHigh - cLow)) * (no2 - cLow) + iLow;
        return aqi.round();
      }
    }
    return no2 > 1249 ? 300 : 0;
  }
}