import 'dart:math';

import 'package:AirVibe/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:AirVibe/constants/app_colors.dart';
import 'package:AirVibe/constants/text_styles.dart';
import 'package:AirVibe/extensions/datetime.dart';
import 'package:AirVibe/models/weather.dart';
import 'package:AirVibe/providers/weekly-provider-weather.dart';
import 'package:AirVibe/utils/get_weather_icons.dart';
import 'package:AirVibe/widgets/subscript_text.dart';

class WeeklyForecastView extends ConsumerWidget {
  const WeeklyForecastView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyForecastData = ref.watch(weeklyWeatherProvider);
    return weeklyForecastData.when(
      data: (weeklyWeather){
        return ListView.builder(
          itemCount: weeklyWeather.daily.weatherCode.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index){
            final dayOfWeek = DateTime.parse(weeklyWeather.daily.time[index])
                .dayOfWeek;
            final date = weeklyWeather.daily.time[index];
            final temp = weeklyWeather.daily.temperature2mMax[index];
            final icon = weeklyWeather.daily.weatherCode[index];

            return WeeklyWeatherTile(
              day: date,
              date: dayOfWeek,
              temp: temp.toInt(),
              icon: getWeatherIcon2(icon),
            );
          },
        );
      }, 
      error: (error, stackTrace) {
        return Center(child: Text(error.toString()));
      },
      loading: () {
        return const Center(
          child: LoadingWidget()
        );
      },
    );
  }
}

class WeeklyWeatherTile extends StatelessWidget {
  const WeeklyWeatherTile({
    super.key,
    required this.day,
    required this.date, 
    required this.temp,
    required this.icon,
  });

  final String day;
  final String date;
  final int temp;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 20.0,
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 12.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Color(0xFFADD8E6).withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(date, style: TextStyles.h3),
              const SizedBox(height: 5),
              Text(day, style: TextStyles.subtitleText),
            ],
          ),

          SuperscriptText(
            text: temp.toString(), 
            superScript: "°C", 
            color: AppColors.white, 
            superscriptColor: AppColors.grey
          ),

          Image.asset(icon, width: 60,),
        ],
      ),
    );
  }
}