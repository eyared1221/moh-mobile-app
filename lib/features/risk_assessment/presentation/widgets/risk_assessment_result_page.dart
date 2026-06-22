import 'package:flutter/material.dart';

class RiskAssessmentResultPage extends StatelessWidget {
  final bool? isHigh;
  final String statusLabel;
  final List<String> actions;
  final String keyMessage;
  final String? saveStatusMessage;
  final bool saveStatusIsError;
  final String? saveStatusActionLabel;
  final VoidCallback? onSaveStatusAction;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTalkToMentor;
  final VoidCallback onGetService;

  const RiskAssessmentResultPage({
    super.key,
    required this.isHigh,
    required this.statusLabel,
    required this.actions,
    required this.keyMessage,
    this.saveStatusMessage,
    this.saveStatusIsError = false,
    this.saveStatusActionLabel,
    this.onSaveStatusAction,
    required this.colorScheme,
    required this.textTheme,
    required this.onTalkToMentor,
    required this.onGetService,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          if (saveStatusMessage != null) ...[
            _buildSaveStatusBanner(),
            const SizedBox(height: 16),
          ],
          _buildResultHeader(),
          const SizedBox(height: 16),
          _buildResultActionsSection(),
          const SizedBox(height: 16),
          _buildKeyMessage(),
          const SizedBox(height: 28),
          _buildBottomActions(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSaveStatusBanner() {
    final bannerColor = saveStatusIsError ? colorScheme.error : colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: bannerColor.withOpacity(0.12),
        border: Border.all(color: bannerColor.withOpacity(0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            saveStatusIsError ? Icons.error_outline : Icons.sync_outlined,
            color: bannerColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              saveStatusMessage!,
              style: textTheme.bodySmall?.copyWith(
                    color: bannerColor,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ) ??
                  TextStyle(
                    color: bannerColor,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
            ),
          ),
          if (saveStatusActionLabel != null && onSaveStatusAction != null) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: onSaveStatusAction,
              style: TextButton.styleFrom(
                foregroundColor: bannerColor,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                saveStatusActionLabel!,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
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

  Widget _buildBottomActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onTalkToMentor,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.people_alt_outlined),
            label: const Text('Talk to Mentor'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onGetService,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.local_hospital_outlined),
            label: const Text('Get Service'),
          ),
        ),
      ],
    );
  }
}
