import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../models/clinic.dart';
import '../widgets/google_map_iframe_stub.dart'
    if (dart.library.html) '../widgets/google_map_iframe_web.dart';

class ClinicDetailPage extends StatefulWidget {
  final Clinic clinic;
  final double? distanceKm;

  const ClinicDetailPage({
    super.key,
    required this.clinic,
    required this.distanceKm,
  });

  @override
  State<ClinicDetailPage> createState() => _ClinicDetailPageState();
}

class _ClinicDetailPageState extends State<ClinicDetailPage> {
  late final PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final images = [
      if (widget.clinic.imageUrl != null) widget.clinic.imageUrl!,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clinic.name),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              child: images.isEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.surfaceVariant,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.local_hospital_outlined,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                    )
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (index) => setState(() => _pageIndex = index),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: _buildClinicImage(images[index]),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (images.length > 1) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _pageIndex ? 18 : 8,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _pageIndex ? colorScheme.primary : colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              widget.clinic.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              widget.clinic.description,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Contact',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            _InfoTile(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: widget.clinic.address,
              onTap: () => _copyValue(context, widget.clinic.address),
            ),
            _InfoTile(
              icon: Icons.call_outlined,
              label: 'Phone',
              value: widget.clinic.phone,
              actionIcon: Icons.phone_rounded,
              onAction: () => _openUrl(context, 'tel:${widget.clinic.phone}'),
            ),
            if (widget.clinic.email != null && widget.clinic.email!.isNotEmpty)
              _InfoTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: widget.clinic.email!,
                actionIcon: Icons.mail_rounded,
                onAction: () => _openUrl(context, 'mailto:${widget.clinic.email!}'),
              ),
            if (widget.clinic.website != null && widget.clinic.website!.isNotEmpty)
              _InfoTile(
                icon: Icons.language_outlined,
                label: 'Website',
                value: widget.clinic.website!,
                actionIcon: Icons.open_in_new_rounded,
                onAction: () => _openUrl(context, _ensureUrl(widget.clinic.website!)),
              ),
            _InfoTile(
              icon: Icons.directions_walk_outlined,
              label: 'Distance',
              value: widget.distanceKm == null
                  ? 'Enable precise location to calculate distance'
                  : '${widget.distanceKm!.toStringAsFixed(1)} km from you',
            ),
            const SizedBox(height: 12),
            _ClinicMapPreview(
              clinicName: widget.clinic.name,
              latitude: widget.clinic.location.latitude,
              longitude: widget.clinic.location.longitude,
              altitude: widget.clinic.altitude,
            ),
          ],
        ),
      ),
    );
  }
}

class _ClinicMapPreview extends StatefulWidget {
  const _ClinicMapPreview({
    required this.clinicName,
    required this.latitude,
    required this.longitude,
    this.altitude,
  });

  final String clinicName;
  final double latitude;
  final double longitude;
  final String? altitude;

  @override
  State<_ClinicMapPreview> createState() => _ClinicMapPreviewState();
}

class _ClinicMapPreviewState extends State<_ClinicMapPreview> {
  static const MethodChannel _mapsConfigChannel = MethodChannel(
    'com.yegna_health/maps_config',
  );
  static const double _maxAcceptedAccuracyMeters = 80;
  static const double _routeRefreshDistanceMeters = 30;
  static const Duration _routeRefreshInterval = Duration(seconds: 15);

  gmaps.GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionSubscription;
  Set<gmaps.Marker> _markers = {};
  Set<gmaps.Polyline> _polylines = {};
  bool _isMapLoading = true;
  bool _isLoadingRoute = false;
  bool _isShowingRoute = false;
  bool _isNavigating = false;
  bool _hasLocationPermission = false;
  bool _isDirectionsRequestActive = false;
  String? _routeNotice;
  bool _routeNoticeIsError = false;
  String? _routeDistanceLabel;
  String? _routeDurationLabel;
  Position? _lastRouteOrigin;
  DateTime? _lastRouteRefreshAt;
  String? _mapsApiKey;
  late String _webMapUrl;

  @override
  void initState() {
    super.initState();
    _webMapUrl = _buildGoogleMapsEmbedUrl(
      latitude: widget.latitude,
      longitude: widget.longitude,
    );
    _initializeMarkers();
    if (!kIsWeb) {
      unawaited(_syncLocationPermissionState());
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  void _initializeMarkers() {
    setState(() {
      _markers = {_buildClinicMarker()};
      _polylines = {};
      _isMapLoading = false;
    });
  }

  gmaps.Marker _buildClinicMarker() {
    return gmaps.Marker(
      markerId: const gmaps.MarkerId('clinic'),
      position: gmaps.LatLng(widget.latitude, widget.longitude),
      infoWindow: gmaps.InfoWindow(
        title: widget.clinicName,
        snippet: widget.altitude != null ? 'Altitude: ${widget.altitude}m' : null,
      ),
      icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueBlue),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
        color: colorScheme.surface,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Facility Location Map',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Latitude/Longitude: ${widget.latitude.toStringAsFixed(6)}/${widget.longitude.toStringAsFixed(6)}',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _isLoadingRoute ? null : () => _openInMaps(context),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Open in Maps'),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 240,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (kIsWeb)
                  buildGoogleMapIFrame(
                    viewType: _buildMapViewType(widget.latitude, widget.longitude, 'web'),
                    embedUrl: _webMapUrl,
                  )
                else
                  gmaps.GoogleMap(
                    initialCameraPosition: gmaps.CameraPosition(
                      target: gmaps.LatLng(widget.latitude, widget.longitude),
                      zoom: 15,
                    ),
                    markers: _markers,
                    polylines: _polylines,
                    onMapCreated: (gmaps.GoogleMapController controller) {
                      _mapController = controller;
                      setState(() {
                        _isMapLoading = false;
                      });
                    },
                    myLocationEnabled: _hasLocationPermission,
                    myLocationButtonEnabled: _hasLocationPermission,
                    compassEnabled: true,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                  ),
                if (_isMapLoading && !kIsWeb)
                  Container(
                    color: colorScheme.surface.withOpacity(0.75),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
                if (_isLoadingRoute)
                  Container(
                    color: colorScheme.surface.withOpacity(0.65),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
                if (widget.altitude != null && widget.altitude!.trim().isNotEmpty)
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withOpacity(0.94),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Text(
                        'Altitude: ${widget.altitude!.trim()} m',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoadingRoute ? null : () => _navigateToClinic(context),
                        icon: Icon(
                          _isNavigating ? Icons.stop_circle_outlined : Icons.route_rounded,
                          size: 18,
                        ),
                        label: Text(_isNavigating ? 'Stop Navigation' : 'Navigate'),
                      ),
                    ),
                  ],
                ),
                if (_routeDistanceLabel != null || _routeDurationLabel != null || _isNavigating) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_routeDistanceLabel != null)
                        _MapMetricChip(
                          icon: Icons.straighten_rounded,
                          label: _routeDistanceLabel!,
                        ),
                      if (_routeDurationLabel != null)
                        _MapMetricChip(
                          icon: Icons.schedule_rounded,
                          label: _routeDurationLabel!,
                        ),
                      if (_isNavigating)
                        const _MapMetricChip(
                          icon: Icons.my_location_rounded,
                          label: 'Live',
                        ),
                    ],
                  ),
                ],
                if (_routeNotice != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _routeNotice!,
                    style: TextStyle(
                      color: _routeNoticeIsError
                          ? colorScheme.error
                          : colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToClinic(BuildContext context) async {
    if (_isNavigating) {
      _resetMapToClinic();
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoadingRoute = true;
      _routeNotice = null;
      _routeNoticeIsError = false;
    });

    try {
      final userPosition = await _getCurrentUserPosition();
      if (userPosition != null) {
        await _startLiveNavigation(userPosition);
      } else {
        setState(() {
          _routeNotice = 'Unable to get your location. Please enable location services.';
          _routeNoticeIsError = true;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _routeNotice = 'Unable to start navigation right now.';
        _routeNoticeIsError = true;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingRoute = false;
      });
    }
  }

  Future<void> _syncLocationPermissionState() async {
    await _ensureLocationAccess(requestIfNeeded: false);
  }

  Future<void> _startLiveNavigation(Position initialPosition) async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;

    if (mounted) {
      setState(() {
        _isNavigating = true;
        _isShowingRoute = true;
      });
    }

    await _refreshRouteForPosition(
      initialPosition,
      forceDirectionsRefresh: true,
      focusRoute: true,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
    ).listen(
      (position) {
        final shouldRefresh = _shouldRefreshRoute(position);
        unawaited(
          _refreshRouteForPosition(
            position,
            forceDirectionsRefresh: shouldRefresh,
            focusRoute: false,
          ),
        );
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _routeNotice =
              'Live location updates paused. Check your location permission and GPS.';
          _routeNoticeIsError = true;
        });
      },
    );
  }

  bool _shouldRefreshRoute(Position position) {
    if (_lastRouteOrigin == null || _lastRouteRefreshAt == null) {
      return true;
    }

    final movedDistance = Geolocator.distanceBetween(
      _lastRouteOrigin!.latitude,
      _lastRouteOrigin!.longitude,
      position.latitude,
      position.longitude,
    );

    return movedDistance >= _routeRefreshDistanceMeters ||
        DateTime.now().difference(_lastRouteRefreshAt!) >= _routeRefreshInterval;
  }

  Future<void> _refreshRouteForPosition(
    Position userPosition, {
    required bool forceDirectionsRefresh,
    required bool focusRoute,
  }) async {
    if (_isDirectionsRequestActive) {
      return;
    }

    if (!forceDirectionsRefresh && _polylines.isNotEmpty) {
      return;
    }

    _isDirectionsRequestActive = true;
    try {
      final routeSnapshot = await _resolveRouteSnapshot(userPosition);
      if (!mounted) return;

      setState(() {
        _markers = {_buildClinicMarker()};
        _polylines = {
          gmaps.Polyline(
            polylineId: const gmaps.PolylineId('route'),
            points: routeSnapshot.points,
            color: const Color(0xFF0F74B8),
            width: 5,
            geodesic: true,
          ),
        };
        _isShowingRoute = true;
        _isNavigating = true;
        _routeDistanceLabel = routeSnapshot.distanceLabel;
        _routeDurationLabel = routeSnapshot.durationLabel;
        _routeNotice = routeSnapshot.notice ?? 'Live navigation active on the map.';
        _routeNoticeIsError = routeSnapshot.isNoticeError;
        _lastRouteOrigin = userPosition;
        _lastRouteRefreshAt = DateTime.now();
        if (kIsWeb) {
          _webMapUrl = _buildGoogleMapsDirectionsEmbedUrl(
            originLat: userPosition.latitude,
            originLon: userPosition.longitude,
            destinationLat: widget.latitude,
            destinationLon: widget.longitude,
          );
        }
      });

      if (focusRoute) {
        await _fitMapToRoute(userPosition, routeSnapshot.points);
      }
    } finally {
      _isDirectionsRequestActive = false;
    }
  }

  Future<_RouteSnapshot> _resolveRouteSnapshot(Position userPosition) async {
    final googleRoute = await _fetchGoogleDirectionsRoute(userPosition);
    if (googleRoute != null) {
      return googleRoute;
    }

    final distanceMeters = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      widget.latitude,
      widget.longitude,
    );

    return _RouteSnapshot(
      points: [
        gmaps.LatLng(userPosition.latitude, userPosition.longitude),
        gmaps.LatLng(widget.latitude, widget.longitude),
      ],
      distanceLabel: _formatDistance(distanceMeters),
      durationLabel: null,
      notice:
          'Live navigation is active. Add a Google Maps Directions-enabled API key to show road routes instead of a direct line.',
      isNoticeError: false,
    );
  }

  Future<_RouteSnapshot?> _fetchGoogleDirectionsRoute(Position userPosition) async {
    final mapsApiKey = await _getMapsApiKey();
    if (mapsApiKey.isEmpty) {
      return null;
    }

    try {
      final routeUri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/directions/json',
        {
          'origin': '${userPosition.latitude},${userPosition.longitude}',
          'destination': '${widget.latitude},${widget.longitude}',
          'mode': 'driving',
          'key': mapsApiKey,
        },
      );

      final response = await http.get(routeUri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        return null;
      }

      final payload = jsonDecode(response.body);
      if (payload is! Map<String, dynamic> || payload['status'] != 'OK') {
        return null;
      }

      final routes = payload['routes'];
      if (routes is! List || routes.isEmpty || routes.first is! Map<String, dynamic>) {
        return null;
      }

      final route = routes.first as Map<String, dynamic>;
      final overviewPolyline = route['overview_polyline'];
      if (overviewPolyline is! Map<String, dynamic>) {
        return null;
      }

      final encodedPolyline = overviewPolyline['points'];
      if (encodedPolyline is! String || encodedPolyline.isEmpty) {
        return null;
      }

      final routePoints = _decodePolyline(encodedPolyline);
      if (routePoints.length < 2) {
        return null;
      }

      String? distanceLabel;
      String? durationLabel;
      final legs = route['legs'];
      if (legs is List && legs.isNotEmpty && legs.first is Map<String, dynamic>) {
        final firstLeg = legs.first as Map<String, dynamic>;
        final distance = firstLeg['distance'];
        final duration = firstLeg['duration'];
        if (distance is Map<String, dynamic>) {
          distanceLabel = distance['text'] as String?;
        }
        if (duration is Map<String, dynamic>) {
          durationLabel = duration['text'] as String?;
        }
      }

      return _RouteSnapshot(
        points: routePoints,
        distanceLabel: distanceLabel,
        durationLabel: durationLabel,
        notice: 'Live navigation active with Google Maps routing.',
        isNoticeError: false,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String> _getMapsApiKey() async {
    if (_mapsApiKey != null) {
      return _mapsApiKey!;
    }

    try {
      final rawApiKey =
          await _mapsConfigChannel.invokeMethod<String>('getGoogleMapsApiKey') ?? '';
      _mapsApiKey = _sanitizeMapsApiKey(rawApiKey);
    } catch (_) {
      _mapsApiKey = '';
    }

    return _mapsApiKey!;
  }

  String _sanitizeMapsApiKey(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.startsWith(r'$(')) {
      return '';
    }
    return trimmed;
  }

  Future<Position?> _getCurrentUserPosition() async {
    try {
      final hasLocationAccess = await _ensureLocationAccess(requestIfNeeded: true);
      if (!hasLocationAccess) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );

      return await _getBetterPositionIfNeeded(position);
    } catch (_) {
      return null;
    }
  }

  Future<bool> _ensureLocationAccess({required bool requestIfNeeded}) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    var permission = await Geolocator.checkPermission();

    if (requestIfNeeded && permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    final hasPermission =
        permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
    final isGranted = serviceEnabled && hasPermission;

    if (mounted && _hasLocationPermission != isGranted) {
      setState(() {
        _hasLocationPermission = isGranted;
      });
    }

    return isGranted;
  }

  Future<void> _openExternalDirections(Position? userPosition) async {
    final externalUrl = _buildExternalDirectionsUrl(
      originLat: userPosition?.latitude,
      originLon: userPosition?.longitude,
      destinationLat: widget.latitude,
      destinationLon: widget.longitude,
    );

    final opened = await launchUrl(
      Uri.parse(externalUrl),
      mode: LaunchMode.externalApplication,
    );

    if (!mounted) return;
    setState(() {
      _routeNotice = opened ? 'Opened Google Maps.' : 'Unable to open Google Maps.';
      _routeNoticeIsError = !opened;
    });
  }

  Future<void> _openInMaps(BuildContext context) async {
    final userPosition = await _getCurrentUserPosition();
    if (userPosition != null) {
      await _openExternalDirections(userPosition);
      return;
    }

    await _openUrl(
      context,
      _buildExternalDirectionsUrl(
        destinationLat: widget.latitude,
        destinationLon: widget.longitude,
      ),
    );
  }

  Future<void> _fitMapToRoute(
    Position userPosition,
    List<gmaps.LatLng> routePoints,
  ) async {
    final controller = _mapController;
    if (controller == null) {
      return;
    }

    final boundsPoints = <gmaps.LatLng>[
      gmaps.LatLng(userPosition.latitude, userPosition.longitude),
      gmaps.LatLng(widget.latitude, widget.longitude),
      ...routePoints,
    ];

    final bounds = _calculateBounds(boundsPoints);
    if (bounds == null) {
      await controller.animateCamera(
        gmaps.CameraUpdate.newCameraPosition(
          gmaps.CameraPosition(
            target: gmaps.LatLng(widget.latitude, widget.longitude),
            zoom: 15,
          ),
        ),
      );
      return;
    }

    await controller.animateCamera(
      gmaps.CameraUpdate.newLatLngBounds(bounds, 56),
    );
  }

  gmaps.LatLngBounds? _calculateBounds(List<gmaps.LatLng> points) {
    if (points.isEmpty) {
      return null;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLon = points.first.longitude;
    double maxLon = points.first.longitude;

    for (final point in points.skip(1)) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLon) minLon = point.longitude;
      if (point.longitude > maxLon) maxLon = point.longitude;
    }

    if (minLat == maxLat && minLon == maxLon) {
      return null;
    }

    return gmaps.LatLngBounds(
      southwest: gmaps.LatLng(minLat, minLon),
      northeast: gmaps.LatLng(maxLat, maxLon),
    );
  }

  void _resetMapToClinic() {
    _positionSubscription?.cancel();
    _positionSubscription = null;

    setState(() {
      _markers = {_buildClinicMarker()};
      _polylines = {};
      _isShowingRoute = false;
      _isNavigating = false;
      _isMapLoading = false;
      _routeNotice = null;
      _routeNoticeIsError = false;
      _routeDistanceLabel = null;
      _routeDurationLabel = null;
      _lastRouteOrigin = null;
      _lastRouteRefreshAt = null;
      _webMapUrl = _buildGoogleMapsEmbedUrl(
        latitude: widget.latitude,
        longitude: widget.longitude,
      );
    });

    final controller = _mapController;
    if (controller != null) {
      controller.animateCamera(
        gmaps.CameraUpdate.newCameraPosition(
          gmaps.CameraPosition(
            target: gmaps.LatLng(widget.latitude, widget.longitude),
            zoom: 15,
          ),
        ),
      );
    }
  }

  Future<Position> _getBetterPositionIfNeeded(Position first) async {
    if (first.accuracy <= _maxAcceptedAccuracyMeters) {
      return first;
    }

    try {
      await Future.delayed(const Duration(milliseconds: 1200));
      final second = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );
      return second.accuracy < first.accuracy ? second : first;
    } catch (_) {
      return first;
    }
  }
}

class _RouteSnapshot {
  const _RouteSnapshot({
    required this.points,
    required this.distanceLabel,
    required this.durationLabel,
    required this.notice,
    required this.isNoticeError,
  });

  final List<gmaps.LatLng> points;
  final String? distanceLabel;
  final String? durationLabel;
  final String? notice;
  final bool isNoticeError;
}

class _MapMetricChip extends StatelessWidget {
  const _MapMetricChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.45),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String _buildMapViewType(double latitude, double longitude, String key) {
  final raw = 'clinic_map_${latitude.toStringAsFixed(6)}_${longitude.toStringAsFixed(6)}_$key';
  return raw.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
}

String _buildGoogleMapsEmbedUrl({
  required double latitude,
  required double longitude,
}) {
  return 'https://maps.google.com/maps?q=${latitude},${longitude}&z=15&output=embed';
}

String _buildGoogleMapsDirectionsEmbedUrl({
  required double originLat,
  required double originLon,
  required double destinationLat,
  required double destinationLon,
}) {
  return 'https://www.google.com/maps?saddr=$originLat,$originLon&daddr=$destinationLat,$destinationLon&output=embed';
}

const String _configuredBaseUrl = String.fromEnvironment(
  'MOBILE_API_BASE_URL',
  defaultValue: 'http://10.0.2.2:4000',
);

String _buildExternalDirectionsUrl({
  double? originLat,
  double? originLon,
  required double destinationLat,
  required double destinationLon,
}) {
  return Uri.https(
    'www.google.com',
    '/maps/dir/',
    {
      'api': '1',
      if (originLat != null && originLon != null)
        'origin': '${originLat.toStringAsFixed(6)},${originLon.toStringAsFixed(6)}',
      'destination': '${destinationLat.toStringAsFixed(6)},${destinationLon.toStringAsFixed(6)}',
      'travelmode': 'driving',
    },
  ).toString();
}

String _formatDistance(double meters) {
  if (meters >= 1000) {
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
  return '${meters.round()} m';
}

List<gmaps.LatLng> _decodePolyline(String encoded) {
  final points = <gmaps.LatLng>[];
  var index = 0;
  var latitude = 0;
  var longitude = 0;

  while (index < encoded.length) {
    var result = 0;
    var shift = 0;
    int byte;

    do {
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20 && index < encoded.length);

    final latitudeChange = (result & 1) == 0 ? (result >> 1) : ~(result >> 1);
    latitude += latitudeChange;

    result = 0;
    shift = 0;

    do {
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20 && index < encoded.length);

    final longitudeChange = (result & 1) == 0 ? (result >> 1) : ~(result >> 1);
    longitude += longitudeChange;

    points.add(
      gmaps.LatLng(latitude / 1e5, longitude / 1e5),
    );
  }

  return points;
}

Widget _buildClinicImage(String imagePath) {
  final resolvedImagePath = _resolveClinicImagePath(imagePath);
  if (resolvedImagePath == null) {
    return _buildImageFallback();
  }

  if (resolvedImagePath.startsWith('assets/')) {
    return Image.asset(
      resolvedImagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImageFallback(),
    );
  }

  final dataBytes = _tryDecodeDataImage(resolvedImagePath);
  if (dataBytes != null) {
    return Image.memory(
      dataBytes,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImageFallback(),
    );
  }

  if (resolvedImagePath.startsWith('http://') || resolvedImagePath.startsWith('https://')) {
    return Image.network(
      resolvedImagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImageFallback(),
    );
  }

  return Image.network(
    resolvedImagePath,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => _buildImageFallback(),
  );
}

String? _resolveClinicImagePath(String? rawPath) {
  if (rawPath == null) return null;

  final path = rawPath.trim();
  if (path.isEmpty) return null;
  if (path.startsWith('assets/')) return path;
  if (path.startsWith('data:image/')) return path;
  if (path.startsWith('http://') || path.startsWith('https://')) return path;

  final base = _apiOrigin();
  if (path.startsWith('/')) {
    return '$base$path';
  }

  return '$base/$path';
}

String _apiOrigin() {
  final configuredBaseUrl = _configuredBaseUrl.replaceAll(RegExp(r'/+$'), '');

  if (kIsWeb) {
    return 'http://localhost:4000';
  }

  if (configuredBaseUrl.endsWith('/api/mobile/auth')) {
    return configuredBaseUrl.replaceFirst(RegExp(r'/api/mobile/auth$'), '');
  }

  if (configuredBaseUrl.endsWith('/api/v1/healthcare-facilities')) {
    return configuredBaseUrl.replaceFirst(
      RegExp(r'/api/v1/healthcare-facilities$'),
      '',
    );
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

Widget _buildImageFallback() {
  return Container(
    color: const Color(0xFFE6EEF2),
    alignment: Alignment.center,
    child: const Icon(
      Icons.local_hospital_outlined,
      size: 44,
      color: Color(0xFF005C8F),
    ),
  );
}

String _ensureUrl(String raw) {
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
  return 'https://$raw';
}

Future<void> _openUrl(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open link')),
    );
  }
}

Future<void> _copyValue(BuildContext context, String value) async {
  await Clipboard.setData(ClipboardData(text: value));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Copied')),
  );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final IconData? actionIcon;
  final VoidCallback? onTap;
  final VoidCallback? onAction;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.actionIcon,
    this.onTap,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tile = Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface.withOpacity(0.7) : Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: colorScheme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (onAction != null && actionIcon != null) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: onAction,
              icon: Icon(actionIcon),
              color: colorScheme.primary,
              visualDensity: VisualDensity.compact,
              tooltip: 'Open',
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return tile;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: tile,
    );
  }
}
