import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final String? decorAsset;
  const GradientBackground({super.key, required this.child, this.decorAsset});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Stack(
      children: [
        // Gradient
        Container(
          width: mq.size.width,
          height: mq.size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE6F2FB), Color(0xFF0C63A4)],
              stops: [0.0, 1.0],
            ),
          ),
        ),
        // Optional decorative image
        if (decorAsset != null)
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                decorAsset!,
                width: mq.size.width * 0.6,
                fit: BoxFit.cover,
              ),
            ),
          ),
        SafeArea(child: child),
      ],
    );
  }
}
