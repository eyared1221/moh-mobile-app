// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

final Set<String> _registeredViewTypes = <String>{};
final Map<String, html.IFrameElement> _iframeElements = <String, html.IFrameElement>{};

Widget buildGoogleMapIFrame({
  required String viewType,
  required String embedUrl,
}) {
  if (_registeredViewTypes.add(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = embedUrl
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true;
      _iframeElements[viewType] = iframe;
      return iframe;
    });
  }

  final iframe = _iframeElements[viewType];
  if (iframe != null && iframe.src != embedUrl) {
    iframe.src = embedUrl;
  }

  return HtmlElementView(viewType: viewType);
}
