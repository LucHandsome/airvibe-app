import 'package:AirVibe/services/api_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentWeatherProvider = FutureProvider.autoDispose((ref){
  return ApiHelper.getCurrentWeather();
}); 