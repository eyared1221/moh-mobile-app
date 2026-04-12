import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yegna_health/shared/widgets/app_bottom_nav.dart';

import '../../data/clinic_repository.dart';
import '../../models/clinic.dart';
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
  final ClinicRepository _repository = ClinicRepository();
  final TextEditingController _searchCtrl = TextEditingController();
  static const int _maxNearbyClinics = 4;

  List<Clinic> _clinics = [];
  bool _isLoading = true;
  String? _error;
  bool _showNearby = true;
  String _searchQuery = '';

  static const double _maxAcceptedAccuracyMeters = 80;

  LatLng? _userLocation;
  bool _isResolvingLocation = false;
  String? _locationNotice;

  @override
  void initState() {
    super.initState();
    _loadClinics();
    _resolveUserLocation();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadClinics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _repository.fetchClinics();
      if (!mounted) return;
      setState(() {
        _clinics = data;
        _isLoading = false;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load clinics. Please try again.';
        _isLoading = false;
      });
    }
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
        if (accuracyMeters <= _maxAcceptedAccuracyMeters) {
          _userLocation = LatLng(position.latitude, position.longitude);
          _locationNotice = null;
        } else {
          _userLocation = null;
          _locationNotice = null;
        }
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
  }

  List<Clinic> _filteredClinics() {
    final query = _searchQuery.trim().toLowerCase();
    return _clinics.where((clinic) {
      if (query.isEmpty) return true;
      final inName = clinic.name.toLowerCase().contains(query);
      final inAddress = clinic.address.toLowerCase().contains(query);
      final inServices = clinic.services.any((s) => s.toLowerCase().contains(query));
      return inName || inAddress || inServices;
    }).toList();
  }

  List<Clinic> _nearbyClinics() {
    final filtered = _filteredClinics();
    if (_userLocation == null) {
      return filtered.take(_maxNearbyClinics).toList();
    }
    final sorted = [...filtered]..sort((a, b) => _distanceKm(a).compareTo(_distanceKm(b)));
    return sorted.take(_maxNearbyClinics).toList();
  }

  double _distanceKm(Clinic clinic) {
    final current = _userLocation;
    if (current == null) return 0;
    return _haversineKm(
      current.latitude,
      current.longitude,
      clinic.location.latitude,
      clinic.location.longitude,
    );
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);

  String _locationHeaderText() {
    final nearbyCount = _nearbyClinics().length;

    if (_showNearby) {
      if (_isResolvingLocation) {
        return 'Detecting your location for precise nearby clinics...';
      }
      if (_userLocation != null) {
        return 'Showing $nearbyCount nearby clinics based on your current location';
      }
      return 'Showing $nearbyCount clinics';
    }
    return 'Showing all clinics';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final nearbyClinics = _nearbyClinics();
    final clinicsToShow = _showNearby ? nearbyClinics : _filteredClinics();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Clinics'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _loadClinics();
              _resolveUserLocation();
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(color: colorScheme.onSurface),
              cursorColor: colorScheme.primary,
              decoration: InputDecoration(
                hintText: 'Search clinic, address, or service',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: isDark ? colorScheme.surfaceVariant : Colors.white,
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: colorScheme.primary, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _locationHeaderText(),
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _isResolvingLocation ? null : _handleLocationAction,
                        icon: _isResolvingLocation
                            ? SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary,
                                ),
                              )
                            : Icon(Icons.my_location_rounded, size: 16, color: colorScheme.primary),
                        label: Text(
                          'Use my location',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_locationNotice != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _locationNotice!,
                      style: TextStyle(
                        color: colorScheme.error,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _TogglePill(
                            label: 'All clinics',
                            selected: !_showNearby,
                            onTap: () => setState(() => _showNearby = false),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _TogglePill(
                            label: 'Nearby (${nearbyClinics.length})',
                            selected: _showNearby,
                            onTap: () => setState(() => _showNearby = true),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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

  Widget _buildBody(BuildContext context, List<Clinic> clinics) {
    if (_isLoading) {
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
      return const Center(
        child: Text('No clinics found. Try a different search.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
    );
  }
}

class _TogglePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TogglePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }
}
