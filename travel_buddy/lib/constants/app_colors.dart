import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF7B1FA2);
  static const Color secondary = Color(0xFF9575CD);
  static const Color accent = Color(0xFFFFC107);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFF3E5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
  
  // Button Gradient
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF7B1FA2), Color(0xFF512DA8)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Card Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1A000000);
  
  // Input Field Colors
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputFocus = Color(0xFF7B1FA2);
  static const Color inputBackground = Color(0xFFFAFAFA);
} 