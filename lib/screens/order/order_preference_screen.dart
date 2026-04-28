import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../dine_in/dine_in_screen.dart';
import '../pickup/pickup_screen.dart';
import '../delivery/delivery_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_entry.dart';
import '../profile/profile_screen.dart';
import '../cart/cart_screen.dart';

class OrderPreferenceScreen extends StatefulWidget {
  const OrderPreferenceScreen({super.key});

  @override
  State<OrderPreferenceScreen> createState() => _OrderPreferenceScreenState();
}

class _OrderPreferenceScreenState extends State<OrderPreferenceScreen>
    with TickerProviderStateMixin {
  OrderMode _selectedPreference = OrderMode.dineIn;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  static const List<_OrderOption> _options = [
    _OrderOption(
      mode: OrderMode.dineIn,
      icon: Icons.table_restaurant_rounded,
      emoji: '🍽️',
      title: 'Dine-In',
      subtitle: 'Enjoy at your table',
      detail: 'Scan the QR code on your table to place orders instantly',
      color: Color(0xFF1E5C3A),
      bgColor: Color(0xFFEDF7F0),
    ),
    _OrderOption(
      mode: OrderMode.pickup,
      icon: Icons.shopping_bag_outlined,
      emoji: '🛍️',
      title: 'Pickup',
      subtitle: 'Order ahead, collect fast',
      detail: 'Place your order now, walk in and pick up when ready',
      color: Color(0xFF8B5A10),
      bgColor: Color(0xFFFDF3E5),
    ),
    _OrderOption(
      mode: OrderMode.delivery,
      icon: Icons.delivery_dining_rounded,
      emoji: '🛵',
      title: 'Delivery',
      subtitle: 'Right to your door',
      detail: 'Fresh from our kitchen delivered straight to you',
      color: Color(0xFF4A2C8A),
      bgColor: Color(0xFFF0EDFA),
    ),
  ];

  Widget _buildOptionCard(_OrderOption option) {
    final bool isSelected = _selectedPreference == option.mode;

    return GestureDetector(
      onTap: () => setState(() => _selectedPreference = option.mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? option.color : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? option.color : const Color(0xFFEAE8E2),
            width: isSelected ? 0 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: option.color.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: -4,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : option.bgColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(option.emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Georgia',
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1C1A17),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    option.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.8)
                          : option.color,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    option.detail,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.65)
                          : const Color(0xFF9A9690),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Check / arrow
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : const Color(0xFFF0EFEB),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected
                    ? Icons.check_rounded
                    : Icons.arrow_forward_ios_rounded,
                color: isSelected ? Colors.white : const Color(0xFFB0AEAA),
                size: isSelected ? 16 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.exit_to_app_rounded,
                  color: Color(0xFFB45309),
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Leave Le Frais?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Georgia',
                  color: Color(0xFF14472A),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Are you sure you want to exit the app?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6A6865),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0EC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'Stay',
                            style: TextStyle(
                              color: Color(0xFF3A3835),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDED),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'Exit',
                            style: TextStyle(
                              color: Color(0xFFB94040),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return shouldExit ?? false;
  }

  void _onContinue() {
    final cart = context.read<CartProvider>();
    cart.updateOrderMode(_selectedPreference);

    if (_selectedPreference == OrderMode.pickup) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const PickupScreen(),
          settings: const RouteSettings(name: '/pickup'),
        ),
      );
    } else if (_selectedPreference == OrderMode.dineIn) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const DineInScreen(),
          settings: const RouteSettings(name: '/dine_in'),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const DeliveryScreen(),
          settings: const RouteSettings(name: '/delivery'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final exit = await _onWillPop();
        if (exit && context.mounted) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F2EC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF4F2EC),
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          toolbarHeight: 64,
          title: Image.asset(
            'assets/logo.jpg',
            height: 38,
            fit: BoxFit.contain,
          ),
          actions: [
            if (cart.totalItems > 0)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => CartScreen())),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Color(0xFF14472A),
                          size: 20,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFC88B1A),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${cart.totalItems}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF14472A),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF14472A).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                const SizedBox(height: 4),
                const Text(
                  'Good day! 👋',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8A7D6A),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'How would you\nlike to order?',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Georgia',
                    color: Color(0xFF0F2A1A),
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select your dining preference to continue.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7A7670),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                // Order mode cards
                ..._options.map(_buildOptionCard),

                const SizedBox(height: 20),

                // Hero image banner
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1556910103-1c02745aae4d?q=80&w=1000&auto=format&fit=crop',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              const Color(0xFF071410).withValues(alpha: 0.92),
                            ],
                            stops: const [0.2, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 24,
                        left: 24,
                        right: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFC88B1A,
                                ).withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'THE CRAFT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Baked fresh daily\nin our forest atelier.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Georgia',
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F4225), Color(0xFF1E5C3A)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F4225).withValues(alpha: 0.45),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _onContinue,
              borderRadius: BorderRadius.circular(30),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderOption {
  final OrderMode mode;
  final IconData icon;
  final String emoji;
  final String title;
  final String subtitle;
  final String detail;
  final Color color;
  final Color bgColor;

  const _OrderOption({
    required this.mode,
    required this.icon,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.color,
    required this.bgColor,
  });
}
