import 'package:flutter/material.dart';

import '../../models/risk_option.dart';
import '../../models/risk_question.dart';

class RiskAssessmentQuestionPage extends StatelessWidget {
  final RiskQuestion question;
  final int currentQuestion;
  final int totalQuestions;
  final int? selectedIndex;
  final ValueChanged<int> onSelectOption;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool isFirst;
  final bool isAnswered;
  final bool isLast;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const RiskAssessmentQuestionPage({
    super.key,
    required this.question,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.selectedIndex,
    required this.onSelectOption,
    required this.colorScheme,
    required this.textTheme,
    required this.isFirst,
    required this.isAnswered,
    required this.isLast,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalQuestions <= 1
        ? 1.0
        : (currentQuestion - 1) / (totalQuestions - 1);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          _buildProgressHeader(progress),
          const SizedBox(height: 21),
          _buildQuestionCard(context),
          const SizedBox(height: 21),
          ...question.options.asMap().entries.map(
                (entry) => _buildOptionTile(
                  context,
                  option: entry.value,
                  isSelected: selectedIndex == entry.key,
                  onTap: () => onSelectOption(entry.key),
                ),
              ),
          const SizedBox(height: 8),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildNavIconButton(
                icon: Icons.arrow_back_rounded,
                label: isFirst ? 'Back' : 'Previous',
                onTap: isFirst ? onPrevious : onPrevious,
                colorScheme: colorScheme,
                filled: false,
              ),
              const Spacer(),
              _buildNavIconButton(
                icon: isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                label: isLast ? 'Finish' : 'Next',
                onTap: isAnswered ? onNext : null,
                colorScheme: colorScheme,
                filled: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavIconButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required ColorScheme colorScheme,
    required bool filled,
  }) {
    final isDisabled = onTap == null;
    final backgroundColor = filled
        ? (isDisabled ? colorScheme.primary.withOpacity(0.4) : colorScheme.primary)
        : colorScheme.surface;
    final foregroundColor = filled
        ? colorScheme.onPrimary
        : isDisabled
            ? colorScheme.outline
            : colorScheme.onSurface;
    final borderColor = filled ? Colors.transparent : colorScheme.outlineVariant;

    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 56,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
              boxShadow: filled
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, color: foregroundColor),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader(double progress) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Question $currentQuestion of $totalQuestions',
            style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ) ??
                TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            const dotSize = 14.0;
            final maxDotOffset = constraints.maxWidth - dotSize;
            final dotOffset = maxDotOffset * clampedProgress;

            return SizedBox(
              height: dotSize,
              child: Stack(
                children: [
                  Positioned(
                    top: 4,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    left: 0,
                    child: Container(
                      width: constraints.maxWidth * clampedProgress,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Positioned(
                    left: dotOffset,
                    top: 0,
                    child: Container(
                      width: dotSize,
                      height: dotSize,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.onPrimary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuestionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.title,
            style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ) ??
                TextStyle(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
          ),
          if (question.helper.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              question.helper,
              style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ) ??
                  TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required RiskOption option,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withOpacity(0.12)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primary,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option.label,
                  style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ) ??
                      TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
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
