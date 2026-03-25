import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final Widget child;

  const InfoCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final sc = Theme.of(context).shadowColor;
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(sc.red, sc.green, sc.blue, 0.08),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}
