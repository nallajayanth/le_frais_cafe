import 'package:flutter/material.dart';

/// Represents a single card in the game
class CardModel {
  final String id;
  final String foodEmoji;
  final String foodName;
  bool isFlipped;
  bool isMatched;
  bool isGoldenCard; // Rare special card
  bool isRainbowCard; // Very rare special card

  CardModel({
    required this.id,
    required this.foodEmoji,
    required this.foodName,
    this.isFlipped = false,
    this.isMatched = false,
    this.isGoldenCard = false,
    this.isRainbowCard = false,
  });

  /// Create a copy with modified fields
  CardModel copyWith({
    String? id,
    String? foodEmoji,
    String? foodName,
    bool? isFlipped,
    bool? isMatched,
    bool? isGoldenCard,
    bool? isRainbowCard,
  }) {
    return CardModel(
      id: id ?? this.id,
      foodEmoji: foodEmoji ?? this.foodEmoji,
      foodName: foodName ?? this.foodName,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
      isGoldenCard: isGoldenCard ?? this.isGoldenCard,
      isRainbowCard: isRainbowCard ?? this.isRainbowCard,
    );
  }

  /// Check if this card matches another
  bool matches(CardModel other) {
    return foodEmoji == other.foodEmoji && id != other.id;
  }

  /// Get glow color based on card type
  Color getGlowColor() {
    if (isRainbowCard) return const Color(0xFF9933FF);
    if (isGoldenCard) return const Color(0xFFFFD700);
    return const Color(0xFFFF6B35);
  }
}
