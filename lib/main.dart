import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const LeFraisApp());
}

class LeFraisApp extends StatelessWidget {
  const LeFraisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Le Frais',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E5C3A)),
        fontFamily: 'sans-serif',
        useMaterial3: true,
      ),
      home: const OnboardingScreen(),
    );
  }
}
