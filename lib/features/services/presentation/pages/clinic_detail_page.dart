import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart'
    if (dart.library.html) '../widgets/navigation_web_stub.dart';

import '../../domain/entities/clinic_entity.dart';
import '../widgets/google_map_iframe_stub.dart'
    if (dart.library.html) '../widgets/google_map_iframe_web.dart';

class ClinicDetailPage extends StatefulWidget {
  final ClinicEntity clinic;
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
  static const double _maxAcceptedAccuracyMeters = 80;

  late final WebViewController _webViewController;
  bool _isMapLoading = true;
  bool _isLoadingRoute = false;
  bool _isNavigating = false;
  bool _hasLocationPermission = false;
  bool _hasMapError = false;
  String? _routeNotice;
  bool _routeNoticeIsError = false;
  String? _routeDistanceLabel;
  String? _routeDurationLabel;
  late String _webMapUrl;

  @override
  void initState() {
    super.initState();
    _webMapUrl = _buildGoogleMapsEmbedUrl(
      latitude: widget.latitude,
      longitude: widget.longitude,
    );
    if (kIsWeb) {
      _isMapLoading = false;
    } else {
      _initializeNativeMap();
      unawaited(_syncLocationPermissionState());
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeNativeMap() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isMapLoading = true;
              _hasMapError = false;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _isMapLoading = false);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame != true || !mounted) return;
            setState(() {
              _isMapLoading = false;
              _hasMapError = true;
              _routeNotice =
                  'Map failed to load inside the app. You can still use Open in Maps.';
              _routeNoticeIsError = true;
            });
          },
        ),
      );

    unawaited(_loadMapUrl(_webMapUrl));
  }

  Future<void> _loadMapUrl(String url) async {
    if (!mounted) return;

    setState(() {
      _webMapUrl = url;
      if (!kIsWeb) {
        _isMapLoading = true;
        _hasMapError = false;
      }
    });

    if (kIsWeb) {
      return;
    }

    await _webViewController.loadHtmlString(
      _buildMobileMapFrameHtml(url),
      baseUrl: 'https://www.google.com',
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
                else if (_hasMapError)
                  Container(
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 42,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Map unavailable in the app right now.',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Use Open in Maps while the in-app view reloads.',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  WebViewWidget(controller: _webViewController),
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
                        onPressed: _isLoadingRoute ? null : _navigateToClinic,
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
                          icon: Icons.route_rounded,
                          label: 'In App',
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

  Future<void> _navigateToClinic() async {
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
        await _showNavigationRoute(userPosition);
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

  Future<void> _showNavigationRoute(Position userPosition) async {
    final distanceMeters = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      widget.latitude,
      widget.longitude,
    );

    final directionsUrl = _buildGoogleMapsDirectionsEmbedUrl(
      originLat: userPosition.latitude,
      originLon: userPosition.longitude,
      destinationLat: widget.latitude,
      destinationLon: widget.longitude,
    );

    if (!mounted) return;
    setState(() {
      _isNavigating = true;
      _routeDistanceLabel = _formatDistance(distanceMeters);
      _routeDurationLabel = null;
      _routeNotice = 'Route loaded inside the app.';
      _routeNoticeIsError = false;
    });

    await _loadMapUrl(directionsUrl);
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

  void _resetMapToClinic() {
    final clinicUrl = _buildGoogleMapsEmbedUrl(
      latitude: widget.latitude,
      longitude: widget.longitude,
    );

    setState(() {
      _isNavigating = false;
      _routeNotice = null;
      _routeNoticeIsError = false;
      _routeDistanceLabel = null;
      _routeDurationLabel = null;
    });

    unawaited(_loadMapUrl(clinicUrl));
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

String _buildMobileMapFrameHtml(String embedUrl) {
  final safeUrl = const HtmlEscape().convert(embedUrl);
  return '''
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"
    >
    <style>
      html, body {
        margin: 0;
        padding: 0;
        width: 100%;
        height: 100%;
        overflow: hidden;
        background: #f8fafc;
      }
      iframe {
        border: 0;
        width: 100%;
        height: 100%;
      }
    </style>
  </head>
  <body>
    <iframe
      src="$safeUrl"
      allowfullscreen
      loading="eager"
      referrerpolicy="no-referrer-when-downgrade"
    ></iframe>
  </body>
</html>
''';
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
