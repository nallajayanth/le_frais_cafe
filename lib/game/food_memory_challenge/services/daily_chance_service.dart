import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// Service to manage daily game chances
class DailyChanceService {
  static final DailyChanceService _instance = DailyChanceService._internal();
  late SharedPreferences _prefs;

  factory DailyChanceService() {
    return _instance;
  }

  DailyChanceService._internal();

  /// Initialize service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get remaining daily chances
  Future<int> getRemainingChances() async {
    return -1;
  }

  /// Use one daily chance
  Future<bool> useChance() async {
    return true;
  }

  /// Get next reset time (next midnight UTC)
  DateTime getNextResetTime() {
    final now = DateTime.now().toUtc();
    final tomorrow = now.add(const Duration(days: 1));
    return DateTime.utc(tomorrow.year, tomorrow.month, tomorrow.day);
  }

  /// Get time until next reset
  Duration getTimeUntilReset() {
    final now = DateTime.now().toUtc();
    final nextReset = getNextResetTime();
    return nextReset.difference(now);
  }

  /// Reset daily chances (for testing)
  Future<void> resetDaily() async {
    await _prefs.setInt('daily_chances_remaining', 3);
    await _prefs.setString(
      'daily_chances_last_reset',
      DateTime.now().toUtc().toString().split(' ')[0],
    );
  }
}
