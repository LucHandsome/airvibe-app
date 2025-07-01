import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:AirVibe/constants/text_styles.dart';
import 'package:AirVibe/extensions/datetime.dart';
import 'package:AirVibe/providers/current-provider-weather.dart';
import 'package:AirVibe/services/api_helper.dart';
import 'package:AirVibe/services/geocoding_service.dart';
import 'package:AirVibe/views/gradient_container.dart';
import 'package:AirVibe/views/hourly_forecast.dart';
import 'package:AirVibe/views/weather_info.dart';
// import 'package:AirVibe/services/geolocator.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherData = ref.watch(currentWeatherProvider);
    return weatherData.when(
      data: (weather) {
        return GradientContainer(
          children: [
            const SizedBox(width: double.infinity),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FutureBuilder(
                  future: getPlaceFromCoordinates(ApiHelper.lat, ApiHelper.lon),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return const Text('Không xác định địa điểm',
                          style: TextStyles.h1);
                    } else {
                      return Text(snapshot.data!, style: TextStyles.h1);
                    }
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  DateTime.now().dateTime,
                  style: TextStyles.subtitleText,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 260,
                  child:
                      Image.asset(
                          'assets/icons/${weather.weather[0].icon.replaceAll('n', 'd')}.png'),
                      // Lottie.asset('assets/lottie/sunny.json'),
                ),
                const SizedBox(height: 40),
                Text(
                  '${weather.weather[0].description[0].toUpperCase()}${weather.weather[0].description.substring(1)}',
                  style: TextStyles.h2,
                ),
              ],
            ),
            const SizedBox(height: 40),
            WeatherInfo(
              weather: weather,
            ),

            const SizedBox(height: 40),

            //!View Hourly Forecast
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today',
                  style: TextStyles.h2,
                ),
                TextButton(
                    onPressed: () {}, child: const Text('View full forecast')),
              ],
            ),

            const SizedBox(
              height: 15,
            ),

            const HourlyForecastView(),
          ],
        );
      },
      error: (error, stackTrace) {
        return Center(
          child: Text(error.toString()),
        );
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
