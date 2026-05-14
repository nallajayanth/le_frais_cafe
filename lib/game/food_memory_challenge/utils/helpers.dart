import 'package:flutter/material.dart';

/// Helper utilities for Food Memory Challenge
class GameHelpers {
  /// Format time in seconds to MM:SS format
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Format large numbers with K suffix
  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  /// Calculate bonus multiplier based on time
  static double calculateTimeMultiplier(int timeRemaining, int totalTime) {
    final ratio = timeRemaining / totalTime;
    if (ratio > 0.8) return 2.0; // Very quick
    if (ratio > 0.6) return 1.5; // Quick
    if (ratio > 0.4) return 1.2; // Normal
    return 1.0; // Slow
  }

  /// Get combo color based on combo count
  static Color getComboColor(int comboCount) {
    if (comboCount >= 10) {
      return const Color(0xFF9933FF); // Purple - Ultimate combo
    } else if (comboCount >= 5) {
      return const Color(0xFFFFD700); // Gold - Hot combo
    } else if (comboCount >= 3) {
      return const Color(0xFFFF6B35); // Orange - On fire
    }
    return Colors.white;
  }

  /// Get difficulty description
  static String getDifficultyName(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      default:
        return 'Unknown';
    }
  }

  /// Calculate star rating based on performance
  static int calculateStarRating({
    required int totalTime,
    required int timeTaken,
    required int moves,
    required int totalPairs,
    required int difficulty,
  }) {
    final timeEfficiency = (totalTime - timeTaken) / totalTime;
    final movesEfficiency = moves / (totalPairs * 2);

    double score = 0;

    // Time efficiency scoring
    if (timeEfficiency > 0.7) score += 2;
    else if (timeEfficiency > 0.5) score += 1.5;
    else if (timeEfficiency > 0.3) score += 1;

    // Moves efficiency scoring
    if (movesEfficiency < 1.2) score += 2;
    else if (movesEfficiency < 1.5) score += 1.5;
    else if (movesEfficiency < 2.0) score += 1;

    // Difficulty bonus
    score += (difficulty * 0.5);

    if (score >= 4) return 3; // 3 stars
    if (score >= 2) return 2; // 2 stars
    return 1; // 1 star
  }

  /// Get emoji reaction for score
  static String getReactionEmoji(int stars) {
    switch (stars) {
      case 3:
        return '⭐⭐⭐';
      case 2:
        return '⭐⭐';
      case 1:
        return '⭐';
      default:
        return '🎮';
    }
  }
}
