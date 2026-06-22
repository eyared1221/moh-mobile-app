import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

String themeModeLabel(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
    ThemeMode.system => 'Light',
  };
}

Future<void> loadSavedTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final t = prefs.getString('themeMode') ?? 'light';
  themeNotifier.value = switch (t) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.light,
  };
}

Future<void> setSavedTheme(ThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  final resolvedMode = mode == ThemeMode.dark ? ThemeMode.dark : ThemeMode.light;
  await prefs.setString(
    'themeMode',
    resolvedMode == ThemeMode.dark ? 'dark' : 'light',
  );
  themeNotifier.value = resolvedMode;
}

Future<void> toggleTheme() async {
  final next = themeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  await setSavedTheme(next);
}
