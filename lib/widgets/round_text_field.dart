import 'package:flutter/material.dart';
import 'package:AirVibe/constants/app_colors.dart';

class RoundTextField extends StatelessWidget {
  const RoundTextField({
    super.key,
    required this.controller,});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xFFADD8E6).withOpacity(0.2),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.only(left: 20, top: 10),
          border: InputBorder.none,
          fillColor: Colors.white,
          focusColor: Colors.white,
          hintText: 'Search',
          hintStyle: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w400,
          )
        ),
      ),
    );
  }
}