import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
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

  static const double _maxAcceptedAccuracyMeters = 80;

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
      final accuracyMeters = position.accuracy;

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
      if (!mounted) return;
      setState(() {
        _isResolvingLocation = false;
      });
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

  Future<void> _callClinic(ClinicEntity clinic) async {
    final uri = Uri(scheme: 'tel', path: clinic.phone);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to start a phone call right now.')),
      );
    }
  }

  Future<void> _openDirections(ClinicEntity clinic) async {
    final destination =
        '${clinic.location.latitude},${clinic.location.longitude}';
    final origin = _userLocation == null
        ? null
        : '${_userLocation!.latitude},${_userLocation!.longitude}';
    final uri = Uri.parse(
      origin == null
          ? 'https://www.google.com/maps/dir/?api=1&destination=$destination&travelmode=driving'
          : 'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving',
    );

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open directions right now.')),
      );
    }
  }

  String _locationHeaderText() {
    final recommendedCount = _recommendedClinics().length;
    final nearbyCount = _nearbyClinics().length;

    switch (_activeListMode) {
      case _ClinicListMode.recommended:
        if (_isResolvingLocation) {
          return 'Selecting recommended clinics for you...';
        }
        if (_userLocation != null) {
          return 'Showing $recommendedCount recommended clinics based on your location';
        }
        return 'Showing $recommendedCount recommended clinics';
      case _ClinicListMode.nearby:
        if (_isResolvingLocation) {
          return 'Detecting your location for precise nearby clinics...';
        }
        if (_userLocation != null) {
          return 'Showing $nearbyCount nearby clinics based on your current location';
        }
        return 'Showing $nearbyCount clinics';
      case _ClinicListMode.all:
        return 'Showing all clinics';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
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
        title: const Text('Healthcare Facility'),
        actions: [
          GlobalTopBarActions(onSyncPressed: _syncClinics),
        ],
      ),
      body: Column(
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
                hintText: 'Search clinics',
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
                Row(
                  children: [
                    Expanded(
                      child: _ClinicQuickAction(
                        icon: _isResolvingLocation
                            ? null
                            : Icons.location_on_rounded,
                        leading: _isResolvingLocation
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary,
                                ),
                              )
                            : null,
                        label: 'Use my location',
                        onTap: _isResolvingLocation ? null : _handleLocationAction,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ClinicQuickAction(
                        icon: Icons.account_balance_outlined,
                        label: 'Select my campus',
                        onTap: _handleCampusSelection,
                      ),
                    ),
                  ],
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
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => setState(
                    () => _listMode = _ClinicListMode.recommended,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? colorScheme.surface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outlineVariant),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: const Color(0xFFF4B400),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'University near your current location',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  _selectedCampusLabel,
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? colorScheme.surface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _TogglePill(
                            label: 'Campus',
                            icon: Icons.star_rounded,
                            selected: _activeListMode == _ClinicListMode.recommended,
                            onTap: () => setState(
                              () => _listMode = _ClinicListMode.recommended,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _TogglePill(
                            label: 'Nearby',
                            icon: Icons.near_me_rounded,
                            selected: _activeListMode == _ClinicListMode.nearby,
                            onTap: () => setState(
                              () => _listMode = _ClinicListMode.nearby,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _TogglePill(
                            label: 'All Clinics',
                            icon: Icons.local_hospital_outlined,
                            selected: _activeListMode == _ClinicListMode.all,
                            onTap: () => setState(
                              () => _listMode = _ClinicListMode.all,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: _buildBody(context, clinicsToShow),
          ),
        ],
      ),
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

    return Column(
      children: [
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
                'Sort by:',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.swap_vert_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Distance',
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
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
        ),
      ],
    );
  }

}

enum _ClinicListMode { recommended, nearby, all }

class _ClinicQuickAction extends StatelessWidget {
  final IconData? icon;
  final Widget? leading;
  final String label;
  final VoidCallback? onTap;

  const _ClinicQuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading ??
                Icon(
                  icon,
                  size: 20,
                  color: colorScheme.primary,
                ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TogglePill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ]
              : const [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
