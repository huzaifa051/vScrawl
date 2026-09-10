import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // splash screen background
  static const Color splashBackground = Color(0xFF484D54);

  // Page background for login/signup
  static const Color pageBackground = Color(0xFFF9F9F9);

  // Brand accent (checkbox icon, "SCRAWL" text, buttons, links)
  static const Color accent = Color(0xFFF8B717);

  // Text Colors
  static const Color textPrimary = Color(0xFF484D54);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Input styling

  static const Color inputBorder = Color(0xEFEFEFEF);
  static const Color inputFill = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFF13A3F);

  static const Color statPending = Color(0xFFF9CC7B);
  static const Color statSigned = Color(0xFF7EC0E4);
  static const Color statSent = Color(0xFFD3D0A8);
  static const Color statCompleted = Color(0xFF99E6A8);
  static const Color statTemplates = Color(0xFF6EBDCF);
  static const Color statActiveUsers = Color(0xFF7DB9B3);

}

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle splashTagLine = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight(300),
    color: AppColors.textOnDark,
  );

  static const TextStyle heading = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight(800),
    color: AppColors.textPrimary,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight(300),
    color: Colors.black,
  );

  static const errorText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight(500),
    color: AppColors.error,
  );

  static const linkAccent = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight(400),
    color: AppColors.accent,
  );

  static const buttonText = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight(600),
    color: Colors.white,
  );
}
