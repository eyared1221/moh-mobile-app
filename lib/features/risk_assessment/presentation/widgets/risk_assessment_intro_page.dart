import 'package:flutter/material.dart';

class RiskAssessmentIntroPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 35),
                _buildAwarenessCard(),
                const SizedBox(height: 18),
                _buildInfoTiles(context),
                const Spacer(),
                _buildStartButton(),
                const SizedBox(height: 65),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAwarenessCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Awareness First',
            style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                ) ??
                TextStyle(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                ),
          ),
          const SizedBox(height: 14),
          Text(
            'A quick self-check for HIV risk awareness. Answer honestly so the app can guide you with better support and safer choices.',
            style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.55,
                ) ??
                TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.55,
                ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline, size: 20, color: colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'This is not a test. There are no right or wrong answers—just a chance to understand your health better.',
                  style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ) ??
                      TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTiles(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoTile(
            context,
            icon: Icons.timer_outlined,
            title: '2-3 minutes',
            subtitle: 'Quick check',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoTile(
            context,
            icon: Icons.lock_outline,
            title: 'Private',
            subtitle: 'Your answers stay safe',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(
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
            subtitle,
            style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ) ??
                TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: 46,
        width: 228,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: hasQuestions ? onGetStarted : null,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Get Started'),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
