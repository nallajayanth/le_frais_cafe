// Main Game Controller - Orchestrates the game flow
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'components/game_components.dart';
import 'models/game_models.dart';
import 'screens/game_screens.dart';
import 'screens/game_over_screen.dart';
import 'services/audio_manager.dart';
import 'services/haptic_manager.dart';
import 'services/rewards_service.dart';
import 'config/game_config.dart';

enum GamePhase { entry, countdown, playing, paused, gameOver }

class CatchTheFoodGameView extends StatefulWidget {
  final VoidCallback? onGameClosed;
  final Function(GameResult)? onRewardEarned;

  const CatchTheFoodGameView({this.onGameClosed, this.onRewardEarned, Key? key})
    : super(key: key);

  @override
  State<CatchTheFoodGameView> createState() => _CatchTheFoodGameViewState();
}

class _CatchTheFoodGameViewState extends State<CatchTheFoodGameView>
    with WidgetsBindingObserver {
  late GamePhase currentPhase;
  late CatchTheFoodGame gameInstance;
  late AudioManager audioManager;
  late HapticFeedbackManager hapticManager;
  late RewardsService rewardsService;
  int dailyChancesLeft = 5;
  int totalCoins = 0;
  GameResult? lastGameResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    currentPhase = GamePhase.entry;
    audioManager = AudioManager();
    hapticManager = HapticFeedbackManager();
    rewardsService = RewardsService();

    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await audioManager.initialize();
      await hapticManager.initialize();
      await rewardsService.initialize();

      setState(() {
        dailyChancesLeft = rewardsService.getDailyChancesLeft();
        totalCoins = rewardsService.getTotalCoins();
      });
    } catch (e) {
      print('Error initializing services: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    gameInstance.removeFromParent();
    super.dispose();
  }

  void _startGame() async {
    // Check if player has chances left
    final hasChance = await rewardsService.useOneChance();
    if (!hasChance) {
      _showNoChangesDialog();
      return;
    }

    await audioManager.playUISelectSound();
    await hapticManager.mediumFeedback();

    setState(() {
      currentPhase = GamePhase.countdown;
      dailyChancesLeft = rewardsService.getDailyChancesLeft();
    });
  }

  void _countdownComplete() {
    setState(() {
      currentPhase = GamePhase.playing;
    });
  }

  void _handleGameOver(GameResult result) async {
    await audioManager.playGameOverSound();
    await hapticManager.pulseFeedback(count: 3);

    await rewardsService.saveGameResult(result);

    setState(() {
      currentPhase = GamePhase.gameOver;
      lastGameResult = result;
      totalCoins = rewardsService.getTotalCoins();
    });

    widget.onRewardEarned?.call(result);
  }

  void _playAgain() {
    setState(() {
      currentPhase = GamePhase.entry;
      lastGameResult = null;
    });
  }

  void _goHome() {
    widget.onGameClosed?.call();
  }

  void _claimReward() async {
    if (lastGameResult?.reward != null) {
      final success = await rewardsService.redeemReward(
        lastGameResult!.reward!,
      );
      if (success) {
        await hapticManager.pulseFeedback(count: 4);
        _showRewardClaimedDialog();
      }
    }
  }

  void _pauseGame() {
    if (currentPhase == GamePhase.playing) {
      gameInstance.pauseGame();
      setState(() {
        currentPhase = GamePhase.paused;
      });
    }
  }

  void _resumeGame() {
    gameInstance.resumeGame();
    setState(() {
      currentPhase = GamePhase.playing;
    });
  }

  void _showNoChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Chances Left'),
        content: const Text('Come back tomorrow for more chances!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _goHome();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRewardClaimedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Reward Claimed!'),
        content: Text(
          'Your ${lastGameResult?.reward?.description} has been added to your account!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentPhase == GamePhase.playing) {
          _pauseGame();
          return false;
        }
        return true;
      },
      child: Scaffold(body: _buildPhaseWidget()),
    );
  }

  Widget _buildPhaseWidget() {
    switch (currentPhase) {
      case GamePhase.entry:
        return GameEntryScreen(
          onStartGame: _startGame,
          dailyChancesLeft: dailyChancesLeft,
          totalCoins: totalCoins,
        );

      case GamePhase.countdown:
        return CountdownScreen(onCountdownComplete: _countdownComplete);

      case GamePhase.playing:
        return _buildGameplayScreen();

      case GamePhase.paused:
        return Stack(
          children: [
            _buildGameplayScreen(),
            PauseOverlay(onResume: _resumeGame, onHome: _goHome),
          ],
        );

      case GamePhase.gameOver:
        return GameOverScreen(
          gameResult: lastGameResult!,
          onPlayAgain: _playAgain,
          onHome: _goHome,
          onClaimReward: _claimReward,
        );
    }
  }

  Widget _buildGameplayScreen() {
    return Stack(
      children: [
        // Game canvas
        GestureDetector(
          // Detect all pan movements
          onPanUpdate: (details) {
            if (currentPhase == GamePhase.playing) {
              // Simple delta-based movement - just move by the drag amount
              gameInstance.movePlayerByDelta(details.delta.dx);
            }
          },
          behavior: HitTestBehavior.opaque,
          child: GameWidget(
            game: gameInstance = CatchTheFoodGame(
              onGameComplete: _handleGameOver,
            ),
          ),
        ),
        // HUD overlay
        Positioned.fill(
          child: IgnorePointer(
            child: GameHUD(
              gameState: gameInstance.gameState,
              onPause: _pauseGame,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (currentPhase == GamePhase.playing) {
        _pauseGame();
      }
    }
  }
}
