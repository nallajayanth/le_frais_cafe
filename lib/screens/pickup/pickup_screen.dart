import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../shared/item_detail_screen.dart';
import '../cart/cart_screen.dart';
import '../../models/app_cart.dart';
import '../../models/cart_entry.dart';
import '../menu/menu_screen.dart';
import '../order/order_history_screen.dart';
import '../profile/profile_screen.dart';

// ── Pickup item model ─────────────────────────────────────────────────────────

class _PickupItem {
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final String? tag;
  final double? rating;
  final int? ratingCount;

  const _PickupItem({
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.tag,
    this.rating,
    this.ratingCount,
  });
}

// ── Static Data ───────────────────────────────────────────────────────────────

const List<_PickupItem> _pickupItems = [
  _PickupItem(
    name: 'Heirloom Breakfast Set',
    description: 'Espresso, croissant & seasonal jam',
    price: 12.50,
    originalPrice: 15.00,
    imageUrl: 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?q=80&w=900&auto=format&fit=crop',
    tag: 'BESTSELLER',
    rating: 4.5,
    ratingCount: 183,
  ),
  _PickupItem(
    name: 'Pain au Chocolat',
    description: 'Flaky layers, Belgian dark chocolate',
    price: 6.50,
    originalPrice: 8.00,
    imageUrl: 'https://images.unsplash.com/photo-1530610476181-d83430b64dcd?q=80&w=900&auto=format&fit=crop',
    tag: 'BESTSELLER',
    rating: 4.2,
    ratingCount: 97,
  ),
  _PickupItem(
    name: 'Daily Macarons',
    description: 'Box of 6, rotating seasonal flavors',
    price: 10.00,
    originalPrice: 13.00,
    imageUrl: 'https://images.unsplash.com/photo-1569864358642-9d1684040f43?q=80&w=900&auto=format&fit=crop',
    rating: 4.6,
    ratingCount: 241,
  ),
  _PickupItem(
    name: 'Midnight Truffle',
    description: 'Dark chocolate ganache, 3 included',
    price: 7.30,
    originalPrice: 9.00,
    imageUrl: 'https://images.unsplash.com/photo-1548741487-18d198e44e8c?q=80&w=900&auto=format&fit=crop',
    rating: 4.3,
    ratingCount: 58,
  ),
  _PickupItem(
    name: 'Artisan Sourdough',
    description: 'Whole loaf, baked every morning',
    price: 9.00,
    imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=900&auto=format&fit=crop',
    tag: 'POPULAR',
    rating: 4.8,
    ratingCount: 312,
  ),
  _PickupItem(
    name: 'Forest Mushroom Tart',
    description: 'Ricotta, truffle oil, wild greens',
    price: 11.00,
    imageUrl: 'https://images.unsplash.com/photo-1541529086526-db283c563270?q=80&w=900&auto=format&fit=crop',
    rating: 4.4,
    ratingCount: 76,
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class PickupScreen extends StatefulWidget {
  const PickupScreen({super.key});

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final Map<String, int> _cart = {};
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Breakfast',
    'Bakery',
    'Drinks',
    'Desserts',
  ];

  int get _totalCartItems => _cart.values.fold(0, (a, b) => a + b);
  double get _totalCartPrice {
    double total = 0;
    for (final item in _pickupItems) {
      final qty = _cart[item.name] ?? 0;
      total += item.price * qty;
    }
    return total;
  }

  // ── 2-Col Grid Card ───────────────────────────────────────────────────────
  Widget _buildGridCard(_PickupItem item) {
    final qty = _cart[item.name] ?? 0;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ItemDetailScreen(
            name: item.name,
            description: item.description,
            price: item.price,
            originalPrice: item.originalPrice,
            imageUrl: item.imageUrl,
            tag: item.tag,
            rating: item.rating,
            ratingCount: item.ratingCount,
          ),
        ),
      ),
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ──────────────────────────────────────────────────────────
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  item.imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Tag badge
              if (item.tag != null)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDECD4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.tag!,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFC77A1A),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // ── Content ────────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating
                  if (item.rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 13, color: Color(0xFF1E5C3A)),
                        const SizedBox(width: 3),
                        Text(
                          '${item.rating} (${item.ratingCount})',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5A5853),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),

                  // Name
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Georgia',
                      color: Color(0xFF14472A),
                      height: 1.2,
                    ),
                  ),
                  const Spacer(),

                  // Price row + ADD/stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Prices
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.originalPrice != null)
                            Text(
                              '₹${item.originalPrice!.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFAFADAA),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            '₹${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E5C3A),
                            ),
                          ),
                        ],
                      ),

                      // ADD button / Stepper
                      qty == 0
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  _cart[item.name] = 1;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF14472A),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'ADD',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF14472A),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF14472A),
                                borderRadius: BorderRadius.circular(10),
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
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 7),
                                      child: Icon(Icons.remove,
                                          size: 14, color: Colors.white),
                                    ),
                                  ),
                                  Text(
                                    '$qty',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _cart[item.name] = qty + 1;
                                      });
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 7),
                                      child: Icon(Icons.add,
                                          size: 14, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),  // closes child: Container
    );    // closes GestureDetector
  }

  // ── Bottom nav item ───────────────────────────────────────────────────────
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF14472A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5C842),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'PICK UP',
                style: TextStyle(
                  color: Color(0xFF3D2B00),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined,
                    color: Color(0xFF14472A)),
                onPressed: () {
                  final entries = _pickupItems
                      .where((item) => (_cart[item.name] ?? 0) > 0)
                      .map((item) => CartEntry(
                            name: item.name,
                            price: item.price,
                            imageUrl: item.imageUrl,
                            qty: _cart[item.name]!,
                          ))
                      .toList();
                  AppCart.update(entries, OrderMode.pickup);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CartScreen(
                        items: entries,
                        orderMode: OrderMode.pickup,
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

      body: Column(
        children: [
          // ── Ready Time Banner ────────────────────────────────────────────
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEDE8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 15, color: Color(0xFF5A5853)),
                const SizedBox(width: 8),
                RichText(
                  text: const TextSpan(
                    style:
                        TextStyle(fontSize: 13, color: Color(0xFF5A5853)),
                    children: [
                      TextSpan(text: 'Estimated Ready Time ~ '),
                      TextSpan(
                        text: '20 min',
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

          // ── Search bar ────────────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F0E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search pickup items...',
                  hintStyle:
                      TextStyle(color: Color(0xFFAFAFAC), fontSize: 14),
                  prefixIcon: Icon(Icons.search,
                      color: Color(0xFFAFAFAC), size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // ── Category Chips ────────────────────────────────────────────────
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF14472A)
                          : const Color(0xFFF1F0E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF5A5853),
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // ── Section Header ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pick of the Batch',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Georgia',
                    color: Color(0xFF14472A),
                  ),
                ),
                Text(
                  '${_pickupItems.length} items',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5A5853),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── 2-Column Grid ─────────────────────────────────────────────────
          Expanded(
            child: GridView.builder(
              padding:
                  const EdgeInsets.fromLTRB(16, 0, 16, 100),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.62,
              ),
              itemCount: _pickupItems.length,
              itemBuilder: (_, i) => _buildGridCard(_pickupItems[i]),
            ),
          ),
        ],
      ),

      // ── Sticky cart banner ────────────────────────────────────────────────
      bottomSheet: _totalCartItems > 0
          ? GestureDetector(
              onTap: () {
                final entries = _pickupItems
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
                      orderMode: OrderMode.pickup,
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
                    color: const Color(0xFF14472A).withValues(alpha: 0.4),
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

      // ── Bottom Navigation ─────────────────────────────────────────────────
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
                  final entries = _pickupItems
                      .where((item) => (_cart[item.name] ?? 0) > 0)
                      .map((item) => CartEntry(
                            name: item.name,
                            price: item.price,
                            imageUrl: item.imageUrl,
                            qty: _cart[item.name]!,
                          ))
                      .toList();
                  // Sync global cart so any screen can navigate here
                  AppCart.update(entries, OrderMode.pickup);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CartScreen(
                        items: entries,
                        orderMode: OrderMode.pickup,
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
