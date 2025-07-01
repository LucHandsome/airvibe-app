import 'package:flutter/material.dart';
import 'package:AirVibe/models/famous_cities.dart';
import 'package:AirVibe/screens/view-detail-screen.dart';
import 'package:AirVibe/widgets/famous_city_tile.dart';

class FamousCitiesView extends StatelessWidget {
  const FamousCitiesView({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: famousCities.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 20),
      itemBuilder: (context, index) {
        final city = famousCities[index];

        return InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => WeatherDetailScreen(
                      lat: city.lat,
                      lon: city.lon,
                    )));
          },
          child: FamousCityTile(
            index: index,
            city: city.name,
            lat: city.lat.toString(),
            lon: city.lon.toString(),
          ),
        );
      },
    );
  }
}

extension StringExtension on String {
  String get capitalize => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

