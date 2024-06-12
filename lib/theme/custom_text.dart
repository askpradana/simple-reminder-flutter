import 'package:flutter/material.dart';
import 'package:gaemcosign/theme/color.dart';

class CustomText extends StatelessWidget {
  const CustomText({super.key, required this.text, this.isBold = false});

  final String text;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: CustomColor.white,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
