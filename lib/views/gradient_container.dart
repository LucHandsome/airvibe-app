import 'package:flutter/material.dart';
import '/constants/app_colors.dart';

class GradientContainer extends StatelessWidget {
  const GradientContainer({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // Updated colors to match ChatScreen's gradient
            colors: [
              Color(0xFF1E3A8A), // Blue-900 from ChatScreen
              Color(0xFF3B82F6), // Blue-500 from ChatScreen
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 36.0,
          ),
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                  children,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}