import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

String themeModeLabel(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
    ThemeMode.system => 'Use system default',
  };
}

Future<void> loadSavedTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final t = prefs.getString('themeMode') ?? 'system';
  themeNotifier.value = switch (t) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}

Future<void> setSavedTheme(ThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('themeMode', mode == ThemeMode.light ? 'light' : (mode == ThemeMode.dark ? 'dark' : 'system'));
  themeNotifier.value = mode;
}

Future<void> toggleTheme() async {
  final next = themeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  await setSavedTheme(next);
}
