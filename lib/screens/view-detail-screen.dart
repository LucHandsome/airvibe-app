import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AirVibe/providers/get-weather-by-city-provider-weather.dart';
import 'package:AirVibe/providers/get_weather_by_city_provider_weather.dart';
import 'package:AirVibe/services/api_helper.dart';
import 'package:AirVibe/services/geocoding_service.dart';
import 'package:AirVibe/views/weather_info.dart';

import '/constants/text_styles.dart';
import '/extensions/datetime.dart';
import '/extensions/strings.dart';
// import '/providers/get_city_forecast_provider.dart';
// import '/screens/weather_screen/weather_info.dart';
import '/views/gradient_container.dart';

class WeatherDetailScreen extends ConsumerWidget {
  const WeatherDetailScreen({
    super.key,
    required this.lat,
    required this.lon,
  });

  final String lat;
  final String lon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherData = ref.watch(getWeatherByLatLonProvider((lat, lon)));

    return Scaffold(
      body: weatherData.when(
        data: (weather) {
          return GradientContainer(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30, width: double.infinity),
                  FutureBuilder(
                    future: getPlaceFromCoordinates(
                        double.parse(lat), double.parse(lon)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError || !snapshot.hasData) {
                        return Text('Không xác định địa điểm',
                            style: TextStyles.h1);
                      } else {
                        return Text(
                          snapshot.data!.split(',').last.trim(),
                          style: TextStyles.h1,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(DateTime.now().dateTime, style: TextStyles.subtitleText),
                  const SizedBox(height: 50),
                  SizedBox(
                    height: 300,
                    child: Image.asset(
                      'assets/icons/${weather.weather[0].icon.replaceAll('n', 'd')}.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Text(
                    weather.weather[0].description.capitalize,
                    style: TextStyles.h2,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              WeatherInfo(weather: weather),
              const SizedBox(height: 15),
            ],
          );
        },
        error: (error, stackTrace) =>
            const Center(child: Text('An error has occurred')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
