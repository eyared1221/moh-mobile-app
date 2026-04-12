import 'package:flutter/material.dart';

class RiskAssessmentResultPage extends StatelessWidget {
  final bool? isHigh;
  final String statusLabel;
  final List<String> actions;
  final String keyMessage;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const RiskAssessmentResultPage({
    super.key,
    required this.isHigh,
    required this.statusLabel,
    required this.actions,
    required this.keyMessage,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _buildResultHeader(),
          const SizedBox(height: 16),
          _buildResultActionsSection(),
          const SizedBox(height: 16),
          _buildKeyMessage(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildResultHeader() {
    final color = isHigh == null
        ? colorScheme.primary
        : (isHigh! ? colorScheme.error : Colors.green);
    final icon = isHigh == null
        ? Icons.assignment_turned_in_outlined
        : (isHigh! ? Icons.report_problem_outlined : Icons.verified_outlined);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            colorScheme.surfaceVariant.withOpacity(0.1),
          ],
        ),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assessment Result',
                  style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ) ??
                      TextStyle(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusLabel,
                  style: textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ) ??
                      TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended actions',
          style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ) ??
              TextStyle(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 10),
        ...actions.map(
          (action) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 3,
                  height: 20,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    action,
                    style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ) ??
                        TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surfaceVariant.withOpacity(0.25),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key message',
            style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ) ??
                TextStyle(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            keyMessage,
            style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ) ??
                TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Talk to a counselor or peer mentor.',
            style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ) ??
                TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
