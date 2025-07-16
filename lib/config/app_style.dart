// lib/config/app_styles.dart

import 'package:flutter/material.dart';

// --- Warna ---
const kBackgroundColor = Color(0xFFF7F8FC);
const kPrimaryTextColor = Color(0xFF333E53);
const kSecondaryTextColor = Color(0xFF8A94A7);
const kPrimaryGradient = LinearGradient(
  colors: [Color(0xFF6A79FF), Color(0xFF8C52FF)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

//  gradiens untuk User
const kUserGradient = LinearGradient(
  colors: [Color(0xFF20BF55), Color(0xFF01BAEF)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kOrangeColor = Color(0xFFF39C12);

// --- Style Teks ---
TextStyle headingStyle(BuildContext context, {bool isDesktop = false}) {
  return TextStyle(
    fontSize: isDesktop ? 24 : 20,
    fontWeight: FontWeight.bold,
    color: kPrimaryTextColor,
  );
}

TextStyle subheadingStyle(BuildContext context, {bool isDesktop = false}) {
  return TextStyle(fontSize: isDesktop ? 16 : 14, color: kSecondaryTextColor);
}
