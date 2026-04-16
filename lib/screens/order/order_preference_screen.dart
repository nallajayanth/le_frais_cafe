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



import '../shared/custom_bottom_nav_bar.dart';

class OrderPreferenceScreen extends StatefulWidget {
  const OrderPreferenceScreen({super.key});

  @override
  State<OrderPreferenceScreen> createState() => _OrderPreferenceScreenState();
}

class _OrderPreferenceScreenState extends State<OrderPreferenceScreen> {
  OrderMode _selectedPreference = OrderMode.dineIn;

  Widget _buildPreferenceCard({
    required String title,
    required String subtitle,
    required OrderMode type,
    required String emoji,
  }) {
    final bool isSelected = _selectedPreference == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPreference = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD6EAE3) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E5C3A) : Colors.transparent,
            width: 1,
          ),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFAFE0CD)
                          : const Color(0xFFEFEEEA),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Georgia',
                      color: isSelected
                          ? const Color(0xFF14472A)
                          : const Color(0xFF1C1A17),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5A5853),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: -8,
                right: -4,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF14472A),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  ),
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
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Leave Le Frais?',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.w800,
            color: Color(0xFF14472A),
          ),
        ),
        content: const Text(
          'Are you sure you want to exit the app?',
          style: TextStyle(color: Color(0xFF5A5853)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Stay',
                style: TextStyle(
                    color: Color(0xFF14472A), fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Exit',
                style: TextStyle(
                    color: Color(0xFFB94040), fontWeight: FontWeight.w700)),
          ),
        ],
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
        backgroundColor: const Color(0xFFF9F9F6),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false, // no back arrow — this is root
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
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => CartScreen()),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFEAE8E4)),
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Color(0xFF14472A),
                          size: 18,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFB94040),
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
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFF14472A),
                    shape: BoxShape.circle,
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How would\nyou like to\norder?',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Georgia',
                  color: Color(0xFF14472A),
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Experience our artisan creations exactly where you want them. Select your dining preference to continue.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF5A5853),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              _buildPreferenceCard(
                title: 'Dine-In',
                subtitle: 'Scan QR to order at table',
                type: OrderMode.dineIn,
                emoji: '🍽️',
              ),
              _buildPreferenceCard(
                title: 'Pickup',
                subtitle: 'Order ahead for quick collection',
                type: OrderMode.pickup,
                emoji: '🛍️',
              ),
              _buildPreferenceCard(
                title: 'Delivery',
                subtitle: 'Get it delivered to your door',
                type: OrderMode.delivery,
                emoji: '🛵',
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://images.unsplash.com/photo-1556910103-1c02745aae4d?q=80&w=1000&auto=format&fit=crop'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFF0F2618).withValues(alpha: 0.9),
                      ],
                      stops: const [0.3, 1.0],
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'THE CRAFT',
                        style: TextStyle(
                          color: Color(0xFF90A391),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Baked fresh daily\nin our forest atelier.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Georgia',
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100, left: 24, right: 24),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5A10),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: const Color(0xFF8B5A10).withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(activeIndex: 0),
      ), // closes Scaffold
    );   // closes PopScope 
  }
}
