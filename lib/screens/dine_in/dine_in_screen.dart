import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../shared/item_detail_screen.dart';
import '../cart/cart_screen.dart';
import '../../models/app_cart.dart';
import '../../models/cart_entry.dart';
import '../menu/menu_screen.dart';
import '../order/order_history_screen.dart';
import '../profile/profile_screen.dart';

// ── Dine-In item model ────────────────────────────────────────────────────────

class _DineInItem {
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final String category;
  final String? tag;
  final double? rating;
  final int? ratingCount;

  const _DineInItem({
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    required this.category,
    this.tag,
    this.rating,
    this.ratingCount,
  });
}

// ── Static Data ───────────────────────────────────────────────────────────────

const List<_DineInItem> _dineInItems = [
  _DineInItem(
    name: 'Pain au Chocolat',
    description: '24-hour fermented dough with 70% dark Belgian chocolate.',
    price: 6.50,
    originalPrice: 8.00,
    imageUrl:
        'https://images.unsplash.com/photo-1530610476181-d83430b64dcd?q=80&w=800&auto=format&fit=crop',
    category: 'Bakery',
    tag: 'BESTSELLER',
    rating: 4.9,
    ratingCount: 214,
  ),
  _DineInItem(
    name: 'Signature Latte',
    description: 'Single origin Peruvian beans with silky micro-foam.',
    price: 5.25,
    originalPrice: 6.50,
    imageUrl:
        'https://images.unsplash.com/photo-1511920170033-f8396924c348?q=80&w=800&auto=format&fit=crop',
    category: 'All Day',
    tag: 'POPULAR',
    rating: 4.8,
    ratingCount: 389,
  ),
  _DineInItem(
    name: 'Forest Green Bowl',
    description: 'Kale, avocado, poached egg, and house-made walnut pesto.',
    price: 14.00,
    imageUrl:
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=800&auto=format&fit=crop',
    category: 'Breakfast',
    tag: 'FARM FRESH',
    rating: 5.0,
    ratingCount: 127,
  ),
  _DineInItem(
    name: 'Smoked Salmon Brioche',
    description: 'House smoked salmon on toasted brioche with capers.',
    price: 19.00,
    imageUrl:
        'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?q=80&w=800&auto=format&fit=crop',
    category: 'Breakfast',
    rating: 4.7,
    ratingCount: 88,
  ),
  _DineInItem(
    name: 'Almond Croissant',
    description: 'Double baked with frangipane and sliced almonds.',
    price: 7.00,
    originalPrice: 9.00,
    imageUrl:
        'https://images.unsplash.com/photo-1555507054-d6edcd01362e?q=80&w=800&auto=format&fit=crop',
    category: 'Bakery',
    rating: 4.9,
    ratingCount: 305,
  ),
  _DineInItem(
    name: 'Truffle Mushroom Toast',
    description: 'Wild mushrooms, black truffle oil and aged parmesan.',
    price: 18.50,
    imageUrl:
        'https://images.unsplash.com/photo-1541529086526-db283c563270?q=80&w=800&auto=format&fit=crop',
    category: 'Lunch',
    tag: "CHEF'S PICK",
    rating: 4.8,
    ratingCount: 156,
  ),
  _DineInItem(
    name: 'Cold Brew Tonic',
    description: 'Slow-steeped 18-hour cold brew with elderflower tonic.',
    price: 6.00,
    originalPrice: 7.50,
    imageUrl:
        'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?q=80&w=800&auto=format&fit=crop',
    category: 'All Day',
    rating: 4.6,
    ratingCount: 201,
  ),
  _DineInItem(
    name: 'Ricotta Lemon Tart',
    description: 'Whipped ricotta, lemon curd and candied zest in butter pastry.',
    price: 8.50,
    imageUrl:
        'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?q=80&w=800&auto=format&fit=crop',
    category: 'Dinner',
    rating: 4.7,
    ratingCount: 94,
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class DineInScreen extends StatefulWidget {
  const DineInScreen({super.key});

  @override
  State<DineInScreen> createState() => _DineInScreenState();
}

class _DineInScreenState extends State<DineInScreen> {
  final Map<String, int> _cart = {};
  String _selectedCategory = 'All Day';
  final List<String> _categories = [
    'All Day',
    'Breakfast',
    'Bakery',
    'Lunch',
    'Dinner',
  ];

  List<_DineInItem> get _filteredItems {
    if (_selectedCategory == 'All Day') return _dineInItems;
    return _dineInItems
        .where((item) => item.category == _selectedCategory)
        .toList();
  }

  int get _totalCartItems => _cart.values.fold(0, (a, b) => a + b);

  double get _totalCartPrice {
    double total = 0;
    for (final item in _dineInItems) {
      final qty = _cart[item.name] ?? 0;
      total += item.price * qty;
    }
    return total;
  }

  // ── 2-Col Grid Card ───────────────────────────────────────────────────────
  Widget _buildGridCard(_DineInItem item) {
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
                  loadingBuilder: (ctx, child, progress) =>
                      progress == null
                          ? child
                          : Container(
                              height: 140,
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
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
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
                          '${item.rating}${item.ratingCount != null ? ' (${item.ratingCount})' : ''}',
                          style: const TextStyle(
                            fontSize: 10,
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
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Georgia',
                      color: Color(0xFF14472A),
                      height: 1.2,
                    ),
                  ),
                  const Spacer(),

                  // Price + ADD / Stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.originalPrice != null)
                            Text(
                              '₹${item.originalPrice!.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFFAFADAA),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            '₹${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E5C3A),
                            ),
                          ),
                        ],
                      ),

                      // ADD or stepper
                      qty == 0
                          ? GestureDetector(
                              onTap: () =>
                                  setState(() => _cart[item.name] = 1),
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
                                    onTap: () => setState(
                                        () => _cart[item.name] = qty + 1),
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
    final items = _filteredItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),

      // ── App Bar ───────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F6),
        elevation: 0,
        leadingWidth: 0,
        leading: const SizedBox.shrink(),
        titleSpacing: 16,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Table badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6B8B77),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.table_restaurant_rounded,
                      color: Colors.white, size: 13),
                  SizedBox(width: 5),
                  Text(
                    'TABLE 7',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
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
            // Cart icon with live badge
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined,
                      color: Color(0xFF14472A)),
                  onPressed: () {
                    final entries = _dineInItems
                        .where((item) => (_cart[item.name] ?? 0) > 0)
                        .map((item) => CartEntry(
                              name: item.name,
                              price: item.price,
                              imageUrl: item.imageUrl,
                              qty: _cart[item.name]!,
                            ))
                        .toList();
                    AppCart.update(entries, OrderMode.dineIn);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CartScreen(
                          items: entries,
                          orderMode: OrderMode.dineIn,
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
      ),

      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F0E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search our artisan menu...',
                  hintStyle: TextStyle(
                      color: Color(0xFFAFAFAC), fontSize: 14),
                  prefixIcon: Icon(Icons.search,
                      color: Color(0xFFAFAFAC), size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // ── Category Chips ──────────────────────────────────────────────
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

          // ── Section Header ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCategory == 'All Day'
                      ? 'Full Menu'
                      : _selectedCategory,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Georgia',
                    color: Color(0xFF14472A),
                  ),
                ),
                Text(
                  '${items.length} items',
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

          // ── 2-Column Grid ───────────────────────────────────────────────
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restaurant_menu_outlined,
                            size: 48, color: Color(0xFFB0AEAA)),
                        SizedBox(height: 12),
                        Text(
                          'No items in this category',
                          style: TextStyle(
                            color: Color(0xFF5A5853),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _buildGridCard(items[i]),
                  ),
          ),
        ],
      ),

      // ── Sticky cart banner ──────────────────────────────────────────────
      bottomSheet: _totalCartItems > 0
          ? GestureDetector(
              onTap: () {
                final entries = _dineInItems
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
                      orderMode: OrderMode.dineIn,
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

      // ── Bottom Navigation ───────────────────────────────────────────────
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
                  final entries = _dineInItems
                      .where((item) => (_cart[item.name] ?? 0) > 0)
                      .map((item) => CartEntry(
                            name: item.name,
                            price: item.price,
                            imageUrl: item.imageUrl,
                            qty: _cart[item.name]!,
                          ))
                      .toList();
                  // Sync global cart so any screen can navigate here
                  AppCart.update(entries, OrderMode.dineIn);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CartScreen(
                        items: entries,
                        orderMode: OrderMode.dineIn,
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
