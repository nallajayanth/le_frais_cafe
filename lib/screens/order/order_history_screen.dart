import 'package:flutter/material.dart';
import '../../models/app_cart.dart';
import '../cart/cart_screen.dart';
import '../menu/menu_screen.dart';
import 'order_tracker_screen.dart';
import '../profile/profile_screen.dart';

enum OrderHistoryStatus { delivered, cancelled, inProgress }

class OrderHistoryEntry {
  final String orderId;
  final String imageUrl;
  final OrderHistoryStatus status;
  final String date;
  final String mode;
  final String itemsCount;
  final String total;

  OrderHistoryEntry({
    required this.orderId,
    required this.imageUrl,
    required this.status,
    required this.date,
    required this.mode,
    required this.itemsCount,
    required this.total,
  });
}

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final List<OrderHistoryEntry> mockOrders = [
    OrderHistoryEntry(
      orderId: '#LF-8830',
      imageUrl:
          'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=400&auto=format&fit=crop', // latte image
      status: OrderHistoryStatus.inProgress,
      date: 'Oct 24, 2023',
      mode: 'Dine-In',
      itemsCount: '3 Items',
      total: '₹24.50',
    ),
    OrderHistoryEntry(
      orderId: '#LF-8829',
      imageUrl:
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=400&auto=format&fit=crop', // bakery bread image
      status: OrderHistoryStatus.delivered,
      date: 'Oct 24, 2023',
      mode: 'Delivery',
      itemsCount: '2 Items',
      total: '₹42.50',
    ),
    OrderHistoryEntry(
      orderId: '#LF-8742',
      imageUrl:
          'https://images.unsplash.com/photo-1555507054-d6edcd01362e?q=80&w=400&auto=format&fit=crop', // pastries image
      status: OrderHistoryStatus.cancelled,
      date: 'Oct 18, 2023',
      mode: 'Pickup',
      itemsCount: '5 Items',
      total: '₹18.20',
    ),
    OrderHistoryEntry(
      orderId: '#LF-8601',
      imageUrl:
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?q=80&w=400&auto=format&fit=crop', // croissants image
      status: OrderHistoryStatus.delivered,
      date: 'Oct 12, 2023',
      mode: 'Dine-In',
      itemsCount: '3 Items',
      total: '₹31.00',
    ),
  ];

  Widget _buildChip(OrderHistoryStatus status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case OrderHistoryStatus.delivered:
        bgColor = const Color(0xFFFBE4CD);
        textColor = const Color(0xFF8B5E34);
        text = 'DELIVERED';
        break;
      case OrderHistoryStatus.cancelled:
        bgColor = const Color(0xFFFDE8EA);
        textColor = const Color(0xFFB14D56);
        text = 'CANCELLED';
        break;
      case OrderHistoryStatus.inProgress:
        bgColor = const Color(0xFFD8ECD9);
        textColor = const Color(0xFF285C42);
        text = 'IN PROGRESS';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCardInfoCol(String label, String value,
      {bool isTotal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9B9A96),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            color: isTotal ? const Color(0xFF8B5E34) : const Color(0xFF383733),
            fontFamily: isTotal ? 'Courier' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(OrderHistoryEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.network(
              entry.imageUrl,
              height: 140,
              width: 140,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 140,
                width: 140,
                color: const Color(0xFFEFEFEA),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ORDER ID',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFA1A09B),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.orderId,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1D1B18),
                    ),
                  ),
                ],
              ),
              _buildChip(entry.status),
            ],
          ),

          const SizedBox(height: 24),

          // Details grid
          Row(
            children: [
              Expanded(child: _buildCardInfoCol('DATE', entry.date)),
              Expanded(child: _buildCardInfoCol('MODE', entry.mode)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildCardInfoCol('ITEMS', entry.itemsCount)),
              Expanded(
                child: _buildCardInfoCol('TOTAL', entry.total, isTotal: true),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(
            color: Color(0xFFF3F3EF),
            height: 1,
            thickness: 1,
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (entry.status == OrderHistoryStatus.delivered ||
                  entry.status == OrderHistoryStatus.inProgress) ...[
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF285C42),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (entry.status == OrderHistoryStatus.inProgress) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OrderTrackerScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F5238),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    entry.status == OrderHistoryStatus.inProgress
                        ? 'Track Order'
                        : 'Reorder',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ] else if (entry.status == OrderHistoryStatus.cancelled) ...[
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE9E9E4),
                    foregroundColor: const Color(0xFF385E47),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Support',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── Nav item ──────────────────────────────────────────────────────────────
  Widget _navItem(IconData icon, String label, bool active,
      {VoidCallback? onTap}) {
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
              color: active ? const Color(0xFF1E3D2A) : const Color(0xFFB0AEAA),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 26,
                      color: Color(0xFF0F442D),
                    ),
                  ),
                  const Text(
                    'Past Orders',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F442D),
                    ),
                  ),
                  const Icon(
                    Icons.settings_outlined,
                    size: 24,
                    color: Color(0xFF0F442D),
                  ),
                ],
              ),
            ),

            // ── Body ──────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  const Text(
                    'The Artisan History',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Georgia',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF385E47),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Every bite tells a story. Revisit your favorite\nmoments from our bakery atelier.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF5A5853),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ...mockOrders.map((entry) => _buildOrderCard(entry)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Navigation ──────────────────────────────────────────────────
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
              // HOME – pop back to home ordering screen
              _navItem(Icons.home_outlined, 'HOME', false, onTap: () {
                Navigator.of(context).popUntil(
                    (r) => r.settings.name == '/home' || r.isFirst);
              }),
              // MENU – go home then push MenuScreen
              _navItem(Icons.restaurant_menu_rounded, 'MENU', false, onTap: () {
                Navigator.of(context).popUntil(
                    (r) => r.settings.name == '/home' || r.isFirst);
                Future.microtask(() => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MenuScreen(),
                      settings: const RouteSettings(name: '/menu'),
                    )));
              }),
              // ORDERS – already here, do nothing
              _navItem(Icons.receipt_long_outlined, 'ORDERS', true),
              // CART – open CartScreen using global cart (shows cart items if any)
              _navItem(
                Icons.shopping_cart_rounded,
                'CART',
                false,
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
                },
              ),
              // PROFILE – go home then push ProfileScreen
              _navItem(Icons.person_outline_rounded, 'PROFILE', false, onTap: () {
                Navigator.of(context).popUntil(
                    (r) => r.settings.name == '/home' || r.isFirst);
                Future.microtask(() => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                      settings: const RouteSettings(name: '/profile'),
                    )));
              }),
            ],
          ),
        ),
      ),
    );
  }
}
