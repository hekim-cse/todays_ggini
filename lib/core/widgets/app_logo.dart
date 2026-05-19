import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double topPadding;
  const AppLogo({super.key, this.size = 250, this.topPadding = 20});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: topPadding), 
        Image.asset('assets/images/top.png', width: size),

      ],
    );
  }
}
