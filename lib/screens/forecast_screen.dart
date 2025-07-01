import 'package:flutter/material.dart';
import 'package:AirVibe/constants/text_styles.dart';
import 'package:AirVibe/extensions/datetime.dart';
import 'package:AirVibe/views/gradient_container.dart';
import 'package:AirVibe/views/hourly_forecast.dart';
import 'package:AirVibe/views/weekly_forecast_view.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        children: [
          const Align(
            alignment: Alignment.center,
            child: Text('Forecast Report', style: TextStyles.h1,)
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Today', style: TextStyles.h3,),
              Text(DateTime.now().dateTime, style: TextStyles.subtitleText),
            ],
          ),
          const SizedBox(height: 20),
          const HourlyForecastView(),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Next Forecast', style: TextStyles.h1), 
              Icon(Icons.calendar_month_outlined, color: Colors.white),
            ],
          ),
          const SizedBox(height: 20),
          const WeeklyForecastView(),
        ],
      ),
    );
  }
}