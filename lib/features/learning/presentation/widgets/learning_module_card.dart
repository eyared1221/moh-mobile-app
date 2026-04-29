import 'package:flutter/material.dart';
import '../../domain/entities/learning_module_entity.dart';
import 'learning_image.dart';

class LearningModuleCard extends StatelessWidget {
  final LearningModuleEntity module;
  final int moduleNumber;
  final VoidCallback onMoreTap;

  const LearningModuleCard({
    super.key,
    required this.module,
    required this.moduleNumber,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTopImage = moduleNumber.isEven;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: isDark
            ? []
            : const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isTopImage) ...[
            Expanded(
              child: _ModuleImage(module: module),
            ),
            const SizedBox(height: 18),
          ],

          Text(
            module.title,
            style: textTheme.titleMedium?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            module.shortDescription,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),

          SizedBox(
            width: 120,
            height: 48,
            child: ElevatedButton(
              onPressed: onMoreTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      module.ctaLabel,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          if (!isTopImage)
            Expanded(
              child: _ModuleImage(module: module),
            ),
        ],
      ),
    );
  }
}

class _ModuleImage extends StatelessWidget {
  final LearningModuleEntity module;

  const _ModuleImage({
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: double.infinity,
        child: LearningImage(
          imageUrl: module.imageUrl,
          isAssetImage: module.isAssetImage,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          errorBuilder: (context) => Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
