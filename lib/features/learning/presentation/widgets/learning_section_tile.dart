import 'package:flutter/material.dart';
import '../../models/learning_content_block.dart';
import '../../models/learning_section.dart';
import 'learning_image.dart';

class LearningSectionTile extends StatelessWidget {
  final LearningSection section;

  const LearningSectionTile({
    super.key,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            section.title,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          iconColor: colorScheme.primary,
          collapsedIconColor: colorScheme.onSurfaceVariant,
          children: section.blocks
              .map((block) => _SectionBlockView(block: block))
              .toList(),
        ),
      ),
    );
  }
}

class _SectionBlockView extends StatelessWidget {
  final LearningContentBlock block;

  const _SectionBlockView({
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    switch (block.type) {
      case LearningContentType.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              block.text,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
                height: 1.65,
              ),
            ),
          ),
        );

      case LearningContentType.subtitle:
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              block.text,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        );

      case LearningContentType.note:
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            block.text,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: colorScheme.onPrimaryContainer,
              height: 1.6,
            ),
          ),
        );

      case LearningContentType.bullets:
      case LearningContentType.alphabet:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: block.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      block.type == LearningContentType.alphabet ? '${String.fromCharCode(65 + block.items.indexOf(item))}. ' : '•  ',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );

      case LearningContentType.image:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LearningImage(
              imageUrl: block.imageUrl,
              isAssetImage: block.isAssetImage,
              fit: BoxFit.cover,
              errorBuilder: (_) => Container(
                height: 140,
                color: colorScheme.surfaceVariant,
                alignment: Alignment.center,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        );

      default:
        // Debug fallback - show any unhandled content types
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unhandled content type: ${block.type.name}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Content: ${block.text}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
                ),
                if (block.items.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Items: ${block.items.join(", ")}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
    }
  }
}
