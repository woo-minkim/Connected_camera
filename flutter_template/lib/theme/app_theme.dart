import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF8FAFC); // Slate-50 (Off-white)
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  
  static const Color textPrimary = Color(0xFF334155); // Slate-700
  static const Color textSecondary = Color(0xFF94A3B8); // Slate-400
  
  static const Color accentBlue = Color(0xFF3B82F6); // Blue-500
  static const Color accentOrange = Color(0xFFFB923C); // Orange-400
  
  static const Color border = Color(0xFFE2E8F0); // Slate-200
}

class AppTextStyles {
  static const TextStyle displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
    height: 1.1,
    fontFamily: 'Roboto', 
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );
}
