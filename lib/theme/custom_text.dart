import 'package:flutter/material.dart';
import 'package:gameconsign/theme/color.dart';

class CustomText extends StatelessWidget {
  const CustomText(
      {super.key, required this.text, this.isBold = false, this.colour});

  final String text;
  final bool isBold;
  final Color? colour;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: colour ?? CustomColor.white,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
