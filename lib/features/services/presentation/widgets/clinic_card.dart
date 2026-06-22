import 'package:flutter/material.dart';

import '../../domain/entities/clinic_entity.dart';

class ClinicCard extends StatelessWidget {
  final ClinicEntity clinic;
  final double? distanceKm;
  final VoidCallback onTap;

  const ClinicCard({
    super.key,
    required this.clinic,
    required this.distanceKm,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1A2232) : Colors.white;
    final titleColor = isDark ? Colors.white : colorScheme.onSurface;
    final metaColor = isDark ? Colors.white70 : colorScheme.onSurfaceVariant;
    final borderColor = isDark
        ? colorScheme.outlineVariant.withOpacity(0.35)
        : colorScheme.outlineVariant;
    final distanceBackground = isDark
        ? colorScheme.primary.withOpacity(0.18)
        : colorScheme.primary.withOpacity(0.10);

    return Card(
      color: cardColor,
      elevation: isDark ? 0.6 : 1.5,
      shadowColor: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      clinic.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                        height: 1.2,
                      ),
                    ),
                  ),
                  if (distanceKm != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: distanceBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${distanceKm!.toStringAsFixed(1)} km',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _IconText(
                icon: Icons.location_on_outlined,
                text: clinic.address,
                color: metaColor,
              ),
              const SizedBox(height: 4),
              _IconText(
                icon: Icons.call_outlined,
                text: clinic.phone,
                color: metaColor,
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onTap,
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    overlayColor: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View details',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _IconText({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
