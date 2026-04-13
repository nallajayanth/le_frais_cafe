import 'package:flutter/material.dart';
import '../../models/app_cart.dart';
import '../auth/login_screen.dart';
import '../cart/cart_screen.dart';
import '../menu/menu_screen.dart';
import '../order/order_history_screen.dart';

class _ProfileTileData {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool hasNotification;
  final VoidCallback? onTap;

  _ProfileTileData({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.hasNotification = false,
    this.onTap,
  });
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_ProfileTileData> tiles = [
      _ProfileTileData(
        icon: Icons.history_rounded,
        title: 'Order History',
        subtitle: 'View your past artisanal treats',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
          );
        },
      ),
      _ProfileTileData(
        icon: Icons.location_on_outlined,
        title: 'Saved Addresses',
        subtitle: 'Manage delivery destinations',
      ),
      _ProfileTileData(
        icon: Icons.notifications_none_rounded,
        title: 'Notifications',
        subtitle: 'Manage alerts and news',
        hasNotification: true,
      ),
      _ProfileTileData(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Payments',
        subtitle: 'Default methods and billing',
      ),
      _ProfileTileData(
        icon: Icons.help_outline_rounded,
        title: 'Help & Support',
        subtitle: 'FAQs and direct assistance',
      ),
      _ProfileTileData(
        icon: Icons.history_rounded, // Reuses same icon in design
        title: 'Rewards',
        subtitle: 'See Your rewards',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCF9),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navItem(context, Icons.home_outlined, 'HOME', false,
                  onTap: () => Navigator.of(context).popUntil(
                      (r) => r.settings.name == '/home' || r.isFirst)),
              _navItem(context, Icons.restaurant_menu_rounded, 'MENU', false,
                  onTap: () {
                    Navigator.of(context).popUntil(
                        (r) => r.settings.name == '/home' || r.isFirst);
                    Future.microtask(() => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MenuScreen(),
                            settings: const RouteSettings(name: '/menu'),
                          ),
                        ));
                  }),
              _navItem(context, Icons.receipt_long_outlined, 'ORDERS', false,
                  onTap: () {
                    Navigator.of(context).popUntil(
                        (r) => r.settings.name == '/home' || r.isFirst);
                    Future.microtask(() => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const OrderHistoryScreen(),
                            settings: const RouteSettings(name: '/orders'),
                          ),
                        ));
                  }),
              _navItem(context, Icons.shopping_cart_rounded, 'CART', false,
                  onTap: () {
                    Navigator.of(context).popUntil(
                        (r) => r.settings.name == '/home' || r.isFirst);
                    Future.microtask(() => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CartScreen(
                              items: AppCart.items,
                              orderMode: AppCart.orderMode,
                            ),
                            settings: const RouteSettings(name: '/cart'),
                          ),
                        ));
                  }),
              _navItem(
                  context, Icons.person_outline_rounded, 'PROFILE', true),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── APP BAR ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: Color(0xFF1B5135)),
                  ),
                  const Text(
                    'Account',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF1B5135),
                    ),
                  ),
                  const Icon(Icons.settings_outlined,
                      color: Color(0xFF1B5135)),
                ],
              ),
            ),

            // ── BODY SCROLL ───────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    // ── AVATAR SECTION ────────────────────────
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          width: 106,
                          height: 106,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=400&auto=format&fit=crop',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Badge Pill
                        Positioned(
                          bottom: -12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCD3AA),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_rounded,
                                    size: 14, color: Color(0xFF4A2511)),
                                const SizedBox(width: 4),
                                const Text(
                                  'GOLD\nMACARON',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    height: 1.1,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                    color: Color(0xFF4A2511),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // User Details
                    const Text(
                      'James Thorne',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B5135),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'james.thorne@artisan.mail',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6F6E6B),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // ── LOYALTY CARD ──────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'YOUR LOYALTY BALANCE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              color: Color(0xFFA1A09B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              const Text(
                                '2',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1B5135),
                                  height: 1.0,
                                ),
                              ),
                              const Text(
                                ',400',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1B5135),
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'pts',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Georgia',
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF8B8A88),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF286044),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Redeem',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Divider(
                              color: Color(0xFFF3F2EE), thickness: 1, height: 1),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Next reward at 3,000 pts',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6F6E6B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '600 to go',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8C6B46),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Progress Bar
                          Container(
                            height: 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F2EE),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 2400 / 3000,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8C6B46),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // ── PREFERENCE & SECURITY ─────────────────
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'PREFERENCE & SECURITY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: Color(0xFFA1A09B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...tiles.map((t) => _buildTile(t)),
                    const SizedBox(height: 16),

                    // ── SIGN OUT ──────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              title: const Text(
                                'Sign Out?',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1B5135),
                                ),
                              ),
                              content: const Text(
                                  'You will be signed out of Le Frais.'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel',
                                      style: TextStyle(
                                          color: Color(0xFF1B5135),
                                          fontWeight: FontWeight.w700)),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(ctx).pop(true),
                                  child: const Text('Sign Out',
                                      style: TextStyle(
                                          color: Color(0xFFC74343),
                                          fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                        icon: const Icon(Icons.logout_rounded, size: 20),
                        label: const Text(
                          'Sign Out',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFC74343),
                          side: const BorderSide(
                              color: Color(0xFFF5DDDB), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(_ProfileTileData data) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(data.icon, color: const Color(0xFF1B5135), size: 20),
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1A17),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8B8A88),
                    ),
                  ),
                ],
              ),
            ),
            // Badge / Chevron
            if (data.hasNotification)
              Container(
                margin: const EdgeInsets.only(right: 8),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF8C6B46),
                  shape: BoxShape.circle,
                ),
              ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFB3B1AC), size: 22),
          ],
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label,
      bool active, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (active)
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF1E3D2A),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            )
          else
            Icon(icon, color: const Color(0xFFB0AEAA), size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: active ? FontWeight.w800 : FontWeight.w500,
              color: active
                  ? const Color(0xFF1E3D2A)
                  : const Color(0xFFB0AEAA),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
