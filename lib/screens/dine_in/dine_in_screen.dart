import 'package:flutter/material.dart';
import '../shared/item_detail_screen.dart';
import '../cart/cart_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_entry.dart';
import '../../models/menu_item.dart';
import '../../data/menu_data.dart';
import '../shared/custom_bottom_nav_bar.dart';

class DineInScreen extends StatefulWidget {
  const DineInScreen({super.key});

  @override
  State<DineInScreen> createState() => _DineInScreenState();
}

class _DineInScreenState extends State<DineInScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'All';
  late AnimationController _headerAnimController;
  late Animation<double> _headerFade;

  static const Color _darkGreen = Color(0xFF0F2A1A);
  static const Color _accentGreen = Color(0xFF1E5C3A);
  static const Color _lightGreen = Color(0xFF2D8653);
  static const Color _gold = Color(0xFFC88B1A);
  static const Color _bgCream = Color(0xFFF4F2EC);

  final List<String> _categories = [
    'All', 'Appetizers', 'Chinese Starters', 'Momos', 'Burgers', 'Noodles', 'Rice',
  ];

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerFade = CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOut);
    _headerAnimController.forward();
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    super.dispose();
  }

  List<MenuItem> get _filteredItems {
    if (_selectedCategory == 'All') return MenuData.getAllItems();
    return MenuData.getAllItems()
        .where((item) => item.category == _selectedCategory)
        .toList();
  }

  Widget _buildHeader(CartProvider cart) {
    return FadeTransition(
      opacity: _headerFade,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F2A1A), Color(0xFF1E4D30)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F2A1A).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          children: [
            // Back button
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Logo + mode badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/logo.jpg',
                    height: 30,
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _gold.withValues(alpha: 0.4), width: 1),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.table_restaurant_rounded, color: Color(0xFFC88B1A), size: 11),
                            SizedBox(width: 4),
                            Text(
                              'TABLE 7  •  DINE-IN',
                              style: TextStyle(
                                color: Color(0xFFC88B1A),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
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

            // Cart button
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartScreen()),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 22),
                  ),
                  if (cart.totalItems > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _gold,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0F2A1A), width: 2),
                        ),
                        child: Text(
                          '${cart.totalItems}',
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAE8E2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.search_rounded, size: 20, color: Color(0xFFB0AEAA)),
          SizedBox(width: 10),
          Text(
            'Search in the menu...',
            style: TextStyle(color: Color(0xFFB0AEAA), fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (ctx, i) {
          final cat = _categories[i];
          final active = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                gradient: active
                    ? const LinearGradient(
                        colors: [Color(0xFF0F2A1A), Color(0xFF1E5C3A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: active ? null : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: active ? Colors.transparent : const Color(0xFFE0DDD8),
                  width: 1.5,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0F2A1A).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : const Color(0xFF6A6865),
                  letterSpacing: 0.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridCard(MenuItem item, CartProvider cart) {
    final qty = cart.getItemQuantity(item.name);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ItemDetailScreen(
            name: item.name,
            description: item.description,
            price: item.price,
            imageUrl: item.imageUrl,
            tag: item.tag,
            rating: item.rating,
            isVeg: item.isVeg,
            customizations: item.customizations,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Image.network(
                      item.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF0EDE6),
                        child: const Center(
                          child: Icon(Icons.fastfood_rounded, color: Color(0xFFCECCC8), size: 36),
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay at bottom of image
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.35)],
                        ),
                      ),
                    ),
                  ),
                  // Veg indicator
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _vegIndicator(item.isVeg),
                  ),
                  // Tag badge
                  if (item.tag != null)
                    Positioned(
                      bottom: 8,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _gold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.tag!.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Georgia',
                        color: _darkGreen,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF9A9690), height: 1.3),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '₹${item.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: _lightGreen,
                          ),
                        ),
                        _quantityControls(item, cart, qty),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vegIndicator(bool isVeg) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: isVeg ? const Color(0xFF2D8653) : Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: isVeg ? const Color(0xFF2D8653) : Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _quantityControls(MenuItem item, CartProvider cart, int qty) {
    if (qty == 0) {
      return GestureDetector(
        onTap: () => cart.addItem(CartEntry(
          name: item.name,
          price: item.price,
          imageUrl: item.imageUrl,
          qty: 1,
        )),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F2A1A), Color(0xFF1E5C3A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E5C3A).withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0EFEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0DDD8), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              final idx = cart.findFirstIndexByName(item.name);
              cart.decrementQuantity(idx);
            },
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.remove_rounded, size: 14, color: _accentGreen),
            ),
          ),
          Text(
            '$qty',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: _darkGreen),
          ),
          GestureDetector(
            onTap: () {
              final idx = cart.findFirstIndexByName(item.name);
              cart.incrementQuantity(idx);
            },
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.add_rounded, size: 14, color: _accentGreen),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = _filteredItems;

    return Scaffold(
      backgroundColor: _bgCream,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(cart),
            const SizedBox(height: 8),
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildCategoryBar(),
            const SizedBox(height: 12),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_rounded, size: 64, color: Colors.black.withValues(alpha: 0.1)),
                          const SizedBox(height: 16),
                          const Text('No items in this category.',
                              style: TextStyle(color: Color(0xFF9A9690), fontSize: 15)),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.60,
                      ),
                      itemCount: items.length,
                      itemBuilder: (ctx, i) => _buildGridCard(items[i], cart),
                    ),
            ),
          ],
        ),
      ),
      bottomSheet: cart.totalItems > 0
          ? _buildCartBanner(cart)
          : null,
      bottomNavigationBar: const CustomBottomNavBar(activeIndex: 0),
    );
  }

  Widget _buildCartBanner(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CartScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F2A1A), Color(0xFF1A4A2E)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F2A1A).withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${cart.totalItems} ${cart.totalItems == 1 ? 'item' : 'items'} in cart',
                    style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '₹${cart.subtotal.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC88B1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Text(
                      'CHECKOUT',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
