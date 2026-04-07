import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class LearningImage extends StatelessWidget {
  final String imageUrl;
  final bool isAssetImage;
  final BoxFit fit;
  final Alignment alignment;
  final Widget Function(BuildContext context) errorBuilder;

  const LearningImage({
    super.key,
    required this.imageUrl,
    required this.isAssetImage,
    required this.errorBuilder,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return errorBuilder(context);
    }

    if (isAssetImage) {
      return Image.asset(
        imageUrl,
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, __, ___) => errorBuilder(context),
      );
    }

    final bytes = _tryDecodeDataImage(imageUrl);
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, __, ___) => errorBuilder(context),
      );
    }

    return Image.network(
      imageUrl,
      fit: fit,
      alignment: alignment,
      errorBuilder: (_, __, ___) => errorBuilder(context),
    );
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
}
