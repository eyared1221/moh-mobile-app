// ignore_for_file: unused_element

import 'package:flutter/material.dart';

class WebViewController {
  WebViewController();

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
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.ondemand_video_rounded, size: 44, color: Colors.grey[500]),
          const SizedBox(height: 8),
          Text(
            'Inline video preview is not available here',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Use the mobile app to play this video inside the page.',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
