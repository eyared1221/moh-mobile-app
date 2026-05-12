import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/constants.dart';
import '../../domain/entities/campus_entity.dart';
import '../../domain/usecases/get_campuses_use_case.dart';

class CampusSelectionPage extends StatefulWidget {
  final String initialCampus;

  const CampusSelectionPage({
    super.key,
    this.initialCampus = '',
  });

  @override
  State<CampusSelectionPage> createState() => _CampusSelectionPageState();
}

class _CampusSelectionPageState extends State<CampusSelectionPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  final GetCampusesUseCase _getCampusesUseCase = GetCampusesUseCase();

  String _query = '';
  bool _isDetectingNearby = false;
  bool _isLoading = true;
  String? _error;
  List<CampusSectionEntity> _sections = [];

  static const int _sectionPreviewLimit = 5;

  static const Map<String, ({Color accent, Color tint})> _sectionStyles = {
    'Government Universities': (accent: kPrimary, tint: Color(0xFFEAF3F8)),
    'Private Universities in Addis Ababa': (accent: kPrimary, tint: Color(0xFFEAF3F8)),
    'Private Universities in Regional Towns': (accent: kPrimary, tint: Color(0xFFEAF3F8)),
  };

  @override
  void initState() {
    super.initState();
    _loadCampuses();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCampuses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _getCampusesUseCase();
      if (mounted) {
        setState(() {
          _sections = result.sections;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<CampusSectionEntity> get _filteredSections {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _sections;

    return _sections
        .map((section) {
          final filtered = section.campuses.where((campus) {
            final nameMatch = campus.title.toLowerCase().contains(query);
            final subtitleMatch = campus.subtitle?.toLowerCase().contains(query) ?? false;
            return nameMatch || subtitleMatch;
          }).toList();
          return CampusSectionEntity(title: section.title, campuses: filtered);
        })
        .where((s) => s.campuses.isNotEmpty)
        .toList();
  }

  Future<void> _detectNearbyCampus() async {
    if (_isDetectingNearby) return;

    setState(() => _isDetectingNearby = true);

    try {
      if (_isLoading || _sections.isEmpty) {
        await _loadCampuses();
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Turn on location to detect nearby campuses.')),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is needed to detect nearby campuses.')),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 12),
      );

      final allCampuses = _sections
          .expand((s) => s.campuses)
          .where((c) => c.location != null)
          .toList();

      if (allCampuses.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No campus locations are available yet.')),
        );
        return;
      }

      allCampuses.sort((a, b) {
        final aDist = Geolocator.distanceBetween(
          position.latitude, position.longitude,
          a.location!.latitude, a.location!.longitude,
        );
        final bDist = Geolocator.distanceBetween(
          position.latitude, position.longitude,
          b.location!.latitude, b.location!.longitude,
        );
        return aDist.compareTo(bDist);
      });

      if (!mounted) return;
      Navigator.pop(context, allCampuses.first.title);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to detect a nearby campus right now.')),
      );
    } finally {
      if (mounted) setState(() => _isDetectingNearby = false);
    }
  }

  void _showWhyCampusInfo() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Why select your campus?'),
        content: const Text(
          'Choosing your campus helps us highlight health facilities and recommendations that fit where you study and live nearby.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSectionPreview(CampusSectionEntity section) async {
    if (_isLoading) return;
    final styles = _sectionStyles[section.title]!;

    final selectedCampus = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return SafeArea(
          top: false,
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              section.title,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Close',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: kPrimaryStroke.withOpacity(0.65)),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: section.campuses.length,
                        itemBuilder: (context, index) {
                          final campus = section.campuses[index];
                          final isSelected = widget.initialCampus == campus.title;
                          return Column(
                            children: [
                              _CampusRow(
                                campus: _CampusItem(
                                  campus.title,
                                  university: campus.university,
                                  subtitle: campus.subtitle,
                                  latitude: campus.location?.latitude,
                                  longitude: campus.location?.longitude,
                                ),
                                accent: styles.accent,
                                selected: isSelected,
                                onTap: () => Navigator.pop(context, campus.title),
                              ),
                              if (index != section.campuses.length - 1)
                                Divider(
                                  height: 1,
                                  indent: 0,
                                  endIndent: 0,
                                  color: kPrimaryStroke.withOpacity(0.65),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (!mounted || selectedCampus == null || selectedCampus.isEmpty) return;
    Navigator.pop(context, selectedCampus);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sections = _filteredSections;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Select Your Campus'),
        actions: [
          IconButton(
            onPressed: _showWhyCampusInfo,
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (value) => setState(() => _query = value),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ) ?? TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Search university or town',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ) ?? TextStyle(color: colorScheme.onSurfaceVariant),
                  prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: colorScheme.surfaceVariant.withOpacity(0.4),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  _CampusDetectCard(
                    isLoading: _isDetectingNearby,
                    isDisabled: _isLoading && _sections.isEmpty,
                    onTap: _detectNearbyCampus,
                  ),
                  const SizedBox(height: 16),
                  for (final section in sections) ...[
                    _CampusSectionCard(
                      section: section,
                      selectedCampus: widget.initialCampus,
                      isLoading: _isLoading,
                      hasError: _error != null,
                      onCampusTap: (campus) => Navigator.pop(context, campus.title),
                      onViewAllTap: () => _showSectionPreview(section),
                    ),
                    const SizedBox(height: 14),
                  ],
                  _CampusWhyCard(colorScheme: colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampusDetectCard extends StatelessWidget {
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onTap;

  const _CampusDetectCard({
    required this.isLoading,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: isLoading || isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: isDisabled ? const Color(0xFFF5F7F9) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: kPrimaryStroke),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: kPrimarySoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    )
                  : Icon(
                      Icons.location_on_rounded,
                      color: isDisabled
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.primary,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detect nearby campus',
                    style: TextStyle(
                      color: isDisabled
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Find universities near your current location',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colorScheme.primary, size: 28),
          ],
        ),
      ),
    );
  }
}

class _CampusSectionCard extends StatelessWidget {
  final CampusSectionEntity section;
  final String selectedCampus;
  final bool isLoading;
  final bool hasError;
  final ValueChanged<CampusEntity> onCampusTap;
  final VoidCallback onViewAllTap;

  const _CampusSectionCard({
    required this.section,
    required this.selectedCampus,
    required this.isLoading,
    required this.hasError,
    required this.onCampusTap,
    required this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final styles = _CampusSelectionPageState._sectionStyles[section.title]!;
    final visibleCampuses = section.campuses.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kPrimaryStroke),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  styles.tint,
                  Colors.white,
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_rounded, color: styles.accent, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    section.title,
                    style: TextStyle(
                      color: styles.accent,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: styles.tint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${section.count}',
                    style: TextStyle(
                      color: styles.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading && visibleCampuses.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Loading universities...',
                  style: TextStyle(
                    color: Color(0xFF5F6E7A),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else if (hasError && visibleCampuses.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Could not load universities.',
                  style: TextStyle(
                    color: Color(0xFF5F6E7A),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else if (!isLoading && visibleCampuses.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'No universities available.',
                  style: TextStyle(
                    color: Color(0xFF5F6E7A),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            for (var index = 0; index < visibleCampuses.length; index++) ...[
              _CampusRow(
                campus: _CampusItem(
                  visibleCampuses[index].title,
                  university: visibleCampuses[index].university,
                  subtitle: visibleCampuses[index].subtitle,
                  latitude: visibleCampuses[index].location?.latitude,
                  longitude: visibleCampuses[index].location?.longitude,
                ),
                accent: styles.accent,
                selected: selectedCampus == visibleCampuses[index].title,
                onTap: () => onCampusTap(visibleCampuses[index]),
              ),
              if (index != visibleCampuses.length - 1)
                Divider(
                  height: 1,
                  indent: 0,
                  endIndent: 0,
                  color: kPrimaryStroke.withOpacity(0.65),
                ),
            ],
          InkWell(
            onTap: isLoading ? null : onViewAllTap,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Row(
                children: [
                  Text(
                    'View all (${section.count})',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, color: colorScheme.primary, size: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CampusRow extends StatelessWidget {
  final _CampusItem campus;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  const _CampusRow({
    required this.campus,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final subtitle = campus.subtitle ?? '';
    final hasSubtitle = subtitle.isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          campus.title,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 14.5,
                            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (selected)
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: kPrimarySoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Selected',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (hasSubtitle) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant, size: 26),
          ],
        ),
      ),
    );
  }
}

class _CampusWhyCard extends StatelessWidget {
  final ColorScheme colorScheme;

  const _CampusWhyCard({
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF2F7FB),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kPrimaryStroke),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: kPrimarySoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.shield_outlined, color: colorScheme.primary, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why select your campus?',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "We'll show you health facilities recommended for your campus and nearby.",
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13.5,
                    height: 1.35,
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

class _CampusItem {
  final String title;
  final String? university;
  final String? subtitle;
  final double? latitude;
  final double? longitude;

  const _CampusItem(
    this.title, {
    this.university,
    this.subtitle,
    this.latitude,
    this.longitude,
  });
}
