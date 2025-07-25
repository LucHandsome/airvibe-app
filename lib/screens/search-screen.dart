import 'package:flutter/material.dart';
import 'package:AirVibe/constants/app_colors.dart';
import 'package:AirVibe/constants/text_styles.dart';
import 'package:AirVibe/views/famous_cities_view.dart';
import 'package:AirVibe/views/gradient_container.dart';
import 'package:AirVibe/widgets/round_text_field.dart';

class ScreenSearch extends StatefulWidget {
  const ScreenSearch({super.key});

  @override
  State<ScreenSearch> createState() => _ScreenSearchState();
}

class _ScreenSearchState extends State<ScreenSearch> {
  late final TextEditingController _controller;

  @override
  void initState() {
    // TODO: implement initState
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Pick Location', style: TextStyles.h1,),
                SizedBox(height: 30),
                Text(
                  'Find the area or city that you want to know the detailed weather info at this time.',
                  style: TextStyles.subtitleText,
                  textAlign: TextAlign.center,
                ),
              ],
          ),      
          const SizedBox(height: 40),

          Row(
            children: [
              Expanded(
                child: RoundTextField(
                  controller: _controller,
                ),
              ),
              const SizedBox(width: 15),
              const LocationIcon(),
            ],
          ),

          const SizedBox(height: 30),
            //Famous cities view
          const FamousCitiesView(),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class LocationIcon extends StatelessWidget {
  const LocationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      width: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xFFADD8E6).withOpacity(0.2),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: const Icon(
        Icons.location_on_outlined,
        color: Colors.white,
      ),
    );
  }
}