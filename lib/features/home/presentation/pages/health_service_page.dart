import 'package:flutter/material.dart';

import '../../../../core/constants.dart';
import '../../../services/presentation/pages/clinic_page.dart';

class HealthServicePage extends StatelessWidget {
  final String age;
  final String? userName;

  const HealthServicePage({
    super.key,
    required this.age,
    this.userName,
  });

  static const List<_HealthServiceItem> _services = [
    _HealthServiceItem(
      title: 'Counseling services',
      description:
          'Get confidential support and guidance for your health and personal concerns.',
      icon: Icons.support_agent_outlined,
    ),
    _HealthServiceItem(
      title: 'Condom promotion and distribution',
      description:
          'Access free condoms and information to help you stay protected.',
      icon: Icons.health_and_safety_outlined,
    ),
    _HealthServiceItem(
      title: 'HIV testing',
      description:
          'Get tested for HIV in a safe, private, and supportive environment.',
      icon: Icons.water_drop_outlined,
    ),
    _HealthServiceItem(
      title: 'STI screening, diagnosis and management',
      description:
          'Screening, diagnosis, and treatment for sexually transmitted infections.',
      icon: Icons.biotech_outlined,
    ),
    _HealthServiceItem(
      title: 'Pre exposure prophylaxis (PrEP)',
      description:
          'Daily medication available for eligible individuals in accordance with national guidelines.',
      icon: Icons.verified_user_outlined,
    ),
    _HealthServiceItem(
      title: 'Post exposure prophylaxis (PEP)',
      description:
          'Emergency medication available for eligible individuals in accordance with national guidelines.',
      icon: Icons.medication_outlined,
    ),
    _HealthServiceItem(
      title: 'Family planning',
      description:
          'Get a variety of family planning services and reproductive health support.',
      icon: Icons.people_alt_outlined,
    ),
    _HealthServiceItem(
      title: 'Gender-based violence (GBV) support',
      description:
          'Safe and confidential support for those affected by gender-based violence.',
      icon: Icons.volunteer_activism_outlined,
    ),
  ];

  void _openClinicFinder(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ClinicPage(age: age, userName: userName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundGradient = isDark
        ? const [
            Color(0xFF09121F),
            Color(0xFF0E1A2D),
            Color(0xFF111E30),
          ]
        : const [
            Color(0xFFF8FBFF),
            Color(0xFFF2F7FD),
            Color(0xFFFFFFFF),
          ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1220) : const Color(0xFFF7FBFF),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: backgroundGradient,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              left: -50,
              child: _GlowOrb(
                size: 220,
                color: kPrimary.withOpacity(isDark ? 0.16 : 0.09),
              ),
            ),
            Positioned(
              top: 220,
              right: -70,
              child: _GlowOrb(
                size: 190,
                color: const Color(0xFF7AC6E6).withOpacity(isDark ? 0.10 : 0.10),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Spacer(),
                              TextButton(
                                onPressed: () => _openClinicFinder(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: isDark ? Colors.white : kPrimary,
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                child: const Text('Skip'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                              _ProgressPill(isActive: true),
                              SizedBox(width: 14),
                              _ProgressPill(),
                              SizedBox(width: 14),
                              _ProgressPill(),
                            ],
                          ),
                          const SizedBox(height: 26),
                          Text(
                            'Explore Health Services Near You',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: isDark ? Colors.white : kPrimary,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.7,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 620),
                            child: Text(
                              'The healthcare facilities in your area offer essential services to support your health and well-being. Here is what you can access:',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF55697E),
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),
                          _IllustrationPanel(isDark: isDark),
                          const SizedBox(height: 20),
                          for (final service in _services) ...[
                            _ServiceCard(
                              service: service,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 14),
                          ],
                          _PrivacyCard(isDark: isDark),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                    child: SizedBox(
                      width: double.infinity,
                      height: 62,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF005C8F),
                              Color(0xFF0B6FA6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimary.withOpacity(isDark ? 0.20 : 0.24),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => _openClinicFinder(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Icon(Icons.arrow_forward_ios_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IllustrationPanel extends StatelessWidget {
  final bool isDark;

  const _IllustrationPanel({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132136) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : const Color(0xFFD9E7F4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.12 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.asset(
          'assets/images/health-facility.png',
          width: double.infinity,
          fit: BoxFit.fitWidth,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 230,
              alignment: Alignment.center,
              color: isDark
                  ? const Color(0xFF1A314B)
                  : const Color(0xFFF1F7FD),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_hospital_outlined,
                    size: 58,
                    color: isDark ? Colors.white70 : kPrimary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Health facility image not found',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white70
                          : const Color(0xFF55697E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final _HealthServiceItem service;
  final bool isDark;

  const _ServiceCard({
    required this.service,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132136) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : const Color(0xFFE3EDF7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.08 : 0.045),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: isDark ? const Color(0xFF1A2C44) : const Color(0xFFF1F7FD),
            ),
            child: Icon(
              service.icon,
              color: kPrimary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF10273C),
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  service.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? Colors.white70
                        : const Color(0xFF5B6F82),
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  final bool isDark;

  const _PrivacyCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? const [
                  Color(0xFF15293E),
                  Color(0xFF102033),
                ]
              : const [
                  Color(0xFFF0F7FF),
                  Color(0xFFE7F1FB),
                ],
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : const Color(0xFFD7E7F5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark ? const Color(0xFF1A2D44) : Colors.white,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: kPrimary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your privacy matters',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.white : kPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'All services are confidential, non-judgmental, and provided with respect and care.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : const Color(0xFF55697E),
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withOpacity(0),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressPill extends StatelessWidget {
  final bool isActive;

  const _ProgressPill({
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 58,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: isActive ? const Color(0xFF6CA6E0) : const Color(0xFFD7E0EA),
      ),
    );
  }
}

class _HealthServiceItem {
  final String title;
  final String description;
  final IconData icon;

  const _HealthServiceItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}
