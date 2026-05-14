/// Player statistics and progress data
class PlayerStats {
  final int totalGamesPlayed;
  final int totalGamesWon;
  final int totalCoinsEarned;
  final int highestScore;
  final int bestTimeInSeconds;
  final int currentStreak;
  final Map<int, int> difficultyHighScores; // difficulty level -> high score
  final Map<int, bool> unlockedDifficulties; // difficulty level -> unlocked
  final int totalMatches;
  final int totalCombos;
  final int goldenCardsFound;
  final int rainbowCardsFound;

  const PlayerStats({
    this.totalGamesPlayed = 0,
    this.totalGamesWon = 0,
    this.totalCoinsEarned = 0,
    this.highestScore = 0,
    this.bestTimeInSeconds = 0,
    this.currentStreak = 0,
    this.difficultyHighScores = const {},
    this.unlockedDifficulties = const {1: true, 2: true, 3: true},
    this.totalMatches = 0,
    this.totalCombos = 0,
    this.goldenCardsFound = 0,
    this.rainbowCardsFound = 0,
  });

  /// Create a copy with modified fields
  PlayerStats copyWith({
    int? totalGamesPlayed,
    int? totalGamesWon,
    int? totalCoinsEarned,
    int? highestScore,
    int? bestTimeInSeconds,
    int? currentStreak,
    Map<int, int>? difficultyHighScores,
    Map<int, bool>? unlockedDifficulties,
    int? totalMatches,
    int? totalCombos,
    int? goldenCardsFound,
    int? rainbowCardsFound,
  }) {
    return PlayerStats(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalGamesWon: totalGamesWon ?? this.totalGamesWon,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      highestScore: highestScore ?? this.highestScore,
      bestTimeInSeconds: bestTimeInSeconds ?? this.bestTimeInSeconds,
      currentStreak: currentStreak ?? this.currentStreak,
      difficultyHighScores: difficultyHighScores ?? this.difficultyHighScores,
      unlockedDifficulties: unlockedDifficulties ?? this.unlockedDifficulties,
      totalMatches: totalMatches ?? this.totalMatches,
      totalCombos: totalCombos ?? this.totalCombos,
      goldenCardsFound: goldenCardsFound ?? this.goldenCardsFound,
      rainbowCardsFound: rainbowCardsFound ?? this.rainbowCardsFound,
    );
  }

  /// Get win rate percentage
  double getWinRate() {
    if (totalGamesPlayed == 0) return 0;
    return (totalGamesWon / totalGamesPlayed) * 100;
  }

  /// Check if difficulty is unlocked
  bool isDifficultyUnlocked(int difficulty) {
    return true;
  }

  /// Get high score for difficulty
  int getHighScoreForDifficulty(int difficulty) {
    return difficultyHighScores[difficulty] ?? 0;
  }
}
