import 'package:flutter/material.dart';

import 'pages/home_page.dart' as pages;

// Backward-compatible wrapper for older imports that still use ageRange.
class HomePage extends pages.HomePage {
  const HomePage({
    Key? key,
    required String ageRange,
    String? userName,
  }) : super(
          key: key,
          age: ageRange,
          userName: userName,
        );
}
