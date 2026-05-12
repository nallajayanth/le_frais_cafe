// Haptic/Vibration Feedback Manager
import 'package:flutter/services.dart';

class HapticFeedbackManager {
  static final HapticFeedbackManager _instance =
      HapticFeedbackManager._internal();

  factory HapticFeedbackManager() {
    return _instance;
  }

  HapticFeedbackManager._internal();

  bool hapticEnabled = true;

  Future<void> initialize() async {
    // haptic_feedback handles device capability detection internally
  }

  // Light vibration - catching regular food
  Future<void> lightFeedback() async {
    if (!hapticEnabled) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      print('Haptic feedback error: $e');
    }
  }

  // Medium vibration - combo activation
  Future<void> mediumFeedback() async {
    if (!hapticEnabled) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      print('Haptic feedback error: $e');
    }
  }

  // Strong vibration - special items
  Future<void> strongFeedback() async {
    if (!hapticEnabled) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      print('Haptic feedback error: $e');
    }
  }

  // Pulse vibration - jackpot/reward (simulated with medium impacts)
  Future<void> pulseFeedback({int count = 3}) async {
    if (!hapticEnabled) return;
    try {
      for (int i = 0; i < count; i++) {
        await HapticFeedback.mediumImpact();
        await Future.delayed(Duration(milliseconds: 100));
      }
    } catch (e) {
      print('Haptic feedback error: $e');
    }
  }

  // Error vibration - bomb/bad item
  Future<void> errorFeedback() async {
    if (!hapticEnabled) return;
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(Duration(milliseconds: 50));
      await HapticFeedback.lightImpact();
    } catch (e) {
      print('Haptic feedback error: $e');
    }
  }

  void toggleHaptic() {
    hapticEnabled = !hapticEnabled;
  }

  Future<void> cancel() async {
    // haptic_feedback doesn't require explicit cancellation
  }
}
