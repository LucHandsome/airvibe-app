import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AirVibe/constants/app_colors.dart';
import 'package:AirVibe/constants/text_styles.dart';
// import 'package:AirVibe/providers/get-weather-by-city-provider-weather.dart';
import 'package:AirVibe/providers/get_weather_by_city_provider_weather.dart';
import 'package:AirVibe/utils/get_weather_icons.dart';

class FamousCityTile extends ConsumerWidget {
  const FamousCityTile({
    super.key, 
    required this.city, 
    required this.index,
    required this.lat,
    required this.lon,
    });

  final String city;
  final int index;
  final String lat;
  final String lon;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherData = ref.watch(getWeatherByLatLonProvider((lat, lon)));
    print('Weather Data for $city: $weatherData');
    return weatherData.when(
      data: (weather){
        return Material(
          color: index == 0 ? AppColors.lightBlue : AppColors.accentBlue,
          elevation: index == 0 ? 8 : 0,
          borderRadius: BorderRadius.circular(25.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(  
              horizontal: 18.0,
              vertical: 24.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column( 
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${weather.main.temp.round().toString()}°", 
                            style: TextStyles.h2,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${weather.weather[0].description[0].toUpperCase()}${weather.weather[0].description.substring(1)}',
                            style: TextStyles.subtitleText, 
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    Image.asset(  
                      getWeatherIcon(
                        weatherCode: weather.weather[0].id
                      ),
                      width: 50,

                    ),
                  ],
                ),
                Text(
                  city,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(.8),
                    fontWeight: FontWeight.w400,
                  )
                ),
              ], 
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        return Center(child: Text(error.toString()));
      } ,
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    );
  }
}
