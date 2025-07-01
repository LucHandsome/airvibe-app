import 'package:AirVibe/models/weather.dart';
import 'package:AirVibe/services/api_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final getWeatherByCityProvider = FutureProvider.autoDispose.family<Weather, String>((ref, cityName) {
  return ApiHelper.getWeatherByCityName(cityName: cityName);
});