# 🎮 Catch The Food - Premium Game Module

A high-quality, production-ready arcade game built with Flutter and Flame for the Le Frais restaurant application.

## 📦 Module Structure

```
lib/game/
├── config/
│   └── game_config.dart          # Game configuration and constants
├── components/
│   └── game_components.dart      # Flame game components (Food, Player, Game class)
├── models/
│   └── game_models.dart          # Game data models and enums
├── screens/
│   ├── game_screens.dart         # Entry, HUD, countdown screens
│   └── game_over_screen.dart     # Game over and results screen
├── services/
│   ├── audio_manager.dart        # Sound effects management
│   ├── haptic_manager.dart       # Vibration feedback
│   └── rewards_service.dart      # Rewards and persistence
├── catch_the_food_game.dart      # Main game controller
├── game_integration.dart         # Integration widgets for order tracking
└── index.dart                    # Module exports
```

## 🎯 Core Features

### Game Mechanics
- **60-second gameplay** with smooth, responsive controls
- **Food spawning system** with difficulty scaling
- **Combo system** that rewards consecutive catches
- **Collision detection** for catching good items and avoiding bad ones

### Food Items

**Good Items (Catch These)**
- 🍔 Burger (10pts)
- 🍕 Pizza (15pts)
- 🍟 Fries (8pts)
- 🍩 Donut (12pts)
- ☕ Cold Coffee (9pts)
- 🍦 Ice Cream (11pts)

**Bad Items (Avoid)**
- 🍔 Burnt Burger (-20pts)
- 🍅 Rotten Tomato (-15pts)
- 💣 Bomb (-30pts)
- 🌶️ Chili Trap (-25pts)

**Special Rare Items (✨)**
- ✨🍔✨ Golden Burger (50pts) - Slow motion, golden glow
- 🌈🍕🌈 Rainbow Pizza (75pts) - Confetti, rainbow flash

### Game Systems

1. **Score System**
   - Base score per item
   - Combo multiplier (up to 3x)
   - Score increases difficulty

2. **Combo System**
   - Activates at 3 consecutive good catches
   - Visual feedback with glowing text and particles
   - Score multiplier (2-3x)
   - Resets on missing or catching bad items

3. **Reward System**
   - Score-based rewards
   - Daily limit (3 plays per day)
   - Coin economy
   - Persistent storage with SharedPreferences

4. **Difficulty Scaling**
   - Food falls faster as score increases
   - Spawn rate increases
   - More bad items appear
   - Scales smoothly from 1.0x to 3.0x

### UI Components

- **Entry Screen** - Animated menu with daily chances
- **Countdown Screen** - 3...2...1...GO! sequence
- **Game HUD** - Real-time score, timer, combo display
- **Game Over Screen** - Results with confetti and reward display
- **Pause Overlay** - Resume/Home options

### Premium Features

- ✨ **Particle effects** for catches and combos
- 🎵 **Satisfying sound design** with arcade-like audio
- 📳 **Haptic feedback** for catches, combos, and rewards
- 🎨 **Modern UI design** with orange/yellow restaurant branding
- 🎯 **Smooth animations** with FlutterAnimate
- 🎊 **Confetti celebrations** for rewards

## 🚀 Integration with Order Tracking

### Adding to Order Tracking Screen

```dart
import 'package:your_app/game/game_integration.dart';

// In your order tracking screen:
Column(
  children: [
    // ... existing order tracking widgets ...
    GamePlayButton(
      onGameClosed: () {
        // Handle game closed
      },
      onCoinsEarned: (coins) {
        // Update user coins
      },
    ),
  ],
)
```

### Available Integration Widgets

1. **GamePlayButton** - Simple play button for order tracking
   ```dart
   GamePlayButton(
     onGameClosed: () {},
     onCoinsEarned: (coins) {},
   )
   ```

2. **GameCard** - Standalone card widget
   ```dart
   GameCard()
   ```

3. **GameRewardCard** - Full-screen dialog variant
   ```dart
   showDialog(
     context: context,
     builder: (_) => GameRewardCard(
       orderNumber: '12345',
       onClose: () {},
     ),
   )
   ```

4. **GamePreviewCard** - Preview/promotional card
   ```dart
   GamePreviewCard(
     onTap: () { /* Launch game */ },
   )
   ```

## 📊 Rewards System

### Reward Tiers
- **50 pts** → 5 Coins
- **100 pts** → Free Fries
- **150 pts** → 10% Discount
- **200 pts** → Mystery Reward
- **300 pts** → Jackpot Spin

### Daily Limits
- 3 plays per day (resets every 24 hours)
- Tracks plays locally with SharedPreferences
- Integrates with backend for production deployment

## 🎨 Customization

### Colors
Edit `lib/game/config/game_config.dart`:
```dart
class ColorPalette {
  static const int primaryOrange = 0xFFFF9800;
  static const int accentYellow = 0xFFFFEB3B;
  // ... customize colors
}
```

### Game Duration
Change in `GameConfig`:
```dart
static const int gameDuration = 60; // Change to 30 for shorter game
```

### Difficulty Scaling
Adjust in `GameConfig`:
```dart
static const double difficultyIncreaseRate = 0.01; // per second
```

### Food Spawn Rates
Modify in `game_models.dart`:
```dart
FoodType.burger: FoodItemData(
  // ...
  spawnProbability: 0.15, // 15% chance
  // ...
)
```

## 🔊 Sound Effects

Required audio files (place in `assets/game/audio/`):
- `catch_good.wav` - Positive catch feedback
- `catch_bad.wav` - Catching bad item
- `combo.wav` - Combo activation
- `special.wav` - Special item (Golden Burger, Rainbow Pizza)
- `game_over.wav` - Game end sound
- `ui_select.wav` - Button/UI interactions

**Note**: If audio files are not available, the game continues without sound.

## 📳 Haptic Feedback Patterns

- **Light** - Regular food catch
- **Medium** - Combo activation
- **Strong** - Special item catch
- **Pulse** - Rewards/Jackpot
- **Error** - Bad item/Bomb

Can be toggled on/off via `HapticFeedbackManager`.

## 💾 Persistence

The game automatically saves:
- Total coins earned
- Daily chances remaining
- Best score
- Game history (last 10 games)
- Play time statistics
- Redeemed rewards

Access via `RewardsService`:
```dart
final service = RewardsService();
await service.initialize();

int totalCoins = service.getTotalCoins();
int chancesLeft = service.getDailyChancesLeft();
int bestScore = service.getBestScore();
List<GameHistoryEntry> history = service.getGameHistory();
```

## ⚙️ Performance Optimization

- **Object pooling** for food items
- **Efficient collision detection** (AABB)
- **Limited particle count** (max 150)
- **Optimized sprite rendering**
- **Compiled with --release** flag for production

### Target Performance
- 60 FPS on mid-range Android devices
- Smooth gameplay on 1-2GB RAM phones
- Minimal battery drain during idle

## 🧪 Testing the Game

### Quick Integration Test
```dart
import 'package:your_app/game/game_integration.dart';

class TestGamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GamePlayButton(
        onGameClosed: () => Navigator.pop(context),
      ),
    );
  }
}
```

### Manual Testing Checklist
- [ ] Game starts after countdown
- [ ] Score increases when catching good items
- [ ] Score decreases when catching bad items
- [ ] Combo activates after 3 consecutive good catches
- [ ] Daily chance limit works correctly
- [ ] Sound plays (if audio files available)
- [ ] Haptic feedback works
- [ ] Game saves results to persistence
- [ ] Game Over screen displays correctly
- [ ] Reward displays for qualifying scores

## 🔮 Future Enhancements

Ready to extend with:
- 🏆 Leaderboard integration
- 👥 Multiplayer mode
- 🎪 Seasonal themes
- 🎯 Achievements system
- 🌟 Power-ups and boosters
- 📱 QR code play events
- 🎬 Replay system
- 📊 Analytics integration

## 📱 Platform Support

- ✅ Android (API 21+)
- ✅ iOS (12.0+)
- ✅ Web (with canvas support)
- ✅ Desktop (Windows, Mac, Linux)

## 🐛 Debugging

Enable debug logging by modifying game components. The game includes print statements for common operations.

### Known Limitations
- Audio requires actual audio files (gracefully falls back to silent mode)
- Haptic feedback requires device support
- Best performance on 64-bit devices

## 📄 License

Part of Le Frais Restaurant Application.

## 👨‍💻 Developer Notes

### Architecture Principles
- **Separation of concerns**: Game logic, UI, services
- **Reusable components**: All widgets can be used independently
- **Type safety**: Full null safety implementation
- **Resource management**: Proper disposal of controllers and services

### Code Quality
- Clean, well-documented code
- Consistent naming conventions
- Modular and extensible design
- Production-level error handling

---

**Ready to integrate! 🎮🚀**
