// lib/models/health_activities.dart
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart';

@immutable
class HealthActivities {
  final LocationInfo location;
  final HealthData health;
  final ActivitiesData activities;
  final String lastUpdated;

  const HealthActivities({
    required this.location,
    required this.health,
    required this.activities,
    required this.lastUpdated,
  });

  factory HealthActivities.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return HealthActivities(
      location: LocationInfo.fromJson(data['location']),
      health: HealthData.fromJson(data['health']),
      activities: ActivitiesData.fromJson(data['activities']),
      lastUpdated: data['lastUpdated'],
    );
  }
}

@immutable
class LocationInfo {
  final double lat;
  final double lon;
  final String name;
  final String country;

  const LocationInfo({
    required this.lat,
    required this.lon,
    required this.name,
    required this.country,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      lat: json['lat']?.toDouble() ?? 0.0,
      lon: json['lon']?.toDouble() ?? 0.0,
      name: json['name'] ?? '',
      country: json['country'] ?? '',
    );
  }
}

@immutable
class HealthData {
  final HealthItem arthritis;
  final HealthItem sinusPressure;
  final HealthItem commonCold;
  final HealthItem flu;
  final HealthItem migraine;
  final HealthItem asthma;
  final HealthItem allergies;

  const HealthData({
    required this.arthritis,
    required this.sinusPressure,
    required this.commonCold,
    required this.flu,
    required this.migraine,
    required this.asthma,
    required this.allergies,
  });

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      arthritis: HealthItem.fromJson(json['arthritis']),
      sinusPressure: HealthItem.fromJson(json['sinusPressure']),
      commonCold: HealthItem.fromJson(json['commonCold']),
      flu: HealthItem.fromJson(json['flu']),
      migraine: HealthItem.fromJson(json['migraine']),
      asthma: HealthItem.fromJson(json['asthma']),
      allergies: HealthItem.fromJson(json['allergies']),
    );
  }

  List<HealthItem> get allItems => [
    arthritis,
    sinusPressure,
    commonCold,
    flu,
    migraine,
    asthma,
    allergies,
  ];
}

@immutable
class ActivitiesData {
  final OutdoorActivities outdoor;
  final TravelActivities travel;
  final HomeGardenActivities homeGarden;
  final PestActivities pests;

  const ActivitiesData({
    required this.outdoor,
    required this.travel,
    required this.homeGarden,
    required this.pests,
  });

  factory ActivitiesData.fromJson(Map<String, dynamic> json) {
    return ActivitiesData(
      outdoor: OutdoorActivities.fromJson(json['outdoor']),
      travel: TravelActivities.fromJson(json['travel']),
      homeGarden: HomeGardenActivities.fromJson(json['homeGarden']),
      pests: PestActivities.fromJson(json['pests']),
    );
  }
}

@immutable
class OutdoorActivities {
  final ActivityItem fishing;
  final ActivityItem running;
  final ActivityItem golf;
  final ActivityItem cycling;
  final ActivityItem beachPool;
  final ActivityItem stargazing;
  final ActivityItem hiking;

  const OutdoorActivities({
    required this.fishing,
    required this.running,
    required this.golf,
    required this.cycling,
    required this.beachPool,
    required this.stargazing,
    required this.hiking,
  });

  factory OutdoorActivities.fromJson(Map<String, dynamic> json) {
    return OutdoorActivities(
      fishing: ActivityItem.fromJson(json['fishing']),
      running: ActivityItem.fromJson(json['running']),
      golf: ActivityItem.fromJson(json['golf']),
      cycling: ActivityItem.fromJson(json['cycling']),
      beachPool: ActivityItem.fromJson(json['beachPool']),
      stargazing: ActivityItem.fromJson(json['stargazing']),
      hiking: ActivityItem.fromJson(json['hiking']),
    );
  }

  List<ActivityItem> get allItems => [
    fishing,
    running,
    golf,
    cycling,
    beachPool,
    stargazing,
    hiking,
  ];
}

@immutable
class TravelActivities {
  final ActivityItem airTravel;
  final ActivityItem driving;

  const TravelActivities({
    required this.airTravel,
    required this.driving,
  });

  factory TravelActivities.fromJson(Map<String, dynamic> json) {
    return TravelActivities(
      airTravel: ActivityItem.fromJson(json['airTravel']),
      driving: ActivityItem.fromJson(json['driving']),
    );
  }
}

@immutable
class HomeGardenActivities {
  final ActivityItem mowing;
  final ActivityItem composting;
  final ActivityItem outdoorEntertainment;

  const HomeGardenActivities({
    required this.mowing,
    required this.composting,
    required this.outdoorEntertainment,
  });

  factory HomeGardenActivities.fromJson(Map<String, dynamic> json) {
    return HomeGardenActivities(
      mowing: ActivityItem.fromJson(json['mowing']),
      composting: ActivityItem.fromJson(json['composting']),
      outdoorEntertainment: ActivityItem.fromJson(json['outdoorEntertainment']),
    );
  }
}

@immutable
class PestActivities {
  final ActivityItem mosquito;
  final ActivityItem indoorPests;
  final ActivityItem outdoorPests;

  const PestActivities({
    required this.mosquito,
    required this.indoorPests,
    required this.outdoorPests,
  });

  factory PestActivities.fromJson(Map<String, dynamic> json) {
    return PestActivities(
      mosquito: ActivityItem.fromJson(json['mosquito']),
      indoorPests: ActivityItem.fromJson(json['indoorPests']),
      outdoorPests: ActivityItem.fromJson(json['outdoorPests']),
    );
  }
}

@immutable
class HealthItem {
  final int score;
  final String level;
  final String color;
  final String description;
  final String advice;

  const HealthItem({
    required this.score,
    required this.level,
    required this.color,
    required this.description,
    required this.advice,
  });

  factory HealthItem.fromJson(Map<String, dynamic> json) {
    return HealthItem(
      score: json['score'] ?? 0,
      level: json['level'] ?? '',
      color: json['color'] ?? '#000000',
      description: json['description'] ?? '',
      advice: json['advice'] ?? '',
    );
  }

  Color get levelColor {
    return Color(int.parse(color.substring(1, 7), radix: 16) + 0xFF000000);
  }
}

@immutable
class ActivityItem {
  final int score;
  final String level;
  final String color;
  final String description;

  const ActivityItem({
    required this.score,
    required this.level,
    required this.color,
    required this.description,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      score: json['score'] ?? 0,
      level: json['level'] ?? '',
      color: json['color'] ?? '#000000',
      description: json['description'] ?? '',
    );
  }

  Color get levelColor {
    return Color(int.parse(color.substring(1, 7), radix: 16) + 0xFF000000);
  }
}