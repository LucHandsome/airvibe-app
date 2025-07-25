import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animation ở giữa
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie/paperplane.json',
                width: 180,
                height: 180,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
