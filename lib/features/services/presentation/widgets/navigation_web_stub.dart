// Stub implementation for web platform
// This file provides empty implementations to avoid webview issues on web

import 'package:flutter/material.dart';

class WebViewController {
  WebViewController() {
    // Empty constructor for web
  }
  
  Future<void> setJavaScriptMode(JavaScriptMode mode) async {}
  
  Future<void> setBackgroundColor(Color color) async {}
  
  Future<void> setNavigationDelegate(NavigationDelegate delegate) async {}
  
  Future<void> loadRequest(Uri uri) async {}

  Future<void> loadHtmlString(String html, {String? baseUrl}) async {}
}

class JavaScriptMode {
  static const unrestricted = JavaScriptMode._('unrestricted');
  static const disabled = JavaScriptMode._('disabled');
  
  const JavaScriptMode._(this.name);
  final String name;
}

class NavigationDelegate {
  NavigationDelegate({
    required Function(String) onPageStarted,
    required Function(String) onPageFinished,
    required Function(WebResourceError) onWebResourceError,
  });
}

class WebResourceError {
  final bool isForMainFrame;
  WebResourceError({required this.isForMainFrame});
}

class WebViewWidget extends StatelessWidget {
  final WebViewController controller;
  
  const WebViewWidget({super.key, required this.controller});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Map view not available on web',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Please use the mobile app for full navigation features',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
