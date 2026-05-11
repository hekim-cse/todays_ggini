import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double topPadding;
  const AppLogo({super.key, this.size = 120, this.topPadding = 20});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: topPadding), 
        Image.asset('assets/images/pic.png', width: size),
        const SizedBox(height: 8),
        Image.asset('assets/images/logo.png', width: size),
      ],
    );
  }
}