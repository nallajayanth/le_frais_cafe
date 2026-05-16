import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/order_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/delivery_provider.dart';
import 'providers/dine_in_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/review_provider.dart';
import 'providers/support_provider.dart';
import 'services/api/api_client.dart';
import 'services/api/menu_service.dart';
import 'services/api/order_service.dart';
import 'services/api/auth_service.dart';
import 'services/api/payment_service.dart';
import 'services/api/delivery_service.dart' show DeliveryAddressService;
import 'services/api/dine_in_service.dart';
import 'services/api/notification_service.dart';
import 'services/api/review_service.dart';
import 'services/api/support_service.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/order/order_preference_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final apiClient = ApiClient();
  await apiClient.initialize();
  final bool isLoggedIn = apiClient.getToken() != null;

  final menuService = MenuService(apiClient: apiClient);
  final orderService = OrderService(apiClient: apiClient);
  final authService = AuthService(apiClient: apiClient);
  final paymentService = PaymentService(apiClient: apiClient);
  final deliveryService = DeliveryAddressService(apiClient: apiClient);
  final dineInService = DineInService(apiClient: apiClient);
  final notificationService = NotificationService(apiClient: apiClient);
  final reviewService = ReviewService(apiClient: apiClient);
  final supportService = SupportService(apiClient: apiClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (_) => MenuProvider(menuService: menuService),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(orderService: orderService),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: authService),
        ),
        ChangeNotifierProvider(
          create: (_) => PaymentProvider(paymentService: paymentService),
        ),
        ChangeNotifierProvider(
          create: (_) => DeliveryProvider(deliveryService: deliveryService),
        ),
        ChangeNotifierProvider(
          create: (_) => DineInProvider(dineInService: dineInService),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              NotificationProvider(notificationService: notificationService),
        ),
        ChangeNotifierProvider(
          create: (_) => ReviewProvider(reviewService: reviewService),
        ),
        ChangeNotifierProvider(
          create: (_) => SupportProvider(supportService: supportService),
        ),
      ],
      child: LeFraisApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class LeFraisApp extends StatelessWidget {
  final bool isLoggedIn;
  const LeFraisApp({super.key, required this.isLoggedIn});

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
      home: isLoggedIn
          ? const OrderPreferenceScreen()
          : const OnboardingScreen(),
    );
  }
}
