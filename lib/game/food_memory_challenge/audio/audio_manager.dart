import 'package:audioplayers/audioplayers.dart';

/// Sound constants for the game
class SoundConstants {
  // Asset paths
  static const String cardFlipSound = 'game/audio/card_flip.mp3';
  static const String matchSound = 'game/audio/match.mp3';
  static const String wrongMatchSound = 'game/audio/wrong_match.mp3';
  static const String comboSound = 'game/audio/combo.mp3';
  static const String goldenCardSound = 'game/audio/golden_card.mp3';
  static const String rainbowCardSound = 'game/audio/rainbow_card.mp3';
  static const String victorySound = 'game/audio/victory.mp3';
  static const String gameOverSound = 'game/audio/game_over.mp3';
  static const String tickingSound = 'game/audio/ticking.mp3';
  static const String rewardSound = 'game/audio/reward.mp3';
  static const String backgroundMusic = 'game/audio/background.mp3';
  static const String buttonClickSound = 'game/audio/button_click.mp3';
}

/// Audio manager for the game
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();

  late final AudioPlayer _musicPlayer;
  late final AudioPlayer _sfxPlayer;

  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;

  factory AudioManager() {
    return _instance;
  }

  AudioManager._internal() {
    _musicPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
  }

  /// Initialize audio manager
  Future<void> initialize() async {
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
  }

  /// Play background music
  Future<void> playBackgroundMusic() async {
    if (!_isMusicEnabled) return;
    try {
      await _musicPlayer.play(AssetSource(SoundConstants.backgroundMusic));
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  /// Stop background music
  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
  }

  /// Play card flip sound
  Future<void> playCardFlip() async {
    if (!_isSfxEnabled) return;
    await _playSfx(SoundConstants.cardFlipSound);
  }

  /// Play match success sound
  Future<void> playMatch() async {
    if (!_isSfxEnabled) return;
    await _playSfx(SoundConstants.matchSound);
  }

  /// Play wrong match sound
  Future<void> playWrongMatch() async {
    if (!_isSfxEnabled) return;
    await _playSfx(SoundConstants.wrongMatchSound);
  }

  /// Play combo sound
  Future<void> playCombo() async {
    if (!_isSfxEnabled) return;
    await _playSfx(SoundConstants.comboSound);
  }

  /// Play golden card sound
  Future<void> playGoldenCard() async {
    if (!_isSfxEnabled) return;
    await _playSfx(SoundConstants.goldenCardSound);
  }

  /// Play rainbow card sound
  Future<void> playRainbowCard() async {
    if (!_isSfxEnabled) return;
    await _playSfx(SoundConstants.rainbowCardSound);
  }

  /// Play victory sound
  Future<void> playVictory() async {
    if (!_isSfxEnabled) return;
    await _playSfx(SoundConstants.victorySound);
  }

  /// Play game over sound
  Future<void> playGameOver() async {
    if (!_isSfxEnabled) return;
    await _playSfx(SoundConstants.gameOverSound);
  }

  /// Play reward sound
  Future<void> playReward() async {
    if (!_isSfxEnabled) return;
    await _playSfx(SoundConstants.rewardSound);
  }

  /// Play button click sound
  Future<void> playButtonClick() async {
    if (!_isSfxEnabled) return;
    await _playSfx(SoundConstants.buttonClickSound);
  }

  /// Internal method to play SFX
  Future<void> _playSfx(String sound) async {
    try {
      await _sfxPlayer.play(AssetSource(sound));
    } catch (e) {
      print('Error playing SFX: $e');
    }
  }

  /// Toggle music
  void toggleMusic(bool enabled) {
    _isMusicEnabled = enabled;
    if (!enabled) {
      _musicPlayer.pause();
    } else {
      _musicPlayer.resume();
    }
  }

  /// Toggle SFX
  void toggleSfx(bool enabled) {
    _isSfxEnabled = enabled;
  }

  /// Set music volume (0.0 - 1.0)
  Future<void> setMusicVolume(double volume) async {
    await _musicPlayer.setVolume(volume);
  }

  /// Set SFX volume (0.0 - 1.0)
  Future<void> setSfxVolume(double volume) async {
    await _sfxPlayer.setVolume(volume);
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}
