import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../shared/item_detail_screen.dart';
import '../cart/cart_screen.dart';
import '../../models/app_cart.dart';
import '../../models/cart_entry.dart';
import '../menu/menu_screen.dart';
import '../order/order_history_screen.dart';
import '../profile/profile_screen.dart';

// ── Delivery item model ───────────────────────────────────────────────────────

class _DeliveryItem {
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String? tag;
  final double? rating;

  const _DeliveryItem({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.tag,
    this.rating,
  });
}

// ── Static data ───────────────────────────────────────────────────────────────

const List<_DeliveryItem> _deliveryItems = [
  _DeliveryItem(
    name: 'Harvest Bowl',
    description:
        'Roasted sweet potato, farro, kale, tahini drizzle & pomegranate seeds.',
    price: 15.90,
    imageUrl:
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=900&auto=format&fit=crop',
    tag: 'BESTSELLER',
    rating: 4.8,
  ),
  _DeliveryItem(
    name: 'Truffle Slider',
    description:
        'Wagyu beef patty, black truffle mayo, aged cheddar on a brioche bun.',
    price: 18.50,
    imageUrl:
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=900&auto=format&fit=crop',
    tag: "CHEF'S PICK",
    rating: 4.9,
  ),
  _DeliveryItem(
    name: 'Valrhona Gateau',
    description:
        'Warm dark chocolate fondant with 66% Valrhona cocoa and salted caramel.',
    price: 11.75,
    imageUrl:
        'https://images.unsplash.com/photo-1548741487-18d198e44e8c?q=80&w=900&auto=format&fit=crop',
    tag: 'POPULAR',
    rating: 4.7,
  ),
  _DeliveryItem(
    name: 'Morning Roast Plate',
    description:
        'Flat white, avocado toast, soft-boiled egg & seasonal fruit. Full starter.',
    price: 14.00,
    imageUrl:
        'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?q=80&w=900&auto=format&fit=crop',
    rating: 4.6,
  ),
];

// ── Category data ─────────────────────────────────────────────────────────────

class _Category {
  final IconData icon;
  final String label;

  const _Category(this.icon, this.label);
}

const List<_Category> _categories = [
  _Category(Icons.restaurant_rounded, 'Mains'),
  _Category(Icons.bakery_dining_rounded, 'Bakery'),
  _Category(Icons.wine_bar_rounded, 'Drinks'),
  _Category(Icons.eco_rounded, 'Vegan'),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final Map<String, int> _cart = {};

  int get _totalCartItems => _cart.values.fold(0, (a, b) => a + b);
  double get _totalCartPrice {
    double total = 0;
    for (final item in _deliveryItems) {
      final qty = _cart[item.name] ?? 0;
      total += item.price * qty;
    }
    return total;
  }

  // ── ADD / Stepper inline widget ───────────────────────────────────────────
  Widget _buildAddStepper(_DeliveryItem item) {
    final qty = _cart[item.name] ?? 0;
    if (qty == 0) {
      return GestureDetector(
        onTap: () => setState(() => _cart[item.name] = 1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF14472A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Add to Cart',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14472A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (qty > 1) {
                  _cart[item.name] = qty - 1;
                } else {
                  _cart.remove(item.name);
                }
              });
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Icon(Icons.remove, size: 14, color: Colors.white),
            ),
          ),
          Text(
            '$qty',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _cart[item.name] = qty + 1),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Icon(Icons.add, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── Daily Speciality full-width card ─────────────────────────────────────
  void _openDetail(_DeliveryItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(
          name: item.name,
          description: item.description,
          price: item.price,
          imageUrl: item.imageUrl,
          tag: item.tag,
          rating: item.rating,
          orderMode: OrderMode.delivery,
        ),
      ),
    );
  }

  Widget _buildSpecialityCard(_DeliveryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image (tap → detail) ────────────────────────────────────────
          GestureDetector(
            onTap: () => _openDetail(item),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    item.imageUrl,
                    width: double.infinity,
                    height: 190,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, progress) => progress == null
                        ? child
                        : Container(
                            height: 190,
                            color: const Color(0xFFEFEEEA),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF14472A),
                              ),
                            ),
                          ),
                  ),
                ),
                if (item.tag != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDECD4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.tag!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFC77A1A),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                if (item.rating != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 13, color: Color(0xFFE8A317)),
                          const SizedBox(width: 3),
                          Text(
                            '${item.rating}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF14472A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Text + Stepper row ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Tap text area → detail
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openDetail(item),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Georgia',
                            color: Color(0xFF14472A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5A5853),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '₹${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E5C3A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Stepper — isolated, does NOT propagate to card tap
                _buildAddStepper(item),
              ],
            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),

      // ── App Bar ────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F6),
        elevation: 0,
        leadingWidth: 0,
        leading: const SizedBox.shrink(),
        titleSpacing: 16,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            const Text(
              'Le Frais',
              style: TextStyle(
                color: Color(0xFF14472A),
                fontSize: 22,
                fontFamily: 'Georgia',
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
              ),
            ),
            // Delivery badge + icons
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8A317),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'DELIVERY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined,
                          color: Color(0xFF14472A)),
                      onPressed: () {
                        final entries = _deliveryItems
                            .where((item) => (_cart[item.name] ?? 0) > 0)
                            .map((item) => CartEntry(
                                  name: item.name,
                                  price: item.price,
                                  imageUrl: item.imageUrl,
                                  qty: _cart[item.name]!,
                                ))
                            .toList();
                        AppCart.update(entries, OrderMode.delivery);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CartScreen(
                              items: entries,
                              orderMode: OrderMode.delivery,
                            ),
                            settings: const RouteSettings(name: '/cart'),
                          ),
                        );
                      },
                    ),
                    if (_totalCartItems > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Color(0xFF14472A),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$_totalCartItems',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Section ───────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2EFE8),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: text + buttons
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Le Frais',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF5A5853),
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Hand-\nCrafted\nSensations.',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Georgia',
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF14472A),
                              height: 1.1,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Artisan food, freshly\nprepared and delivered\nstraight to your door.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5A5853),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF14472A),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Order Now',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xFF14472A),
                                        width: 1.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Menu',
                                    style: TextStyle(
                                      color: Color(0xFF14472A),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right: Circular food image
                    Expanded(
                      flex: 2,
                      child: ClipOval(
                        child: Image.network(
                          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=600&auto=format&fit=crop',
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Estimated Delivery Banner ──────────────────────────────────
            Container(
              width: double.infinity,
              margin:
                  const EdgeInsets.symmetric(horizontal: 20),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEEEDE8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delivery_dining_rounded,
                      size: 17, color: Color(0xFF5A5853)),
                  const SizedBox(width: 8),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFF5A5853)),
                      children: [
                        TextSpan(text: 'Estimated Delivery ~ '),
                        TextSpan(
                          text: '30–40 min',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF14472A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── The Morning Roast Feature Card ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  height: 140,
                  color: const Color(0xFF1E3D2A),
                  child: Row(
                    children: [
                      // Text side
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'FEATURED',
                                  style: TextStyle(
                                    color: Color(0xFFAFE0CD),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'The Morning\nRoast',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Georgia',
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      size: 13, color: Color(0xFFF5C842)),
                                  const SizedBox(width: 4),
                                  const Text(
                                    '4.8 · \$14.00',
                                    style: TextStyle(
                                      color: Color(0xFFAFE0CD),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Image side
                      SizedBox(
                        width: 130,
                        height: 140,
                        child: Image.network(
                          'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?q=80&w=600&auto=format&fit=crop',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Artisan Bakery Feature Card ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  height: 130,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://images.unsplash.com/photo-1555507054-d6edcd01362e?q=80&w=900&auto=format&fit=crop'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'ARTISAN BAKERY',
                          style: TextStyle(
                            color: Color(0xFFF5C842),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Fresh from the\noven, daily.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Georgia',
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Category Icons Row ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _categories
                    .map(
                      (cat) => Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F0E8),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(cat.icon,
                                color: const Color(0xFF14472A), size: 28),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cat.label,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF14472A),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 30),

            // ── Daily Specialities ─────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Specialities',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Georgia',
                      color: Color(0xFF14472A),
                    ),
                  ),
                  Text(
                    'View all →',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5A5853),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 0, 20, 100),
              child: Column(
                children: _deliveryItems
                    .map((item) => _buildSpecialityCard(item))
                    .toList(),
              ),
            ),
          ],
        ),
      ),

      // ── Sticky cart banner ─────────────────────────────────────────────────
      bottomSheet: _totalCartItems > 0
          ? GestureDetector(
              onTap: () {
                final entries = _deliveryItems
                    .where((item) => (_cart[item.name] ?? 0) > 0)
                    .map((item) => CartEntry(
                          name: item.name,
                          price: item.price,
                          imageUrl: item.imageUrl,
                          qty: _cart[item.name]!,
                        ))
                    .toList();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CartScreen(
                      items: entries,
                      orderMode: OrderMode.delivery,
                    ),
                  ),
                );
              },
              child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF14472A),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF14472A)
                        .withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_totalCartItems ${_totalCartItems == 1 ? 'item' : 'items'} added',
                        style: const TextStyle(
                          color: Color(0xFFAFE0CD),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '₹${_totalCartPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Text(
                        'View Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 18),
                    ],
                  ),
                ],
              ),
              ),
            )
          : null,

      // ── Bottom Navigation ──────────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
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
              _navItem(
                Icons.home_outlined,
                'HOME',
                true,
                onTap: () => Navigator.of(context).pop(),
              ),
              _navItem(Icons.restaurant_menu_rounded, 'MENU', false,
                  onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MenuScreen(),
                          settings: const RouteSettings(name: '/menu'),
                        ),
                      )),
              _navItem(Icons.receipt_long_outlined, 'ORDERS', false,
                  onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OrderHistoryScreen(),
                          settings: const RouteSettings(name: '/orders'),
                        ),
                      )),
              _navItem(
                Icons.shopping_cart_rounded,
                'CART',
                false,
                onTap: () {
                  final entries = _deliveryItems
                      .where((item) => (_cart[item.name] ?? 0) > 0)
                      .map((item) => CartEntry(
                            name: item.name,
                            price: item.price,
                            imageUrl: item.imageUrl,
                            qty: _cart[item.name]!,
                          ))
                      .toList();
                  // Sync global cart so any screen can navigate here
                  AppCart.update(entries, OrderMode.delivery);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CartScreen(
                        items: entries,
                        orderMode: OrderMode.delivery,
                      ),
                      settings: const RouteSettings(name: '/cart'),
                    ),
                  );
                },
              ),
              _navItem(Icons.person_outline_rounded, 'PROFILE', false,
                  onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                          settings: const RouteSettings(name: '/profile'),
                        ),
                      )),
            ],
          ),
        ),
      ),    // closes Scaffold's bottomNavigationBar Container
    );        // closes Scaffold
  }
}
