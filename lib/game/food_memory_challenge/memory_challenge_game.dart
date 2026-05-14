import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/controllers/game_controller.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/screens/home_screen.dart';

/// Main game entry point with provider setup
class FoodMemoryChallengeApp extends StatelessWidget {
  const FoodMemoryChallengeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameController()..initialize(),
      child: MaterialApp(
        title: 'Food Memory Challenge',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          primaryColor: const Color(0xFFFF6B35),
          scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        ),
        home: const FoodMemoryChallengeHomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
