# Food Memory Challenge - Integration Guide

This guide explains how to integrate the Food Memory Challenge game into your Le Frais mobile application.

## 🔗 Quick Integration

### Step 1: Add Game to Main Navigation

In your main app routing/navigation file, add:

```dart
import 'package:le_frais_mobile_application/game/food_memory_challenge/memory_challenge_game.dart';

// In your navigation logic:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const FoodMemoryChallengeApp(),
  ),
);
```

### Step 2: Add a Button to Access the Game

```dart
import 'package:le_frais_mobile_application/game/food_memory_challenge/memory_challenge_game.dart';

ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FoodMemoryChallengeApp(),
      ),
    );
  },
  child: const Text('🎮 Play Memory Challenge'),
)
```

### Step 3: Add Game Provider to Main App

If not already using Provider in your main app, add:

```dart
import 'package:provider/provider.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/controllers/game_controller.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameController()..initialize(),
      child: const MyApp(),
    ),
  );
}
```

## 📱 Integration Points

### From Home Screen
```dart
import 'package:le_frais_mobile_application/game/food_memory_challenge/screens/home_screen.dart';

// Navigate to game
onPressed: () => Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const FoodMemoryChallengeHomeScreen(),
  ),
)
```

### From Order Completion Flow
```dart
// After successful order payment
showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: const Text('🎮 Play & Win!'),
    content: const Text('Earn coins by playing our Memory Challenge'),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FoodMemoryChallengeHomeScreen(),
            ),
          );
        },
        child: const Text('Play Now'),
      ),
    ],
  ),
);
```

### From Restaurant Menu
```dart
// Add to app bar or bottom navigation
Chip(
  label: const Text('🎮 Memory Game'),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FoodMemoryChallengeHomeScreen(),
      ),
    );
  },
)
```

## 🎵 Audio Setup

### Create Audio Assets Directory
```
assets/
└── game/
    └── audio/
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

### Audio File Recommendations

- **card_flip.mp3**: Short whoosh sound, ~0.3s
- **match.mp3**: Positive beep/ding, ~0.4s
- **wrong_match.mp3**: Buzz/error sound, ~0.3s
- **combo.mp3**: Uplifting ascending tone, ~0.5s
- **golden_card.mp3**: Magical chime, ~0.6s
- **rainbow_card.mp3**: Celebratory sound, ~1.0s
- **victory.mp3**: Triumphant music, ~2-3s
- **game_over.mp3**: Sad trumpet/sad sound, ~1.5s
- **ticking.mp3**: Clock ticking, ~0.2s
- **reward.mp3**: Coin/collect sound, ~0.4s
- **button_click.mp3**: UI click sound, ~0.2s
- **background.mp3**: Looping game music, ~30-60s

> 💡 Use royalty-free audio from sites like Freesound.org or create custom audio

### Verify Audio in pubspec.yaml
```yaml
flutter:
  assets:
    - assets/onboarding/
    - assets/logo.jpg
    - assets/game/audio/
    - assets/game/animations/
```

## 💾 Data Persistence

The game automatically saves:
- Player statistics (uses SharedPreferences)
- Game progress
- Daily chances
- Coin balance
- Reward history

All data is stored locally in the device's secure storage.

## 🎁 Reward Integration

### Linking to Restaurant System

To integrate rewards with your restaurant system:

```dart
import 'package:le_frais_mobile_application/game/food_memory_challenge/models/reward_data.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/services/reward_service.dart';

// Get player's earned coins
final rewardService = RewardService();
final coins = await rewardService.getCoins();

// Redeem a reward
final success = await rewardService.spendCoins(50);

// Get coupon code for reward
final coupons = await rewardService.getRedeemedCoupons();
for (var coupon in coupons) {
  print('Coupon: $coupon');
}
```

### Custom Rewards

Add custom rewards to `models/reward_data.dart`:

```dart
static const List<AvailableReward> availableRewards = [
  AvailableReward(
    id: 'my_reward',
    title: '🌮 Free Burrito',
    description: 'Get a free burrito',
    coinsCost: 75,
    couponCode: 'FREEBURRITO',
    category: 'free_item',
  ),
  // ... more rewards
];
```

## 🎮 Game Events & Callbacks

### Listen to Game State Changes

```dart
final controller = context.read<GameController>();

// Game state updates
controller.currentGameState?.isVictory;
controller.currentGameState?.score;
controller.currentGameState?.coinsEarned;
```

### Custom Event Handling

```dart
// After game completes
await controller.saveGameResult();

// Get updated stats
final stats = await controller.getPlayerStats();
print('Total wins: ${stats.totalGamesWon}');
print('Total coins: ${stats.totalCoinsEarned}');
```

## 🎨 Customization

### Change Colors

Edit `utils/color_palette.dart`:

```dart
static const Color primaryOrange = Color(0xFFYourColor);
```

### Adjust Game Difficulty

Edit `utils/game_constants.dart`:

```dart
static const int easyTimer = 90; // Increase from 60 to 90 seconds
static const int easyPairs = 6; // Increase pairs
```

### Modify Rewards

Edit `models/reward_data.dart` to change coin costs or add new rewards.

### Change Food Items

Edit `utils/food_items.dart` to add restaurant-specific menu items:

```dart
static const List<FoodItem> items = [
  FoodItem(
    emoji: '🌮',
    name: 'Your Signature Dish',
    description: 'Description',
  ),
  // ...
];
```

## 🧪 Testing

### Test Game State
```dart
// In your test
testWidgets('Game initializes correctly', (tester) async {
  await tester.pumpWidget(const FoodMemoryChallengeApp());
  expect(find.byType(FoodMemoryChallengeHomeScreen), findsOneWidget);
});
```

### Test Player Progression
```dart
// Simulate game completion
final progressService = GameProgressService();
await progressService.recordGameResult(
  isWin: true,
  score: 100,
  coins: 50,
  difficulty: DifficultyLevel.easy,
  timeElapsed: 30,
);
```

### Clear Test Data
```dart
// Reset for testing
final progressService = GameProgressService();
await progressService.clearAllProgress();
```

## 🚀 Performance Tips

1. **Preload Audio** - Audio loads on demand, cached afterward
2. **Lazy Load Screens** - Screens are created when navigated to
3. **Dispose Properly** - GameController handles cleanup
4. **Monitor Memory** - Particle effects are capped at 200

## 🐛 Troubleshooting

### Issue: No Sound
- ✅ Check audio files exist in `assets/game/audio/`
- ✅ Verify pubspec.yaml includes assets
- ✅ Check device volume isn't muted
- ✅ Check Android/iOS audio permissions

### Issue: Cards Not Flipping
- ✅ Verify flutter_animate package is installed
- ✅ Check GPU acceleration enabled
- ✅ Reduce particle count if lagging

### Issue: Game State Not Persisting
- ✅ Ensure SharedPreferences initialized
- ✅ Check file system permissions
- ✅ Try clearing app cache

### Issue: Coins Not Saving
- ✅ Check RewardService.initialize() called
- ✅ Verify SharedPreferences working
- ✅ Check storage space available

## 📊 Analytics Integration

To track game usage, add event tracking:

```dart
// Track game start
trackEvent('game_started', {'difficulty': 'easy'});

// Track game completion
trackEvent('game_completed', {
  'difficulty': 'easy',
  'victory': true,
  'score': 150,
  'coins_earned': 50,
});

// Track reward redemption
trackEvent('reward_redeemed', {
  'reward_id': 'free_fries',
  'coins_spent': 50,
});
```

## 📦 Deployment Checklist

- ✅ Audio files included in build
- ✅ Game constants tuned for your restaurant
- ✅ Rewards configured with your menu
- ✅ Colors match app branding
- ✅ Tested on target devices (Android/iOS)
- ✅ Daily chance system works
- ✅ Coins persist across app restarts
- ✅ Difficulty unlocking works
- ✅ Haptic feedback enabled (if supported)
- ✅ Privacy policy updated for data storage

## 🔐 Security Notes

- Player data stored locally, not on server
- No sensitive information transmitted
- SharedPreferences used (encrypted on iOS, AES on Android)
- Consider backend integration for:
  - Leaderboard
  - Anti-cheating measures
  - Reward validation
  - Analytics

## 📞 Support

For issues or questions:
1. Check README.md in game folder
2. Review relevant screen implementation
3. Check GameController for state management
4. Verify all dependencies installed

---

**Integration complete! Your players can now earn coins by playing!** 🎮🪙
