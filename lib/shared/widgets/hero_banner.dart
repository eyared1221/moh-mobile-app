import 'package:flutter/material.dart';

class HeroBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String age;

  const HeroBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.age,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompactHeight = MediaQuery.sizeOf(context).height < 760;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompactHeight ? 20 : 24,
        vertical: isCompactHeight ? 22 : 28,
      ),
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: theme.textTheme.headlineMedium?.copyWith(
          fontSize: isCompactHeight ? 22 : 26,
          height: 1.2,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}
