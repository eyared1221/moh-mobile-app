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

  int get _mappedIndex {
    switch (currentIndex) {
      case 1:
        return 3;
      case 3:
        return 4;
      default:
        return currentIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GuestBottomNav(
      currentIndex: _mappedIndex,
      ageRange: _resolvedAgeRange,
      userName: userName,
      isLoggedIn: true,
    );
  }
}
