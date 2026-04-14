import 'package:flutter/material.dart';

import 'guest_bottom_nav.dart';

class AppBottomNav extends StatelessWidget {
  final String? ageRange;
  final String? age;
  final int currentIndex;
  final String? userName;

  const AppBottomNav({
    super.key,
    this.ageRange,
    this.age,
    required this.currentIndex,
    this.userName,
  });

  String get _resolvedAgeRange => ageRange ?? age ?? '10-14';

  @override
  Widget build(BuildContext context) {
    return GuestBottomNav(
      currentIndex: currentIndex,
      ageRange: _resolvedAgeRange,
      userName: userName,
      isLoggedIn: true,
    );
  }
}
