import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/mentor_entity.dart';

class MentorCard extends StatefulWidget {
  final MentorEntity mentor;

  const MentorCard({super.key, required this.mentor});

  @override
  State<MentorCard> createState() => _MentorCardState();
}

class _MentorCardState extends State<MentorCard> {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'MOBILE_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000',
  );

  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = _displayName(widget.mentor);
    final initials = widget.mentor.fullName.trim().isEmpty
        ? 'M'
        : widget.mentor.fullName
            .trim()
            .split(' ')
            .map((s) => s.isNotEmpty ? s[0] : '')
            .take(2)
            .join();
    final lift = (_isPressed || _isHovered) ? -4.0 : 0.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, lift, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildAvatar(
                  context,
                  imagePath: widget.mentor.imageUrl,
                  initials: initials.toUpperCase(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.mentor.phone,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.65),
                          fontWeight: FontWeight.w600,
                          fontSize: 10.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _openUrl(context, 'tel:${widget.mentor.phone}'),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.call_rounded,
                      color: colorScheme.primary,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _displayName(MentorEntity mentor) {
    final name = mentor.fullName.trim();
    if (name.isEmpty) return 'Mentor';
    final role = mentor.role?.toLowerCase() ?? '';
    if (role.contains('doctor') || role == 'dr' || role.contains('dr.')) {
      if (name.toLowerCase().startsWith('dr')) return name;
      return 'Dr. $name';
    }
    return name;
  }

  Widget _buildAvatar(
    BuildContext context, {
    required String? imagePath,
    required String initials,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedImagePath = _resolveImagePath(imagePath);

    return ClipOval(
      child: Container(
        width: 40,
        height: 40,
        color: colorScheme.primary.withOpacity(0.12),
        child: resolvedImagePath == null
            ? _buildInitials(initials, colorScheme)
            : _buildAvatarImage(
                context,
                imagePath: resolvedImagePath,
                initials: initials,
              ),
      ),
    );
  }

  Widget _buildAvatarImage(
    BuildContext context, {
    required String imagePath,
    required String initials,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildInitials(initials, colorScheme),
      );
    }

    final bytes = _tryDecodeDataImage(imagePath);
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildInitials(initials, colorScheme),
      );
    }

    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildInitials(initials, colorScheme),
    );
  }

  Widget _buildInitials(String initials, ColorScheme colorScheme) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  String? _resolveImagePath(String? rawPath) {
    if (rawPath == null) return null;

    final path = rawPath.trim();
    if (path.isEmpty) return null;
    if (path.startsWith('assets/')) return path;
    if (path.startsWith('data:image/')) return path;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;

    final base = _apiOrigin;
    if (path.startsWith('/')) {
      return '$base$path';
    }

    return '$base/$path';
  }

  String get _apiOrigin {
    final configuredBaseUrl = _configuredBaseUrl.replaceAll(RegExp(r'/+$'), '');

    if (kIsWeb) {
      return 'http://localhost:4000';
    }

    if (configuredBaseUrl.endsWith('/api/mobile/auth')) {
      return configuredBaseUrl.replaceFirst(RegExp(r'/api/mobile/auth$'), '');
    }

    if (configuredBaseUrl.endsWith('/api/v1/assessments')) {
      return configuredBaseUrl.replaceFirst(RegExp(r'/api/v1/assessments$'), '');
    }

    if (configuredBaseUrl.endsWith('/api/v1')) {
      return configuredBaseUrl.replaceFirst(RegExp(r'/api/v1$'), '');
    }

    if (configuredBaseUrl.endsWith('/api')) {
      return configuredBaseUrl.replaceFirst(RegExp(r'/api$'), '');
    }

    return configuredBaseUrl;
  }

  Uint8List? _tryDecodeDataImage(String value) {
    if (!value.startsWith('data:image/')) {
      return null;
    }

    final commaIndex = value.indexOf(',');
    if (commaIndex == -1 || commaIndex == value.length - 1) {
      return null;
    }

    try {
      return base64Decode(value.substring(commaIndex + 1));
    } catch (_) {
      return null;
    }
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open dialer')),
      );
    }
  }
}

class MentorSkeletonCard extends StatefulWidget {
  const MentorSkeletonCard({super.key});

  @override
  State<MentorSkeletonCard> createState() => _MentorSkeletonCardState();
}

class _MentorSkeletonCardState extends State<MentorSkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final base = colorScheme.surfaceVariant;
        final highlight = colorScheme.surfaceVariant.withOpacity(0.55);
        final fill = Color.lerp(base, highlight, _pulse.value)!;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              CircleAvatar(radius: 20, backgroundColor: fill),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 11,
                      width: 130,
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 9,
                      width: 100,
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: fill,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
