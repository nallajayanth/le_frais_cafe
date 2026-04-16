import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../order/order_preference_screen.dart';
import '../menu/menu_screen.dart';
import '../order/order_history_screen.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int activeIndex;

  const CustomBottomNavBar({
    super.key,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    const Color darkGreen = Color(0xFF1E3D2A);
    const Color inactiveColor = Color(0xFFB0AEAA);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navItem(
              context,
              index: 0,
              activeIndex: activeIndex,
              icon: Icons.home_outlined,
              label: 'HOME',
              onTap: () {
                if (activeIndex == 0) return;
                Navigator.of(context).popUntil((r) => r.isFirst || r.settings.name == '/home');
              },
            ),
            _navItem(
              context,
              index: 1,
              activeIndex: activeIndex,
              icon: Icons.restaurant_menu_rounded,
              label: 'MENU',
              onTap: () {
                if (activeIndex == 1) return;
                Navigator.of(context).popUntil((r) => r.isFirst || r.settings.name == '/home');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MenuScreen(),
                    settings: const RouteSettings(name: '/menu'),
                  ),
                );
              },
            ),
            _navItem(
              context,
              index: 2,
              activeIndex: activeIndex,
              icon: Icons.receipt_long_outlined,
              label: 'ORDERS',
              onTap: () {
                if (activeIndex == 2) return;
                Navigator.of(context).popUntil((r) => r.isFirst || r.settings.name == '/home');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const OrderHistoryScreen(),
                    settings: const RouteSettings(name: '/orders'),
                  ),
                );
              },
            ),
            _navItem(
              context,
              index: 3,
              activeIndex: activeIndex,
              icon: Icons.shopping_cart_outlined,
              label: 'CART',
              showBadge: true,
              badgeCount: cart.totalItems,
              onTap: () {
                if (activeIndex == 3) return;
                Navigator.of(context).popUntil((r) => r.isFirst || r.settings.name == '/home');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CartScreen(),
                    settings: const RouteSettings(name: '/cart'),
                  ),
                );
              },
            ),
            _navItem(
              context,
              index: 4,
              activeIndex: activeIndex,
              icon: Icons.person_outline_rounded,
              label: 'PROFILE',
              onTap: () {
                if (activeIndex == 4) return;
                Navigator.of(context).popUntil((r) => r.isFirst || r.settings.name == '/home');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                    settings: const RouteSettings(name: '/profile'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required int index,
    required int activeIndex,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool showBadge = false,
    int badgeCount = 0,
  }) {
    final bool isActive = index == activeIndex;
    final Color color = isActive ? const Color(0xFF1E3D2A) : const Color(0xFFB0AEAA);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 24),
                if (showBadge && badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFB94040),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                color: color,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
