// lib/widgets/module_card.dart
import 'package:flutter/material.dart';

class ModuleCard extends StatelessWidget {
  final String title; // e.g. "HIV/ADIS"
  final String subtitle; // e.g. "Module 1"
  final String imagePath;
  final VoidCallback onTap;

  const ModuleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // the card will occupy available width from grid
    const cornerRadius = 16.0;

    return GestureDetector(
      onTap: onTap,
      child: Transform.rotate(
        angle: -0.02, // slight diagonal
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(cornerRadius),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(cornerRadius),
            child: Container(
              // background image; white base is not needed because we use image,
              // but to match Figma we keep a white overlay feel via gradient below
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // bottom-to-top dark gradient to make text readable
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(0,0,0,0.02),
                          Color.fromRGBO(0,0,0,0.42),
                        ],
                      ),
                    ),
                  ),

                  // module label (top-left small pill)
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255,255,255,0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        subtitle,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF005C8F)),
                      ),
                    ),
                  ),

                  // title near bottom-left
                  Positioned(
                    left: 12,
                    bottom: 12,
                    right: 12,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        shadows: [Shadow(color: Colors.black45, offset: Offset(0, 2), blurRadius: 6)],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // small "More..." bottom-right
                  const Positioned(
                    bottom: 10,
                    right: 12,
                    child: Text('More...', style: TextStyle(color: Color.fromRGBO(255,255,255,0.9), fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
