import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AirVibe/models/weather.dart';
import 'package:AirVibe/services/api_helper.dart';

final getWeatherByLatLonProvider = FutureProvider.autoDispose
    .family<Weather, (String lat, String lon)>((ref, coords) async {
  return ApiHelper.getWeatherByLatLon(lat: coords.$1, lon: coords.$2);
});
