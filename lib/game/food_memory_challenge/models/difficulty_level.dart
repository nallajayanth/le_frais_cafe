/// Difficulty level for the game
enum DifficultyLevel {
  easy(1, 'Easy', 4, 60),
  medium(2, 'Medium', 8, 45),
  hard(3, 'Hard', 12, 30);

  final int level;
  final String name;
  final int pairs;
  final int timeSeconds;

  const DifficultyLevel(this.level, this.name, this.pairs, this.timeSeconds);

  /// Get coins reward for completing this difficulty
  int getCompletionCoins() {
    return switch (this) {
      DifficultyLevel.easy => 10,
      DifficultyLevel.medium => 25,
      DifficultyLevel.hard => 50,
    };
  }

  /// Check if next difficulty is unlocked
  bool isNextDifficultyUnlocked(int completedLevel) {
    return completedLevel >= level;
  }
}
