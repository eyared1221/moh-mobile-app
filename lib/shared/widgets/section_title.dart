import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.18),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ],
    );
  }
}
