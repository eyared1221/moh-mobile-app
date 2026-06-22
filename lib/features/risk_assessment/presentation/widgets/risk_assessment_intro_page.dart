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
  State<RiskAssessmentIntroPage> createState() =>
      _RiskAssessmentIntroPageState();
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withOpacity(0.45),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeaderSection(colorScheme, textTheme),
                          const SizedBox(height: 18),
                          _buildInfoCard(
                            colorScheme,
                            textTheme,
                            icon: Icons.volunteer_activism_outlined,
                            content: TextSpan(
                              children: [
                                const TextSpan(
                                  text:
                                      'This risk assessment helps identify situations where ',
                                ),
                                _accentSpan(
                                  'extra support, testing, or prevention',
                                  colorScheme,
                                ),
                                const TextSpan(
                                  text: ' guidance may be useful.',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            colorScheme,
                            textTheme,
                            icon: Icons.medical_services_outlined,
                            content: TextSpan(
                              children: [
                                const TextSpan(text: 'The information is for '),
                                _accentSpan('guidance only', colorScheme),
                                const TextSpan(
                                  text:
                                      ' and does not replace professional medical advice, diagnosis, or treatment.',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            colorScheme,
                            textTheme,
                            icon: Icons.assignment_outlined,
                            content: TextSpan(
                              children: [
                                const TextSpan(
                                  text:
                                      'Your answers are used to guide your next steps inside the app, and you should ',
                                ),
                                _accentSpan('respond honestly', colorScheme),
                                const TextSpan(
                                  text: ' for the most useful result.',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            colorScheme,
                            textTheme,
                            icon: Icons.lock_outline_rounded,
                            content: TextSpan(
                              children: [
                                const TextSpan(
                                  text:
                                      'By sharing your responses, the app can provide more relevant support. Review how your data is handled in the ',
                                ),
                                _accentSpan('privacy policy.', colorScheme),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildAgreementCard(colorScheme, textTheme),
                          const SizedBox(height: 18),
                          _buildContinueButton(colorScheme, textTheme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.health_and_safety_outlined,
                color: colorScheme.primary,
                size: 34,
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.18),
                    ),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: colorScheme.primary,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Disclaimer',
                  style: textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ) ??
                      TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please read the following information before starting the assessment.',
                  style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        height: 1.45,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ) ??
                      TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    ColorScheme colorScheme,
    TextTheme textTheme, {
    required IconData icon,
    required TextSpan content,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF162033) : colorScheme.surface;
    final borderColor = isDark
        ? colorScheme.outlineVariant.withOpacity(0.38)
        : colorScheme.outlineVariant.withOpacity(0.5);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text.rich(
                content,
                style: textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      height: 1.55,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ) ??
                    TextStyle(
                      fontSize: 15,
                      height: 1.55,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
               ),
             ),
           ),
        ],
      ),
    );
  }

  TextSpan _accentSpan(String text, ColorScheme colorScheme) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildAgreementCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
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
                side: BorderSide(color: colorScheme.primary, width: 1.4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity:
                    const VisualDensity(horizontal: -4, vertical: -4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ) ??
                    TextStyle(
                      fontSize: 14,
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
      ),
    );
  }

  Widget _buildContinueButton(ColorScheme colorScheme, TextTheme textTheme) {
    final canContinue = widget.hasQuestions && _hasAcceptedDisclaimer;
    final disabledForeground = Colors.white.withOpacity(0.78);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canContinue ? widget.onGetStarted : null,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(58),
          elevation: 0,
          disabledBackgroundColor: colorScheme.primary.withOpacity(0.48),
          disabledForegroundColor: disabledForeground,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Continue',
          style: textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: canContinue
                    ? colorScheme.onPrimary
                    : disabledForeground,
              ) ??
              TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: canContinue
                    ? colorScheme.onPrimary
                    : disabledForeground,
              ),
        ),
      ),
    );
  }
}
