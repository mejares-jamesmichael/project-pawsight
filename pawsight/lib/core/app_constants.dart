import 'package:flutter/material.dart';

/// App-wide constants for spacing and layout
class AppSpacing {
  /// 4.0
  static const double xs = 4.0;
  
  /// 8.0
  static const double sm = 8.0;
  
  /// 12.0
  static const double md = 12.0;
  
  /// 16.0
  static const double lg = 16.0;
  
  /// 24.0
  static const double xl = 24.0;
  
  /// 32.0
  static const double xxl = 32.0;
}

/// App-wide constants for specific brand/social colors
class AppColors {
  static const Color facebook = Color(0xFF1877F2);
  static const Color instagram = Color(0xFFE4405F);
  
  // Semantic colors for moods (if not using theme)
  static const Color moodHappy = Colors.green;
  static const Color moodRelaxed = Colors.blue;
  static const Color moodFearful = Colors.orange;
  static const Color moodAggressive = Colors.red;
  static const Color moodMixed = Colors.purple;
}
