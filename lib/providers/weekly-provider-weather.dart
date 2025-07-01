import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AirVibe/services/api_helper.dart';

final weeklyWeatherProvider = FutureProvider.autoDispose((ref) {
  return ApiHelper.getWeeklyWeather();
});