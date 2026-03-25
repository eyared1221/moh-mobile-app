// lib/widgets/module_grid.dart
import 'package:flutter/material.dart';
import 'module_card.dart';

class ModuleGrid extends StatelessWidget {
  final List<Map<String, String>> items;
  final void Function(int index) onCardTap;

  const ModuleGrid({super.key, required this.items, required this.onCardTap});

  @override
  Widget build(BuildContext context) {
    // 2 columns grid, vertical flow, spacing to match Figma
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 18,
        childAspectRatio: 180 / 250, // width / height matching desired visual
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return ModuleCard(
          title: item['title'] ?? '',
          subtitle: 'Module ${index + 1}',
          imagePath: item['image'] ?? '',
          onTap: () => onCardTap(index),
        );
      },
    );
  }
}
