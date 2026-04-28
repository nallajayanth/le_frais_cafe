import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/order_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/delivery_provider.dart';
import 'services/api/api_client.dart';
import 'services/api/menu_service.dart';
import 'services/api/order_service.dart';
import 'services/api/auth_service.dart';
import 'services/api/payment_service.dart';
import 'services/api/delivery_service.dart' show DeliveryAddressService;
import 'screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  // Initialize API services
  final apiClient = ApiClient();
  final menuService = MenuService(apiClient: apiClient);
  final orderService = OrderService(apiClient: apiClient);
  final authService = AuthService(apiClient: apiClient);
  final paymentService = PaymentService(apiClient: apiClient);
  final deliveryService = DeliveryAddressService(apiClient: apiClient);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider(menuService: menuService)),
        ChangeNotifierProvider(create: (_) => OrderProvider(orderService: orderService)),
        ChangeNotifierProvider(create: (_) => AuthProvider(authService: authService)),
        ChangeNotifierProvider(create: (_) => PaymentProvider(paymentService: paymentService)),
        ChangeNotifierProvider(create: (_) => DeliveryProvider(deliveryService: deliveryService)),
      ],
      child: const LeFraisApp(),
    ),
  );
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
