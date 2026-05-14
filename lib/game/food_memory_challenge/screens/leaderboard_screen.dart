import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/controllers/game_controller.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/models/player_stats.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/utils/color_palette.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/utils/helpers.dart';

/// Leaderboard screen showing player stats
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: ColorPalette.gameBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFFF6B35).withOpacity(0.5),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      '🏆 Statistics',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Stats content
              Expanded(
                child: FutureBuilder<PlayerStats>(
                  future: context.read<GameController>().getPlayerStats(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFFF6B35),
                          ),
                        ),
                      );
                    }

                    final stats = snapshot.data!;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Main stats cards
                          _buildStatCard(
                            icon: '🎮',
                            title: 'Games Played',
                            value: stats.totalGamesPlayed.toString(),
                            color: const Color(0xFF2196F3),
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            icon: '🏆',
                            title: 'Games Won',
                            value: stats.totalGamesWon.toString(),
                            color: const Color(0xFFFFD700),
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            icon: '🪙',
                            title: 'Total Coins',
                            value: stats.totalCoinsEarned.toString(),
                            color: const Color(0xFFFFA500),
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            icon: '⏱️',
                            title: 'Best Time',
                            value: GameHelpers.formatTime(
                              stats.bestTimeInSeconds,
                            ),
                            color: const Color(0xFF4CAF50),
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            icon: '🔥',
                            title: 'Current Streak',
                            value: stats.currentStreak.toString(),
                            color: const Color(0xFFE63946),
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            icon: '🎯',
                            title: 'Win Rate',
                            value: '${stats.getWinRate().toStringAsFixed(1)}%',
                            color: const Color(0xFF9933FF),
                          ),

                          const SizedBox(height: 30),

                          // Difficulty high scores
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFF6B35).withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'High Scores by Difficulty',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildHighScoreRow(
                                  'Easy',
                                  stats.getHighScoreForDifficulty(1),
                                ),
                                const SizedBox(height: 8),
                                _buildHighScoreRow(
                                  'Medium',
                                  stats.getHighScoreForDifficulty(2),
                                ),
                                const SizedBox(height: 8),
                                _buildHighScoreRow(
                                  'Hard',
                                  stats.getHighScoreForDifficulty(3),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Special achievements
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFF6B35).withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Special Finds',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildAchievementRow(
                                  '✨ Golden Cards',
                                  stats.goldenCardsFound,
                                ),
                                const SizedBox(height: 8),
                                _buildAchievementRow(
                                  '🌈 Rainbow Cards',
                                  stats.rainbowCardsFound,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideX(
      begin: -0.12,
      end: 0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  Widget _buildHighScoreRow(String difficulty, int score) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          difficulty,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            score.toString(),
            style: const TextStyle(
              color: Color(0xFFFF6B35),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementRow(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
