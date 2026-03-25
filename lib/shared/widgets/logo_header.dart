import 'package:flutter/material.dart';

class LogoHeader extends StatelessWidget {
  final String logoAsset;
  final String title;
  final String subtitle;
  final double? logoSize;
  final double? titleFontSize;
  final double? subtitleFontSize;

  const LogoHeader({
    super.key,
    required this.logoAsset,
    required this.title,
    required this.subtitle,
    this.logoSize,
    this.titleFontSize,
    this.subtitleFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    final double l = logoSize ?? 120;
    final double t = titleFontSize ?? 36;
    final double s = subtitleFontSize ?? 18;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          logoAsset,
          width: l,
          height: l,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.health_and_safety, size: l, color: Colors.white);
          },
        ),
        SizedBox(height: l * 0.13),
        Text(
          title,
          style: theme.displayLarge?.copyWith(
            color: Colors.white,
            fontSize: t,
            shadows: const [
              Shadow(
                blurRadius: 4,
                color: Colors.black45,
                offset: Offset(0, 2),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: s * 0.4),
        Text(
          subtitle,
          style: theme.titleLarge?.copyWith(color: Colors.white, fontSize: s),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
