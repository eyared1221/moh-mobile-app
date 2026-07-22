import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yegna_health/shared/widgets/app_bottom_nav.dart';
import 'package:yegna_health/shared/widgets/global_notification_bell.dart';

import '../../data/clinic_repository.dart';
import '../../data/datasources/university_mapping_remote_data_source.dart';
import '../../data/datasources/university_mapping_local_data_source.dart';
import '../../domain/entities/clinic_entity.dart';
import '../../domain/entities/lat_lng_entity.dart';
import '../../domain/usecases/get_clinics_use_case.dart';
import '../../models/clinic.dart';
import '../../models/university_campus_mapping.dart';
import 'campus_selection_page.dart';
import '../controllers/clinic_page_controller.dart';
import '../pages/clinic_detail_page.dart';
import '../widgets/clinic_card.dart';

class ClinicPage extends StatefulWidget {
  final String age;
  final String? userName;

  const ClinicPage({
    super.key,
    required this.age,
    this.userName,
  });

  @override
  State<ClinicPage> createState() => _ClinicPageState();
}

class _ClinicPageState extends State<ClinicPage> {
  late final ClinicPageController _controller;
  final UniversityMappingRemoteDataSource _universityMappingRemoteDataSource =
      UniversityMappingRemoteDataSource();
  final UniversityMappingLocalDataSource _universityMappingLocalDataSource =
      UniversityMappingLocalDataSource();
  final TextEditingController _searchCtrl = TextEditingController();
  static const int _maxNearbyClinics = 4;

  List<ClinicEntity> _clinics = [];
  List<UniversityCampusMapping> _universityMappings = [];
  bool _isLoading = true;
  bool _isLoadingUniversityMappings = true;
  String? _error;
  _ClinicListMode? _listMode = _ClinicListMode.recommended;
  String _searchQuery = '';
  String _selectedCampusLabel = 'Select your campus';

  LatLngEntity? _userLocation;
  bool _isResolvingLocation = false;
  String? _locationNotice;

  _ClinicListMode get _activeListMode =>
      _listMode ?? _ClinicListMode.recommended;

  @override
  void initState() {
    super.initState();
    _controller = ClinicPageController(
      GetClinicsUseCase(ClinicRepository()),
    );
    _loadPersistedCampus();
    _bootstrapClinics();
    _loadUniversityMappings();
    _resolveUserLocation();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _bootstrapClinics() async {
    final cachedClinics = await _controller.loadCachedClinics();
    if (!mounted) return;

    if (cachedClinics.isNotEmpty) {
      setState(() {
        _clinics = cachedClinics;
        _isLoading = false;
        _error = null;
      });
    }

    unawaited(
      _refreshClinics(showLoading: cachedClinics.isEmpty),
    );
  }

  Future<void> _refreshClinics({bool showLoading = false}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final data = await _controller.loadClinics();
      if (!mounted) return;
      setState(() {
        _clinics = data;
        _error = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (_clinics.isEmpty) {
          _error = 'Failed to load clinics. Please try again.';
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _loadClinics() async {
    await _refreshClinics(showLoading: true);
  }

  Future<void> _loadUniversityMappings() async {
    final cachedPayload = await _universityMappingLocalDataSource
        .getCachedUniversityMappingsPayload();
    if (cachedPayload != null) {
      try {
        final cachedMappings = _universityMappingRemoteDataSource
            .mapPayloadToMappings(cachedPayload);
        if (!mounted) return;
        setState(() {
          _universityMappings = cachedMappings;
          _isLoadingUniversityMappings = false;
        });
        _updateListModeBasedOnCampus();
      } catch (_) {
        // If cache is corrupted, fall through to fetch from backend
      }
    }

    unawaited(_refreshUniversityMappings(showLoading: cachedPayload == null));
  }

  Future<void> _refreshUniversityMappings({bool showLoading = false}) async {
    if (showLoading && mounted) {
      setState(() {
        _isLoadingUniversityMappings = true;
      });
    }

    try {
      final mappings = await _universityMappingRemoteDataSource
          .fetchUniversityMappings();
      if (!mounted) return;
      setState(() {
        _universityMappings = mappings;
        _isLoadingUniversityMappings = false;
      });
      _updateListModeBasedOnCampus();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (_universityMappings.isEmpty) {
          _isLoadingUniversityMappings = false;
        }
      });
      // Keep clinic results available even if campus mappings fail to load.
    }
  }

  void _updateListModeBasedOnCampus() {
    if (_selectedCampusMapping != null) {
      setState(() {
        _listMode = _ClinicListMode.recommended;
      });
    } else if (_selectedCampusLabel == 'Select your campus') {
      setState(() {
        _listMode = _ClinicListMode.all;
      });
    }
  }

  Future<void> _syncClinics() async {
    await _refreshClinics(showLoading: _clinics.isEmpty);
    await _loadUniversityMappings();
    await _resolveUserLocation();
  }

  Future<void> _resolveUserLocation() async {
    if (mounted) {
      setState(() {
        _isResolvingLocation = true;
      });
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _locationNotice = 'Location service is off. Enable it for precise nearby results.';
          _userLocation = null;
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() {
          _locationNotice = 'Location permission denied. Allow location to use precise distance.';
          _userLocation = null;
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _locationNotice = 'Location is permanently denied. Open app settings to allow it.';
          _userLocation = null;
        });
        return;
      }

      final position = await _getBestAvailablePosition();
      if (!mounted) return;
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _locationNotice = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _locationNotice = 'Unable to read your location right now.';
        _userLocation = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResolvingLocation = false;
        });
      }
    }
  }

  Future<Position> _getBestAvailablePosition() async {
    final first = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      timeLimit: const Duration(seconds: 12),
    );

    if (first.accuracy <= 80) {
      return first;
    }

    await Future.delayed(const Duration(milliseconds: 1200));

    final second = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      timeLimit: const Duration(seconds: 12),
    );

    return second.accuracy < first.accuracy ? second : first;
  }

  Future<void> _handleLocationAction() async {
    if (mounted) {
      setState(() {
        _listMode = _ClinicListMode.nearby;
      });
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      await _resolveUserLocation();
      return;
    }

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return;
    }

    await _resolveUserLocation();

    if (!mounted) return;
    setState(() {
      _listMode = _userLocation != null
          ? _ClinicListMode.nearby
          : _ClinicListMode.recommended;
    });
  }

  Future<void> _handleCampusSelection() async {
    final selectedCampus = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => CampusSelectionPage(
          initialCampus: _selectedCampusLabel,
        ),
      ),
    );

    if (selectedCampus == null || !mounted) return;
    setState(() {
      _selectedCampusLabel = selectedCampus;
      _listMode = _ClinicListMode.recommended;
    });
    await _savePersistedCampus(selectedCampus);
  }

  Future<void> _loadPersistedCampus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCampus = prefs.getString('selected_campus');
    if (savedCampus != null && savedCampus.isNotEmpty) {
      setState(() {
        _selectedCampusLabel = savedCampus;
      });
    }
  }

  Future<void> _savePersistedCampus(String campus) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_campus', campus);
  }

  Future<void> _handleFindModeSelection(_ClinicListMode mode) async {
    switch (mode) {
      case _ClinicListMode.nearby:
        await _handleLocationAction();
        return;
      case _ClinicListMode.recommended:
      case _ClinicListMode.all:
        if (!mounted) return;
        setState(() {
          _listMode = mode;
        });
    }
  }

  List<ClinicEntity> _filteredClinics() {
    return _controller.filterClinics(_clinics, _searchQuery);
  }

  List<ClinicEntity> _nearbyClinics() {
    return _controller.nearbyClinics(
      _clinics,
      query: _searchQuery,
      userLocation: _userLocation,
      maxNearbyClinics: _maxNearbyClinics,
    );
  }

  List<ClinicEntity> _recommendedClinics() {
    final selectedMapping = _selectedCampusMapping;
    if (selectedMapping == null ||
        selectedMapping.recommendedFacilities.isEmpty) {
      return const [];
    }

    final recommendedOrderById = <String, int>{};
    final recommendedOrderByName = <String, int>{};
    for (var index = 0;
        index < selectedMapping.recommendedFacilities.length;
        index++) {
      final facility = selectedMapping.recommendedFacilities[index];
      final normalizedFacilityId = facility.facilityId.trim().toLowerCase();
      if (normalizedFacilityId.isNotEmpty) {
        recommendedOrderById[normalizedFacilityId] = index;
      }

      final normalizedFacilityName = _normalizeMatchKey(facility.name);
      if (normalizedFacilityName.isNotEmpty) {
        recommendedOrderByName[normalizedFacilityName] = index;
      }
    }

    final recommendedClinics = _filteredClinics().where((clinic) {
      final normalizedClinicId = clinic.id.trim().toLowerCase();
      if (normalizedClinicId.isNotEmpty &&
          recommendedOrderById.containsKey(normalizedClinicId)) {
        return true;
      }

      return recommendedOrderByName.containsKey(_normalizeMatchKey(clinic.name));
    }).toList();

    recommendedClinics.sort((a, b) {
      if (_userLocation != null) {
        final aDistance = _distanceKm(a);
        final bDistance = _distanceKm(b);
        final distanceComparison = aDistance.compareTo(bDistance);

        if (distanceComparison != 0) {
          return distanceComparison;
        }
      }

      final aRank = recommendedOrderById[a.id.trim().toLowerCase()] ??
          recommendedOrderByName[_normalizeMatchKey(a.name)] ??
          selectedMapping.recommendedFacilities.length;
      final bRank = recommendedOrderById[b.id.trim().toLowerCase()] ??
          recommendedOrderByName[_normalizeMatchKey(b.name)] ??
          selectedMapping.recommendedFacilities.length;

      if (aRank != bRank) {
        return aRank.compareTo(bRank);
      }

      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return recommendedClinics;
  }

  UniversityCampusMapping? get _selectedCampusMapping {
    final normalizedSelectedLabel = _normalizeMatchKey(_selectedCampusLabel);

    for (final mapping in _universityMappings) {
      if (_normalizeMatchKey(mapping.displayTitle) == normalizedSelectedLabel ||
          _normalizeMatchKey(mapping.university) == normalizedSelectedLabel) {
        return mapping;
      }
    }

    return null;
  }

  double _distanceKm(ClinicEntity clinic) {
    final current = _userLocation;
    if (current == null) return 0;
    return _controller.distanceKm(clinic, current);
  }

  List<ClinicEntity> _sortClinics(List<ClinicEntity> clinics) {
    final sorted = [...clinics];
    if (_userLocation == null) {
      sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return sorted;
    }

    sorted.sort((a, b) => _distanceKm(a).compareTo(_distanceKm(b)));
    return sorted;
  }

  String _normalizeMatchKey(String value) {
    return value
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r"[.'(),-]"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _findModeLabel(_ClinicListMode mode) {
    switch (mode) {
      case _ClinicListMode.nearby:
        return 'Nearby';
      case _ClinicListMode.recommended:
        return 'By campus';
      case _ClinicListMode.all:
        return 'All';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recommendedClinics = _recommendedClinics();
    final nearbyClinics = _nearbyClinics();
    final clinicsToShow = switch (_activeListMode) {
      _ClinicListMode.recommended => recommendedClinics,
      _ClinicListMode.nearby => _sortClinics(nearbyClinics),
      _ClinicListMode.all => _sortClinics(_filteredClinics()),
    };

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Health Facility'),
        actions: [
          GlobalTopBarActions(onSyncPressed: _syncClinics),
        ],
      ),
      body: _buildBody(context, clinicsToShow),
      bottomNavigationBar: AppBottomNav(
        age: widget.age,
        currentIndex: 3,
        userName: widget.userName,
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<ClinicEntity> clinics) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_activeListMode == _ClinicListMode.recommended &&
        _isLoadingUniversityMappings) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadClinics,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }
    if (clinics.isEmpty) {
      final emptyMessage = _activeListMode == _ClinicListMode.recommended
          ? (_selectedCampusLabel == 'Select your campus'
              ? 'Choose your campus or tap "Detect Nearby Campus" to find recommended health services near you.'
              : 'No recommended health services are available for this campus yet.')
          : 'No clinics found. Try a different search.';

      return Center(
        child: Text(emptyMessage),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final clinicLabel = clinics.length == 1 ? 'clinic' : 'clinics';

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (value) => setState(() => _searchQuery = value),
            style:
                theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ) ??
                TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
            decoration: InputDecoration(
              hintText: 'Search health facility',
              hintStyle:
                  theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ) ??
                  TextStyle(color: colorScheme.onSurfaceVariant),
              prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
              filled: true,
              fillColor: colorScheme.surfaceVariant.withOpacity(0.4),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
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
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ClinicSupportSelectorCard(
                isResolvingLocation: _isResolvingLocation,
                onUseLocation: _isResolvingLocation ? null : _handleLocationAction,
                onSelectCampus: _handleCampusSelection,
              ),
              if (_locationNotice != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    _locationNotice!,
                    style: TextStyle(
                      color: colorScheme.error,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
          child: Row(
            children: [
              Icon(Icons.filter_list_rounded, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Showing ${clinics.length} $clinicLabel',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'Find:',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              PopupMenuButton<_ClinicListMode>(
                initialValue: _activeListMode,
                onSelected: (mode) {
                  unawaited(_handleFindModeSelection(mode));
                },
                color: theme.cardColor,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _ClinicListMode.nearby,
                    child: Text(_findModeLabel(_ClinicListMode.nearby)),
                  ),
                  PopupMenuItem(
                    value: _ClinicListMode.recommended,
                    child: Text(_findModeLabel(_ClinicListMode.recommended)),
                  ),
                  PopupMenuItem(
                    value: _ClinicListMode.all,
                    child: Text(_findModeLabel(_ClinicListMode.all)),
                  ),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.swap_vert_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _findModeLabel(_activeListMode),
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          itemCount: clinics.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final clinic = clinics[index];
            final distance = _userLocation == null ? null : _distanceKm(clinic);
            return ClinicCard(
              clinic: clinic,
              distanceKm: distance,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClinicDetailPage(clinic: clinic, distanceKm: distance),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

enum _ClinicListMode { recommended, nearby, all }

class _ClinicSupportSelectorCard extends StatelessWidget {
  final bool isResolvingLocation;
  final VoidCallback? onUseLocation;
  final VoidCallback onSelectCampus;

  const _ClinicSupportSelectorCard({
    required this.isResolvingLocation,
    required this.onUseLocation,
    required this.onSelectCampus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;
    final borderColor = isDark
        ? colorScheme.outlineVariant.withOpacity(0.38)
        : colorScheme.outlineVariant;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useHorizontalLayout = constraints.maxWidth >= 430;
          final actionColumnWidth = (constraints.maxWidth * 0.42).clamp(
            196.0,
            220.0,
          );

          if (!useHorizontalLayout) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoBlock(context, colorScheme),
                const SizedBox(height: 16),
                _buildActionButtons(context, colorScheme),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12, top: 4),
                  child: _buildInfoBlock(context, colorScheme),
                ),
              ),
              SizedBox(
                width: actionColumnWidth,
                child: _buildActionButtons(context, colorScheme),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoBlock(BuildContext context, ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.location_on_outlined,
          color: colorScheme.primary,
          size: 26,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find care near you',
                style: textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ) ??
                    TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Use your location or select your campus to see recommended health facilities.',
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
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        _ClinicActionButton(
          icon: isResolvingLocation ? null : Icons.my_location_rounded,
          leading: isResolvingLocation
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : null,
          label: 'Use my location',
          onTap: onUseLocation,
          filled: true,
        ),
        const SizedBox(height: 10),
        _ClinicActionButton(
          icon: Icons.school_outlined,
          label: 'Select campus',
          onTap: onSelectCampus,
          filled: false,
        ),
      ],
    );
  }
}

class _ClinicActionButton extends StatelessWidget {
  final IconData? icon;
  final Widget? leading;
  final String label;
  final VoidCallback? onTap;
  final bool filled;

  const _ClinicActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.filled,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: filled ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.primary,
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading ??
                Icon(
                  icon,
                  size: 18,
                  color: filled ? colorScheme.onPrimary : colorScheme.primary,
                ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: filled ? colorScheme.onPrimary : colorScheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
