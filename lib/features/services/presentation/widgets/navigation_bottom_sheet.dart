import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../models/clinic.dart';

// Only import webview for non-web platforms
import 'package:webview_flutter/webview_flutter.dart' if (dart.library.html) 'navigation_web_stub.dart';

class NavigationBottomSheet extends StatefulWidget {
  final Position userPosition;
  final LatLng clinicPosition;
  final String clinicName;

  const NavigationBottomSheet({
    super.key,
    required this.userPosition,
    required this.clinicPosition,
    required this.clinicName,
  });

  @override
  State<NavigationBottomSheet> createState() => _NavigationBottomSheetState();
}

class _NavigationBottomSheetState extends State<NavigationBottomSheet> {
  late final WebViewController _webViewController;
  bool _isMapLoading = true;
  bool _hasMapError = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initializeMap();
    } else {
      setState(() {
        _isMapLoading = false;
      });
    }
  }

  void _initializeMap() {
    final directionsUrl = _buildDirectionsUrl();
    
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
            if (error.isForMainFrame != true) return;
            if (!mounted) return;
            setState(() {
              _isMapLoading = false;
              _hasMapError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(directionsUrl));
  }

  String _buildDirectionsUrl() {
    return 'https://www.google.com/maps/dir/?api=1&origin=${widget.userPosition.latitude},${widget.userPosition.longitude}&destination=${widget.clinicPosition.latitude},${widget.clinicPosition.longitude}&travelmode=driving';
  }

  Future<void> _launchExternalNavigation() async {
    final url = _buildDirectionsUrl();
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.navigation, color: Colors.blue[700]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Navigation',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Routes to ${widget.clinicName}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Location inputs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.my_location, color: Colors.green[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your location',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.clinicName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Map
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    if (kIsWeb)
                      // Web platform - show message
                      Container(
                        color: Colors.grey[100],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map_outlined, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Interactive map not available on web',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Use "Start Navigation" button below',
                                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      // Mobile platform - show webview
                      WebViewWidget(controller: _webViewController),
                    
                    if (_isMapLoading && !kIsWeb)
                      Container(
                        color: Colors.white,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    if (_hasMapError && !kIsWeb)
                      Container(
                        color: Colors.grey[100],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map_outlined, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Map unavailable',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _launchExternalNavigation,
                    icon: const Icon(Icons.directions),
                    label: const Text('Start Navigation in Google Maps'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
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
