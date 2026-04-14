import 'package:flutter/material.dart';

class RiskAssessmentIntroPage extends StatefulWidget {
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool hasQuestions;
  final VoidCallback onGetStarted;

  const RiskAssessmentIntroPage({
    super.key,
    required this.colorScheme,
    required this.textTheme,
    required this.hasQuestions,
    required this.onGetStarted,
  });

  @override
  State<RiskAssessmentIntroPage> createState() => _RiskAssessmentIntroPageState();
}

class _RiskAssessmentIntroPageState extends State<RiskAssessmentIntroPage> {
  bool _hasAcceptedDisclaimer = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.colorScheme;
    final textTheme = widget.textTheme;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 18, 10, 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildHeader(colorScheme, textTheme),
                    const SizedBox(height: 30),
                    _buildParagraphBlock(
                      'This risk assessment helps identify situations where extra support, testing, or prevention guidance may be useful.',
                    ),
                    const SizedBox(height: 22),
                    _buildParagraphBlock(
                      'The information is for guidance only and does not replace professional medical advice, diagnosis, or treatment.',
                    ),
                    const SizedBox(height: 22),
                    _buildParagraphBlock(
                      'Your answers are used to guide your next steps inside the app, and you should respond honestly for the most useful result.',
                    ),
                    const SizedBox(height: 22),
                    _buildParagraphBlock(
                      'By sharing your responses, the app can provide more relevant support. Review how your data is handled in the privacy policy.',
                    ),
                    const SizedBox(height: 32),
                    _buildAgreementRow(colorScheme, textTheme),
                    const SizedBox(height: 34),
                    _buildContinueButton(colorScheme, textTheme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        Icon(
          Icons.error_outline_rounded,
          color: colorScheme.primary,
          size: 40,
        ),
        const SizedBox(height: 14),
        Text(
          'Disclaimer',
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
              ) ??
              TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
              ),
        ),
      ],
    );
  }

  Widget _buildParagraphBlock(String text) {
    return Text(
      text,
      textAlign: TextAlign.justify,
      style: widget.textTheme.bodyLarge?.copyWith(
            height: 1.55,
            fontWeight: FontWeight.w600,
            color: widget.colorScheme.onSurface,
          ) ??
          TextStyle(
            height: 1.55,
            fontWeight: FontWeight.w600,
            color: widget.colorScheme.onSurface,
          ),
    );
  }

  Widget _buildAgreementRow(ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: _hasAcceptedDisclaimer,
              onChanged: (value) {
                setState(() {
                  _hasAcceptedDisclaimer = value ?? false;
                });
              },
              activeColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.outline, width: 1.3),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ) ??
                  TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
              children: [
                const TextSpan(text: 'I have read and agree to the '),
                TextSpan(
                  text: 'Terms and Conditions',
                  style: TextStyle(
                    color: colorScheme.primary,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy.',
                  style: TextStyle(
                    color: colorScheme.primary,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(ColorScheme colorScheme, TextTheme textTheme) {
    final canContinue = widget.hasQuestions && _hasAcceptedDisclaimer;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canContinue ? widget.onGetStarted : null,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(58),
          elevation: 0,
          disabledBackgroundColor: colorScheme.primary.withOpacity(0.35),
          disabledForegroundColor: colorScheme.onPrimary.withOpacity(0.8),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Continue',
          style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: canContinue
                    ? colorScheme.onPrimary
                    : colorScheme.onPrimary.withOpacity(0.8),
              ) ??
              TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: canContinue
                    ? colorScheme.onPrimary
                    : colorScheme.onPrimary.withOpacity(0.8),
              ),
        ),
      ),
    );
  }
}
