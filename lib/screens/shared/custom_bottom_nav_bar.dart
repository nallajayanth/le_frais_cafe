import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F2A1A),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F2A1A).withValues(alpha: 0.45),
                blurRadius: 30,
                offset: const Offset(0, 10),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navItem(
                context,
                index: 0,
                activeIndex: activeIndex,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                onTap: () {
                  if (activeIndex == 0) return;
                  Navigator.of(context).popUntil((r) => r.isFirst || r.settings.name == '/home');
                },
              ),
              _navItem(
                context,
                index: 1,
                activeIndex: activeIndex,
                icon: Icons.restaurant_menu_outlined,
                activeIcon: Icons.restaurant_menu_rounded,
                label: 'Menu',
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
                activeIcon: Icons.receipt_long_rounded,
                label: 'Orders',
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
                icon: Icons.shopping_bag_outlined,
                activeIcon: Icons.shopping_bag_rounded,
                label: 'Cart',
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
                activeIcon: Icons.person_rounded,
                label: 'Profile',
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
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required int index,
    required int activeIndex,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required VoidCallback onTap,
    bool showBadge = false,
    int badgeCount = 0,
  }) {
    final bool isActive = index == activeIndex;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: isActive
            ? const EdgeInsets.symmetric(horizontal: 18, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1E5C3A) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? Colors.white : const Color(0xFF6B8F71),
                  size: 22,
                ),
                if (showBadge && badgeCount > 0)
                  Positioned(
                    right: -7,
                    top: -7,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC88B1A),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF0F2A1A), width: 1.5),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
