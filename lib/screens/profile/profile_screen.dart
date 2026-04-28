import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../cart/cart_screen.dart';
import '../order/order_history_screen.dart';
import '../address/address_picker_sheet.dart';
import '../shared/custom_bottom_nav_bar.dart';

class _ProfileTileData {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool hasNotification;
  final VoidCallback? onTap;

  _ProfileTileData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
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
        iconBg: const Color(0xFFE9F5EC),
        iconColor: const Color(0xFF1E5C3A),
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
        iconBg: const Color(0xFFEDF2FF),
        iconColor: const Color(0xFF3B5BDB),
        title: 'Saved Addresses',
        subtitle: 'Manage delivery destinations',
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => AddressPickerSheet(
              selected: null,
              onSelected: (_) {},
            ),
          );
        },
      ),
      _ProfileTileData(
        icon: Icons.notifications_none_rounded,
        iconBg: const Color(0xFFFFF3E0),
        iconColor: const Color(0xFFC88B1A),
        title: 'Notifications',
        subtitle: 'Manage alerts and news',
        hasNotification: true,
      ),
      _ProfileTileData(
        icon: Icons.account_balance_wallet_outlined,
        iconBg: const Color(0xFFEEF4FF),
        iconColor: const Color(0xFF5B6AF0),
        title: 'Payments',
        subtitle: 'Default methods and billing',
      ),
      _ProfileTileData(
        icon: Icons.help_outline_rounded,
        iconBg: const Color(0xFFF6F0FF),
        iconColor: const Color(0xFF8B5CF6),
        title: 'Help & Support',
        subtitle: 'FAQs and direct assistance',
      ),
      _ProfileTileData(
        icon: Icons.card_giftcard_rounded,
        iconBg: const Color(0xFFFFF0F6),
        iconColor: const Color(0xFFE64980),
        title: 'Rewards',
        subtitle: 'See your exclusive rewards',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EC),
      bottomNavigationBar: const CustomBottomNavBar(activeIndex: 4),
      body: Stack(
        children: [
          // Header gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0F2A1A), Color(0xFFF4F2EC)],
                  stops: [0.0, 0.88],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 16, color: Colors.white),
                        ),
                      ),
                      const Text(
                        'My Account',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.settings_outlined,
                            color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),

                // Scrollable body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // Avatar section with gold ring
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Gold ring
                            Container(
                              width: 118,
                              height: 118,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFC88B1A), Color(0xFFDAA520), Color(0xFF8B5A10)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFC88B1A).withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                    spreadRadius: -4,
                                  ),
                                ],
                              ),
                            ),
                            // Avatar
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
                            // Edit button
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFC88B1A),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit, color: Colors.white, size: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Member badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFCD3AA), Color(0xFFFFE8CC)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFC88B1A).withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, size: 14, color: Color(0xFF8B5A10)),
                              SizedBox(width: 5),
                              Text(
                                'GOLD MACARON MEMBER',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  color: Color(0xFF8B5A10),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        const Text(
                          'James Thorne',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F2A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'james.thorne@artisan.mail',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6F6E6B),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Loyalty card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F2A1A), Color(0xFF1E4D30), Color(0xFF1A3D26)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F2A1A).withValues(alpha: 0.4),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                                spreadRadius: -4,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'LOYALTY BALANCE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.8,
                                      color: Colors.white54,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC88B1A).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFFC88B1A).withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: const Text(
                                      '⭐  GOLD',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFC88B1A),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  const Text(
                                    '2,400',
                                    style: TextStyle(
                                      fontSize: 52,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'pts',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Georgia',
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: 2400 / 3000,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFC88B1A), Color(0xFFDAA520)],
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    'Next reward at 3,000 pts',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '600 pts to go',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFC88B1A),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFB8860B), Color(0xFFDAA520)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFC88B1A).withValues(alpha: 0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {},
                                    borderRadius: BorderRadius.circular(16),
                                    child: const Center(
                                      child: Text(
                                        'Redeem Points',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Section header
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'PREFERENCES & SECURITY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.8,
                              color: Color(0xFF9A9690),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...tiles.map((t) => _buildTile(t)),
                        const SizedBox(height: 16),

                        // Sign out
                        GestureDetector(
                          onTap: () async {
                            final confirm = await showDialog<bool>(
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
                                        color: Colors.black.withValues(alpha: 0.12),
                                        blurRadius: 30,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFEE2E2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 26),
                                      ),
                                      const SizedBox(height: 18),
                                      const Text(
                                        'Sign Out?',
                                        style: TextStyle(
                                          fontFamily: 'Georgia',
                                          fontWeight: FontWeight.w900,
                                          fontSize: 22,
                                          color: Color(0xFF0F2A1A),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'You will be signed out of Le Frais.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 14, color: Color(0xFF6A6865), height: 1.5),
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
                                                  child: Text('Cancel',
                                                      style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF3A3835))),
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
                                                  child: Text('Sign Out',
                                                      style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFDC2626))),
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
                            if (confirm == true && context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (route) => false,
                              );
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEDED),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout_rounded, size: 18, color: Color(0xFFDC2626)),
                                SizedBox(width: 8),
                                Text(
                                  'Sign Out',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(_ProfileTileData data) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: data.iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(data.icon, color: data.iconColor, size: 22),
            ),
            const SizedBox(width: 14),
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
            if (data.hasNotification)
              Container(
                margin: const EdgeInsets.only(right: 8),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFC88B1A),
                  shape: BoxShape.circle,
                ),
              ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Color(0xFFD0CEC9), size: 14),
          ],
        ),
      ),
    );
  }
}
