# Food Memory Challenge - Production-Quality Flutter Game

A premium restaurant-branded memory matching game built with Flutter. Part of the Le Frais restaurant mobile application ecosystem.

## 🎮 Game Features

### Core Gameplay
- **Memory Matching**: Match pairs of food items as quickly as possible
- **3 Difficulty Modes**:
  - Easy: 4 pairs, 60 seconds
  - Medium: 8 pairs, 45 seconds  
  - Hard: 12 pairs, 30 seconds

### Premium Visual Experience
- Smooth 3D card flip animations
- Glowing effects and particle systems
- Animated backgrounds with floating elements
- Glassmorphism UI design
- Restaurant-themed color palette (orange, yellow, cream, black)
- Real-time combo display
- Special card effects (Golden, Rainbow)

### Game Systems
- **Combo System**: Match cards in sequence to trigger combo multipliers (2x/3x)
- **Special Cards**: 
  - Golden Cards: 10% chance, +50 bonus coins
  - Rainbow Cards: 2% chance, +100 bonus coins
- **Timer System**: Countdown with visual pressure as time runs out
- **Scoring System**: Base points + time bonuses + combo multipliers
- **Reward System**: Earn coins that unlock restaurant coupons and discounts

### Audio & Haptics
- Card flip sounds
- Match success sounds
- Combo activation effects
- Victory/Game Over sounds
- Haptic feedback for interactions
- Optional background music

### Progression & Persistence
- Daily chances system (3 games/day)
- Local player statistics tracking
- Difficulty unlock progression
- High score tracking per difficulty
- Reward history

## 📁 Project Structure

```
lib/game/food_memory_challenge/
├── models/
│   ├── card_model.dart
│   ├── game_state.dart
│   ├── difficulty_level.dart
│   ├── player_stats.dart
│   └── reward_data.dart
├── screens/
│   ├── home_screen.dart
│   ├── gameplay_screen.dart
│   └── (additional screens)
├── widgets/
│   ├── animated_card.dart
│   ├── premium_button.dart
│   ├── combo_display.dart
│   └── (additional widgets)
├── animations/
│   ├── card_flip_animation.dart
│   └── (additional animations)
├── audio/
│   ├── audio_manager.dart
│   └── sound_constants.dart
├── services/
│   ├── game_service.dart
│   ├── game_progress_service.dart
│   ├── reward_service.dart
│   └── daily_chance_service.dart
├── controllers/
│   └── game_controller.dart
├── utils/
│   ├── game_constants.dart
│   ├── color_palette.dart
│   ├── food_items.dart
│   └── helpers.dart
├── effects/
│   ├── particle_system.dart
│   └── glow_effect.dart
├── index.dart
└── memory_challenge_game.dart
```

## 🚀 Quick Start

### 1. Add to Pubspec

The following dependencies are already configured:
```yaml
dependencies:
  flutter_animate: ^4.5.0
  flip_card: ^0.7.0
  lottie: ^2.7.0
  confetti: ^0.7.0
  haptic_feedback: ^0.6.4+3
  audioplayers: ^6.1.0
  rive: ^0.13.7
  shared_preferences: ^2.5.5
  provider: ^6.1.5+1
```

### 2. Setup Audio Assets

Create the following audio files in `assets/game/audio/`:
```
assets/game/audio/
├── card_flip.mp3
├── match.mp3
├── wrong_match.mp3
├── combo.mp3
├── golden_card.mp3
├── rainbow_card.mp3
├── victory.mp3
├── game_over.mp3
├── ticking.mp3
├── reward.mp3
├── button_click.mp3
└── background.mp3
```

### 3. Launch the Game

```dart
import 'package:le_frais_mobile_application/game/food_memory_challenge/memory_challenge_game.dart';

// In your main.dart or navigation
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const FoodMemoryChallengeApp()),
);
```

## 🎯 Core Classes

### GameController
Central controller managing all game state and user interactions.
```dart
final controller = context.read<GameController>();
await controller.startGame(DifficultyLevel.easy);
await controller.tapCard('card_0');
```

### GameService
Core game logic: card shuffling, matching, combo detection.

### GameProgressService
Persists player statistics and progression using SharedPreferences.

### RewardService
Manages coin economy and reward tracking.

### AudioManager
Handles all sound effects and background music.

## 🎨 Customization

### Colors
Modify `utils/color_palette.dart`:
```dart
static const Color primaryOrange = Color(0xFFFF6B35);
static const Color accentYellow = Color(0xFFFFA500);
```

### Game Constants
Adjust game parameters in `utils/game_constants.dart`:
- Card flip duration
- Timer values
- Coin rewards
- Special card probabilities

### Food Items
Add/modify items in `utils/food_items.dart`:
```dart
FoodItem(
  emoji: '🍕',
  name: 'Pizza',
  description: 'Delicious pizza',
)
```

## 📊 Game Statistics Tracking

The game automatically tracks:
- Total games played
- Games won
- Total coins earned
- High scores per difficulty
- Best completion time
- Current win streak
- Total matches made
- Special cards found

Access player stats:
```dart
final stats = await gameProgressService.getPlayerStats();
print('Win rate: ${stats.getWinRate()}%');
```

## 🎁 Reward System

Available rewards:
- 🍟 Free Fries (50 coins)
- 🥤 Free Drink (40 coins)
- 💰 10% Discount (60 coins)
- 💰 20% Discount (100 coins)
- 🍕 Free Pizza (150 coins)
- 🍔 Combo Meal (200 coins)

## 🔄 Daily Chances

Players get 3 daily chances to play the game. The counter resets at midnight UTC.

```dart
final remaining = await dailyChanceService.getRemainingChances();
final used = await dailyChanceService.useChance();
```

## ⚡ Performance Optimization

- Cards use efficient AnimationController-based flips
- Particle effects are capped at 200 active particles
- Images are pre-optimized
- Unnecessary rebuilds minimized with Consumer widgets
- Audio files are small MP3s

## 🚀 Future Enhancements

Planned features:
- Multiplayer mode
- Online leaderboard integration
- Seasonal themes
- QR table play mode
- Streak rewards
- Achievements system
- Live restaurant events
- Theme customization

## 📱 Platform Support

- ✅ Android (API 21+)
- ✅ iOS (13+)
- ✅ Web
- ✅ Linux/macOS (with audio limitations)

## 🐛 Troubleshooting

### Audio not playing
- Ensure audio files exist in `assets/game/audio/`
- Check audio permissions on device
- On web, ensure browser allows audio

### Cards not flipping smoothly
- Reduce ParticleSystem maxParticles
- Disable unnecessary animations
- Check device performance

### Game state not persisting
- Ensure SharedPreferences is initialized
- Check file system permissions
- Clear app cache if needed

## 📚 API Reference

### Starting a Game
```dart
controller.startGame(DifficultyLevel.medium);
```

### Tapping a Card
```dart
controller.tapCard('card_id');
```

### Getting Player Coins
```dart
final coins = await controller.getPlayerCoins();
```

### Saving Game Result
```dart
await controller.saveGameResult();
```

## 📄 License

Part of Le Frais restaurant application.

## 👨‍💻 Developer Notes

- All animations use Flutter's built-in APIs and flutter_animate package
- State management uses Provider pattern
- Game logic is separated from UI
- Audio manager follows singleton pattern
- All user data is stored locally with SharedPreferences

---

**Built for Premium Mobile Gaming Experience** 🎮✨
