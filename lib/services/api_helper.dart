import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show immutable;

import '/constants/constants.dart';
import '/models/hourly_weather.dart';
import '/models/weather.dart';
import '/models/weekly_weather.dart';
import '/services/geolocator.dart';
import '/utils/logging.dart';

@immutable
class ApiHelper {
  static const baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const weeklyWeatherUrl =
      'https://api.open-meteo.com/v1/forecast?current=&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto';

  static double lat = 0.0;
  static double lon = 0.0;
  static final dio = Dio();

  static Future<void> fetchLocation() async {
    final location = await getLocation();
    lat = location.latitude;
    lon = location.longitude;
  }

  //Current weather
  static Future<Weather> getCurrentWeather() async {
    await fetchLocation();
    final url = _constructWeatherUrl();
    final response = await _fetchData(url);
    return Weather.fromJson(response);
  }

  //Hourly weather
  static Future<HourlyWeather> getHourlyWeather() async {
    await fetchLocation();
    final url = _constructForecastUrl();
    final response = await _fetchData(url);
    return HourlyWeather.fromJson(response);
  }

  //Weekly weather
  static Future<WeeklyWeather> getWeeklyWeather() async {
    await fetchLocation();
    final url = _constructWeeklyWeatherUrl();
    final response = await _fetchData(url);
    return WeeklyWeather.fromJson(response);
  }

  //Weather by city name
  static Future<Weather> getWeatherByCityName({
    required String cityName,
  }) async {
    final url = _constructWeatherUrlByCity(cityName);
    final response = await _fetchData(url);
    return Weather.fromJson(response);
  }

  // Weather by lat & lon (cho FamousCityTile)
  static Future<Weather> getWeatherByLatLon({
    required String lat,
    required String lon,
  }) async {
    final url =
        '$baseUrl/weather?lat=$lat&lon=$lon&units=metric&appid=${Constants.apiKey}&lang=vi';
    final response = await _fetchData(url);
    return Weather.fromJson(response);
  }

  static String _constructWeatherUrl() =>
      '$baseUrl/weather?lat=$lat&lon=$lon&units=metric&appid=${Constants.apiKey}&lang=vi';

  static String _constructForecastUrl() =>
      '$baseUrl/forecast?lat=$lat&lon=$lon&units=metric&appid=${Constants.apiKey}&lang=vi';

  static String _constructWeatherUrlByCity(String city) =>
      '$baseUrl/weather?q=$city&units=metric&appid=${Constants.apiKey}&lang=vi';

  static String _constructWeeklyWeatherUrl() =>
      '$weeklyWeatherUrl&latitude=$lat&longitude=$lon&lang=vi';

  static Future<Map<String, dynamic>> _fetchData(String url) async {
    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        printWarning('Failed to fetch data from $url: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      printWarning('Error fetching data from $url: $e');
      throw Exception('Error fetching data');
    }
  }
}
