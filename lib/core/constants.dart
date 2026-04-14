// constants.dart
import 'package:flutter/material.dart';

const kPrimary = Color(0xFF005C8F);
const kSecondary = Color(0xFF00A8A8);
const kBg = Color(0xFFF6F9FB);
const kPrimarySoft = Color(0xFFEAF3F8);
const kPrimarySoftAlt = Color(0xFFD8E6EF);
const kPrimaryStroke = Color(0xFFC6D7E3);
const kPrimaryGlow = Color(0xFFA7C8DA);

final ButtonStyle navButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: kPrimary,
  padding: const EdgeInsets.symmetric(vertical: 14),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
);
