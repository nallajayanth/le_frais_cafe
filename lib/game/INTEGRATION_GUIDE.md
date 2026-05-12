# 🎮 Integration Guide - Adding Game to Order Tracking Screen

## Quick Start

### Step 1: Import the game module

In your order tracking screen file:

```dart
import 'package:le_frais_mobile_application/game/game_integration.dart';
```

### Step 2: Add the game button

In your order tracking screen widget, add the `GamePlayButton` widget:

```dart
class OrderTrackingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Existing order tracking UI
            _buildOrderStatus(),
            _buildOrderDetails(),
            
            // Add the game button
            GamePlayButton(
              onGameClosed: () {
                // Handle game closed (optional)
                print('Game closed');
              },
              onCoinsEarned: (coins) {
                // Update user's coin balance
                _updateUserCoins(coins);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🎉 Earned $coins coins!'),
                    backgroundColor: Color(0xFFFFEB3B),
                  ),
                );
              },
            ),
            
            // Other widgets
          ],
        ),
      ),
    );
  }

  void _updateUserCoins(int coins) {
    // Update your app state/provider
  }
}
```

## Integration Patterns

### Pattern 1: Full-Page Entry (After Payment)

Show the game full-screen after successful payment:

```dart
void _showGameAfterPayment() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => GameRewardCard(
      orderNumber: orderData.orderNumber,
      onClose: () {
        Navigator.pop(context);
        _showRewardSummary();
      },
    ),
  );
}
```

### Pattern 2: Card Widget in Feed

Add game as a promotional card in the order list:

```dart
ListView(
  children: [
    // Order 1
    OrderCard(order: orders[0]),
    
    // Game card
    GamePreviewCard(
      onTap: () {
        // Launch game full-screen
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: CatchTheFoodGameView(
              onGameClosed: () => Navigator.pop(context),
            ),
          ),
        );
      },
    ),
    
    // More orders
    ...orders.skip(1).map((order) => OrderCard(order: order)),
  ],
)
```

### Pattern 3: Mini Play Button in Status Card

Embed game button directly in order status:

```dart
Container(
  child: Column(
    children: [
      // Order status
      Text('Order #${order.number} - ${order.status}'),
      const SizedBox(height: 12),
      
      // Game button
      GamePlayButton(
        onCoinsEarned: (coins) {
          context.read<UserProvider>().addCoins(coins);
        },
      ),
    ],
  ),
)
```

## Integration with Providers

If using Provider state management:

```dart
class OrderProvider extends ChangeNotifier {
  int userCoins = 0;

  Future<void> playGame() async {
    // Get initial coins
    final initialCoins = userCoins;
    
    // Game returns result
    final result = await _openGame();
    
    if (result != null) {
      userCoins += result.totalCoins;
      
      // Save to backend
      await _saveCoinsToBackend(userCoins);
      notifyListeners();
    }
  }
}
```

## Complete Example: Order Tracking Screen

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:le_frais_mobile_application/game/game_integration.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({
    required this.orderId,
    Key? key,
  }) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late Order order;

  @override
  void initState() {
    super.initState();
    _loadOrderData();
  }

  Future<void> _loadOrderData() async {
    // Load order from provider or API
    order = await context.read<OrderProvider>().getOrder(widget.orderId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.number}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with restaurant info
            _buildRestaurantHeader(),
            
            // Order status timeline
            _buildOrderStatus(),
            
            // Order items
            _buildOrderItems(),
            
            // Estimated time
            _buildEstimatedTime(),
            
            // Game card - Enable during waiting period
            if (order.status == OrderStatus.preparing ||
                order.status == OrderStatus.ready)
              GamePlayButton(
                onGameClosed: () {
                  print('Game session ended');
                },
                onCoinsEarned: (coins) {
                  // Update coins in provider
                  context.read<UserProvider>().addCoins(coins);
                  
                  // Show notification
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '🎉 Earned $coins coins! Use them for discounts.',
                      ),
                      backgroundColor: const Color(0xFFFFEB3B),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
              ),
            
            // Delivery instructions
            _buildDeliveryInstructions(),
            
            // Support button
            _buildSupportButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFF5F5F5),
      child: Row(
        children: [
          // Restaurant logo
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(order.restaurantLogo),
          ),
          const SizedBox(width: 12),
          // Restaurant info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.restaurantName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '📍 ${order.restaurantDistance}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatus() {
    // Implement timeline visualization
    return Container();
  }

  Widget _buildOrderItems() {
    // Implement order items list
    return Container();
  }

  Widget _buildEstimatedTime() {
    // Implement estimated time display
    return Container();
  }

  Widget _buildDeliveryInstructions() {
    // Implement delivery instructions
    return Container();
  }

  Widget _buildSupportButton() {
    // Implement support button
    return Container();
  }
}
```

## Handling Game Results

The `GamePlayButton` provides two callbacks:

### onGameClosed
Called when the player closes the game (Home button in game over):

```dart
onGameClosed: () {
  // Perform cleanup or navigation
  // This is called regardless of performance
  print('Game closed by player');
}
```

### onCoinsEarned
Called when a game session completes with results:

```dart
onCoinsEarned: (coins) {
  // coins = coins earned in that game session
  // Update your app state
  setState(() {
    userCoins += coins;
  });
}
```

## State Management Integration

### With Provider
```dart
// Get coins
int coins = context.watch<UserProvider>().coins;

// Update coins
context.read<UserProvider>().addCoins(earnedCoins);
```

### With Riverpod
```dart
// In your state provider
final userCoinsProvider = StateNotifierProvider<CoinNotifier, int>((ref) {
  return CoinNotifier();
});

// Update coins
ref.read(userCoinsProvider.notifier).addCoins(earnedCoins);
```

### With GetX
```dart
final userController = Get.find<UserController>();
userController.addCoins(earnedCoins);
```

## Location in App Flow

Recommended placement:

1. **During Order Waiting** (✅ Best)
   - When customer is waiting for food
   - On order tracking screen
   - Before estimated time arrives

2. **After Payment** (✅ Good)
   - Immediately after successful payment
   - Full-screen modal
   - Creates positive reinforcement

3. **In Main Menu** (⭐ Discovery)
   - Promotional card in order history
   - Encourages repeat visits
   - After-order engagement

4. **Notification** (Advanced)
   - When customer's order is ready
   - Deep link to game on order tracking
   - Requires push notification integration

## Testing the Integration

```dart
void _testGameIntegration() {
  // Simulate game played
  final testResult = GameResult(
    finalScore: 250,
    totalCoins: 25,
    bestCombo: 7,
    reward: RewardData.rewardTiers[2],
    playedAt: DateTime.now(),
  );
  
  // Call the callback
  onCoinsEarned?.call(testResult.totalCoins);
}
```

## Error Handling

The game module handles errors gracefully:

```dart
try {
  // Initialize game services
  await rewardsService.initialize();
  await audioManager.initialize();
} catch (e) {
  // Game continues without these services
  print('Service initialization error: $e');
}
```

## Performance Considerations

- Game uses Flame engine (optimized)
- Minimal memory footprint (~50-80MB during play)
- Unloads completely when closed
- No memory leaks with proper disposal
- Suitable for low-end devices

## Troubleshooting

### Game doesn't start
1. Check if daily chances are available
2. Verify RewardsService initialized
3. Check logs for errors

### Coins not being added
1. Verify `onCoinsEarned` callback is triggered
2. Check if coin update is persisted
3. Verify provider state update

### No sound
1. Check if audio files exist in `assets/game/audio/`
2. Verify pubspec.yaml includes assets
3. Run `flutter clean && flutter pub get`

### Haptic feedback not working
1. Device may not support vibration
2. Check permission settings
3. Verify `HapticFeedbackManager` initialized

---

**Ready to integrate! 🚀**

For more details, see `GAME_README.md` in the game module.
