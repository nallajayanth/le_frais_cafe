# ✅ Getting Started Checklist

## Pre-Implementation

- [ ] Read `QUICK_REFERENCE.md` (5 min)
- [ ] Review `INTEGRATION_GUIDE.md` (10 min)
- [ ] Check device/emulator ready for testing
- [ ] Backup current code (recommended)

---

## Installation

- [ ] Run `flutter pub get` in terminal
- [ ] Run `flutter clean`
- [ ] Run `flutter pub get` again
- [ ] Wait for dependencies to install (~2-5 min)

**Verify**: No red errors in console

---

## Simple Integration (5 minutes)

### Step 1: Open order_tracker_screen.dart
- [ ] File located at: `lib/screens/order/order_tracker_screen.dart`

### Step 2: Add Import
```dart
import 'package:le_frais_mobile_application/game/game_integration.dart';
```
- [ ] Add at top with other imports

### Step 3: Add Game Button
In the `build()` method, inside the `Column` of widgets, add:

```dart
if (_shouldShowGameButton())
  GamePlayButton(
    onGameClosed: () {
      // Handle game closed
    },
    onCoinsEarned: (coins) {
      // Update coins: context.read<UserProvider>().addCoins(coins);
    },
  ),
```

- [ ] Added between order status and delivery info sections
- [ ] Inside the Column children list

### Step 4: Add Helper Methods
Add these methods to the `_OrderTrackerScreenState` class:

```dart
bool _shouldShowGameButton() {
  final order = context.read<OrderProvider>().currentOrder;
  if (order == null) return false;
  
  final status = order.status.toUpperCase();
  return status == 'PREPARING' || 
         status == 'CONFIRMED' || 
         status == 'READY' ||
         status == 'OUT_FOR_DELIVERY';
}

void _onGameCoinsEarned(int coins) {
  // Update coins in your provider
  // Example: context.read<UserProvider>().addCoins(coins);
}
```

- [ ] Added to _OrderTrackerScreenState class

---

## Testing

### Build & Run
- [ ] Run `flutter run`
- [ ] Wait for app to build (~30-60 seconds)
- [ ] App launches successfully
- [ ] No red error messages

### Visual Test
- [ ] Navigate to order tracking screen
- [ ] Look for game button (if order is in appropriate status)
- [ ] Button is visible and styled correctly
- [ ] Button is positioned well with other content

### Functional Test
- [ ] Tap game button
- [ ] Game entry screen appears
- [ ] See animated menu and chef mascot
- [ ] See "Play & Win" button
- [ ] See daily chances remaining (should be 2/3 or 3/3)

### Gameplay Test
- [ ] Tap "Start Game" button
- [ ] See countdown (3...2...1...GO!)
- [ ] Game starts and food begins falling
- [ ] Can move tray left/right (tap sides)
- [ ] Score increases when catching food
- [ ] Timer counts down
- [ ] Game ends after ~60 seconds
- [ ] Game over screen shows with results
- [ ] See coins earned displayed

### Persistence Test
- [ ] Close game (tap Home button)
- [ ] Check daily chances: should now be 1/3 (decreased by 1)
- [ ] Play game again
- [ ] Verify coins persist (new coins added to total)

### UI Test
- [ ] Game button styled correctly
- [ ] Colors match restaurant brand
- [ ] Text is readable
- [ ] No overlapping widgets
- [ ] Responsive on different screen sizes

---

## Optional Enhancements

### Add Audio Files
- [ ] Create `assets/game/audio/` directory
- [ ] Download 6 sound effect files (see ASSETS_SETUP.md)
- [ ] Place files in directory:
  - catch_good.wav
  - catch_bad.wav
  - combo.wav
  - special.wav
  - game_over.wav
  - ui_select.wav
- [ ] Run `flutter clean && flutter pub get`
- [ ] Test audio plays during game

### Customize Colors
- [ ] Open `lib/game/config/game_config.dart`
- [ ] Find `ColorPalette` class
- [ ] Update colors to match your brand:
  - primaryOrange
  - accentYellow
  - darkBackground
  - textPrimary

### Adjust Game Settings
- [ ] Open `lib/game/config/game_config.dart`
- [ ] Modify values:
  - `gameDuration` - change to 30, 45, or 90 seconds
  - `playerSpeed` - faster/slower tray movement
  - `spawnRate` - more/fewer food items
  - `comboThreshold` - easier/harder combo activation

---

## Troubleshooting

### If Game Button Doesn't Appear

**Problem**: Button not visible on order tracking screen

**Solutions**:
1. [ ] Verify import statement is correct
2. [ ] Check `_shouldShowGameButton()` logic
3. [ ] Ensure order status matches expected values
4. [ ] Try debug print in method to check if called
5. [ ] Run `flutter clean` and rebuild

### If App Crashes on Launch

**Problem**: Red error message when running

**Solutions**:
1. [ ] Run `flutter pub get` again
2. [ ] Check for typos in import statement
3. [ ] Verify file paths in imports
4. [ ] Check Dart syntax (missing semicolons, brackets)
5. [ ] Look at error message for specific issue

### If Game Won't Start

**Problem**: Enter game, but gameplay screen is blank

**Solutions**:
1. [ ] Check device logs for errors
2. [ ] Verify Flame is initialized
3. [ ] Try on different device/emulator
4. [ ] Check RAM available
5. [ ] Run in release mode: `flutter run --release`

### If Coins Don't Save

**Problem**: Coins earned but don't persist after close

**Solutions**:
1. [ ] Check if `onCoinsEarned` callback is called
2. [ ] Verify coins update in your provider
3. [ ] Check SharedPreferences write permissions
4. [ ] Verify `RewardsService.saveGameResult()` called
5. [ ] Add debug logging to track coin flow

---

## Performance Verification

- [ ] Game runs at smooth 60 FPS (no stuttering)
- [ ] No lag when moving tray
- [ ] Food items fall smoothly
- [ ] No crashes after 1-2 minute gameplay
- [ ] App responsive after game closes
- [ ] Memory returned after game closes

**If not smooth**:
- [ ] Close other apps
- [ ] Test on real device (not emulator)
- [ ] Run in release mode: `flutter run --release`
- [ ] Check device CPU usage

---

## Code Quality Verification

- [ ] No red errors in IDE
- [ ] No yellow warnings (or reviewed)
- [ ] Code follows existing style
- [ ] Imports organized at top
- [ ] Comments where necessary

**Run analysis**:
```bash
flutter analyze
```

---

## Documentation Review

- [ ] Read QUICK_REFERENCE.md
- [ ] Understand game flow (GAME_README.md)
- [ ] Know integration options (INTEGRATION_GUIDE.md)
- [ ] Familiar with architecture (ARCHITECTURE.md)

---

## Deployment Preparation

- [ ] Game tested on Android device
- [ ] Game tested on iOS device (if applicable)
- [ ] Daily chance limit verified
- [ ] Coins persist correctly
- [ ] Game closes without crashes
- [ ] UI looks good on all screen sizes
- [ ] Brand colors match expectations

---

## Final Checklist

### Before Committing

- [ ] All tests pass
- [ ] No debug logging left in code
- [ ] Imports clean and organized
- [ ] No unused variables
- [ ] Code formatted properly
- [ ] Comments clear and helpful

### Before Production Release

- [ ] Full end-to-end testing complete
- [ ] QA approved
- [ ] Performance benchmarks met
- [ ] No outstanding bugs
- [ ] Analytics integration (if planned)
- [ ] Backend reward redemption tested
- [ ] User documentation complete
- [ ] Support team trained

---

## Post-Launch

### Monitor

- [ ] User engagement metrics
- [ ] Crash reports (if any)
- [ ] Game play statistics
- [ ] Reward redemption rates
- [ ] User feedback

### Iterate

- [ ] Adjust difficulty if needed
- [ ] Add more food types
- [ ] Improve animations
- [ ] Seasonal themes
- [ ] Leaderboard integration

---

## Support Contacts

### For Questions:
1. Check QUICK_REFERENCE.md (common issues)
2. Read INTEGRATION_GUIDE.md (integration help)
3. Check GAME_README.md (features overview)
4. Review ARCHITECTURE.md (system design)
5. Look at EXAMPLE_INTEGRATION.dart (code examples)

### For Issues:
- Check Flutter logs: `flutter logs`
- Device logs: `adb logcat` (Android)
- Xcode console (iOS)
- Check internet connectivity
- Verify all dependencies installed

---

## Estimated Timeline

| Task | Time |
|------|------|
| Dependencies install | 5 min |
| Add import | 1 min |
| Add button widget | 2 min |
| Add helper methods | 3 min |
| Build & test | 10 min |
| Audio setup (optional) | 10 min |
| Customization (optional) | 15 min |
| **Total** | **~30-45 min** |

---

## Success Indicators ✅

- ✅ Game button appears on order screen
- ✅ Game starts when button tapped
- ✅ Game plays for ~60 seconds
- ✅ Score updates correctly
- ✅ Game ends and shows results
- ✅ Coins earned and displayed
- ✅ Daily chances decrease by 1
- ✅ No crashes or errors
- ✅ UI looks polished
- ✅ Ready for users!

---

## 🎉 Congratulations!

If you've completed this checklist, your restaurant app now has a **professional, engaging arcade game**!

**Next step**: Launch to production and watch user engagement soar! 🚀

---

**Questions?** Everything is documented in the game module.  
**Issues?** Check the Troubleshooting section above.  
**Ready?** Deploy with confidence! 🎮
