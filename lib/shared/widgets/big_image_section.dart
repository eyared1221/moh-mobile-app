import 'package:flutter/material.dart';

class BigImageSection extends StatelessWidget {
  const BigImageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/images/guest.png",
      width: double.infinity,
      height: 260,
      fit: BoxFit.cover, // FULL WIDTH, NO SPACES
    );
  }
}
