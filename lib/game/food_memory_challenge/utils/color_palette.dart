import 'package:flutter/material.dart';

/// Color palette for Food Memory Challenge - Restaurant themed
class ColorPalette {
  // Primary colors - Restaurant branded
  static const Color primaryOrange = Color(0xFFFF6B35); // Vibrant orange
  static const Color accentYellow = Color(0xFFFFA500); // Golden yellow
  static const Color creamBackground = Color(0xFFFFF5E6); // Cream
  static const Color deepBlack = Color(0xFF1A1A1A); // Deep black
  static const Color accentRed = Color(0xFFE63946); // Restaurant red

  // Card colors
  static const Color cardBackground = Color(0xFF2D2D2D); // Dark card
  static const Color cardGlowLight = Color(0xFFFFD700); // Gold glow
  static const Color cardGlowOrange = Color(0xFFFF6B35); // Orange glow

  // Game background
  static const LinearGradient gameBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F0F0F), // Very dark
      Color(0xFF2D2D2D), // Dark gray
      Color(0xFF1A1A1A), // Almost black
    ],
  );

  // Premium gradients
  static const LinearGradient premiumButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF8C42), // Orange
      Color(0xFFFF6B35), // Deeper orange
    ],
  );

  static const LinearGradient goldenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD700), // Gold
      Color(0xFFFFA500), // Orange
    ],
  );

  static const LinearGradient rainbowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF0000), // Red
      Color(0xFFFFFF00), // Yellow
      Color(0xFF00FF00), // Green
      Color(0xFF0000FF), // Blue
      Color(0xFF9933FF), // Purple
    ],
  );

  // Status colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFFA500);
  static const Color errorRed = Color(0xFFE63946);
  static const Color infoBlue = Color(0xFF2196F3);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF); // White
  static const Color textSecondary = Color(0xFFCCCCCC); // Light gray
  static const Color textDark = Color(0xFF1A1A1A); // Dark
  static const Color textAccent = Color(0xFFFF6B35); // Orange

  // Glow and effects
  static const Color glowOrange = Color(0xFFFF6B35);
  static const Color glowYellow = Color(0xFFFFD700);
  static const Color glowGreen = Color(0xFF4CAF50);
  static const Color glowPurple = Color(0xFF9933FF);

  // Overlay colors
  static Color overlayLight = Colors.white.withOpacity(0.1);
  static Color overlayDark = Colors.black.withOpacity(0.3);
  static Color overlayBlur = Colors.black.withOpacity(0.5);
}
