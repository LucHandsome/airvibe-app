// lib/providers/health_activities_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AirVibe/models/health_activities.dart';
import 'package:AirVibe/services/api_helper.dart';

// Provider cho health activities hiện tại
final currentHealthActivitiesProvider = FutureProvider<HealthActivities>((ref) async {
  return await ApiHelper.getCurrentHealthActivities();
});

// Provider cho health activities theo lat/lon
final healthActivitiesByLatLonProvider = 
    FutureProvider.family<HealthActivities, (String, String)>((ref, coords) async {
  final (lat, lon) = coords;
  return await ApiHelper.getHealthActivitiesByLatLon(lat: lat, lon: lon);
});