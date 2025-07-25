import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AirVibe/models/air_pollution.dart';
import 'package:AirVibe/services/api_helper.dart';

// Provider cho air pollution hiện tại
final currentAirPollutionProvider = FutureProvider<AirPollution>((ref) async {
  return await ApiHelper.getCurrentAirPollution();
});

// Provider cho air pollution theo lat/lon
final airPollutionByLatLonProvider = FutureProvider.family<AirPollution, (String, String)>((ref, coords) async {
  final (lat, lon) = coords;
  return await ApiHelper.getAirPollutionByLatLon(lat: lat, lon: lon);
});