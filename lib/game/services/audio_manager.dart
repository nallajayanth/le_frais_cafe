// Audio/Sound Manager Service
import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();

  factory AudioManager() {
    return _instance;
  }

  AudioManager._internal();

  bool soundEnabled = true;
  double soundVolume = 0.8;

  // Initialize audio
  Future<void> initialize() async {
    try {
      await FlameAudio.audioCache.loadAll([
        'catch_good.wav',
        'catch_bad.wav',
        'combo.wav',
        'special.wav',
        'game_over.wav',
        'ui_select.wav',
      ]);
    } catch (e) {
      print('Error loading audio: $e');
    }
  }

  // Play sound effects
  Future<void> playCatchGoodSound() async {
    if (soundEnabled) {
      try {
        await FlameAudio.play('catch_good.wav', volume: soundVolume);
      } catch (e) {
        print('Error playing catch_good sound: $e');
      }
    }
  }

  Future<void> playCatchBadSound() async {
    if (soundEnabled) {
      try {
        await FlameAudio.play('catch_bad.wav', volume: soundVolume * 0.7);
      } catch (e) {
        print('Error playing catch_bad sound: $e');
      }
    }
  }

  Future<void> playComboSound() async {
    if (soundEnabled) {
      try {
        await FlameAudio.play('combo.wav', volume: soundVolume);
      } catch (e) {
        print('Error playing combo sound: $e');
      }
    }
  }

  Future<void> playSpecialItemSound() async {
    if (soundEnabled) {
      try {
        await FlameAudio.play('special.wav', volume: soundVolume);
      } catch (e) {
        print('Error playing special sound: $e');
      }
    }
  }

  Future<void> playGameOverSound() async {
    if (soundEnabled) {
      try {
        await FlameAudio.play('game_over.wav', volume: soundVolume * 0.8);
      } catch (e) {
        print('Error playing game_over sound: $e');
      }
    }
  }

  Future<void> playUISelectSound() async {
    if (soundEnabled) {
      try {
        await FlameAudio.play('ui_select.wav', volume: soundVolume * 0.6);
      } catch (e) {
        print('Error playing ui_select sound: $e');
      }
    }
  }

  // Control sound
  void toggleSound() {
    soundEnabled = !soundEnabled;
  }

  void setVolume(double volume) {
    soundVolume = volume.clamp(0.0, 1.0);
  }
}
