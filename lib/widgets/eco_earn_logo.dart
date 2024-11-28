import 'package:flutter/material.dart';

class EcoEarnLogo extends StatelessWidget {
  final double height;
  
  const EcoEarnLogo({
    super.key,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: height,
      fit: BoxFit.contain,
    );
  }
} 