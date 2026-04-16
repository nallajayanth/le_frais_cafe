import 'package:flutter/material.dart';
import '../shared/item_detail_screen.dart';
import '../cart/cart_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_entry.dart';
import '../../models/menu_item.dart';
import '../../data/menu_data.dart';
import '../menu/menu_screen.dart';
import '../order/order_history_screen.dart';
import '../profile/profile_screen.dart';

import '../shared/custom_bottom_nav_bar.dart';

class DineInScreen extends StatefulWidget {
  const DineInScreen({super.key});

  @override
  State<DineInScreen> createState() => _DineInScreenState();
}

class _DineInScreenState extends State<DineInScreen> {
  String _selectedCategory = 'All';
  
  static const Color _darkGreen = Color(0xFF1E3D2A);
  static const Color _accentGreen = Color(0xFF2D8653);
  static const Color _bgCream = Color(0xFFFDFCF9);
  static const Color _gold = Color(0xFFC77A1A);

  List<String> get _categories => [
    'All',
    'Appetizers',
    'Chinese Starters',
    'Momos',
    'Burgers',
    'Noodles',
    'Rice',
  ];

  List<MenuItem> get _filteredItems {
    if (_selectedCategory == 'All') return MenuData.getAllItems();
    return MenuData.getAllItems().where((item) => item.category == _selectedCategory).toList();
  }

  // ── Header Component ───────────────────────────────────────────────────
  Widget _buildHeader(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6B8B77),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.table_restaurant_rounded, color: Colors.white, size: 13),
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
          Hero(
            tag: 'app_logo',
            child: Image.asset(
              'assets/logo.jpg',
              height: 38,
              fit: BoxFit.contain,
            ),
          ),
          _circleButton(
            icon: Icons.shopping_cart_outlined,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen())),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: _darkGreen),
      ),
    );
  }

  // ── Grid Item Card ──────────────────────────────────────────────────────
  Widget _buildGridCard(MenuItem item, CartProvider cart) {
    final cartItemIndex = cart.items.indexWhere((e) => e.name == item.name);
    final qty = cartItemIndex >= 0 ? cart.items[cartItemIndex].qty : 0;

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
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  Hero(
                    tag: 'item_dine_${item.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Image.network(
                        item.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFF2EFEE),
                          child: const Center(
                            child: Icon(Icons.image_not_supported_outlined, color: Color(0xFFB0AEAA), size: 32),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(top: 10, left: 10, child: _vegIndicator(item.isVeg)),
                  if (item.tag != null)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: const BoxDecoration(
                          color: _gold,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(15)),
                        ),
                        child: Text(item.tag!, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Georgia', color: _darkGreen),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF8A8884), height: 1.3),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('₹${item.price}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _accentGreen)),
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
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: isVeg ? Colors.green : Colors.red, width: 1), borderRadius: BorderRadius.circular(3)),
      child: Container(width: 6, height: 6, decoration: BoxDecoration(color: isVeg ? Colors.green : Colors.red, shape: BoxShape.circle)),
    );
  }

  Widget _quantityControls(MenuItem item, CartProvider cart, int qty) {
    if (qty == 0) {
      return GestureDetector(
        onTap: () => cart.addItem(CartEntry(name: item.name, price: item.price, imageUrl: item.imageUrl, qty: 1)),
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(color: _darkGreen, shape: BoxShape.circle),
          child: const Icon(Icons.add, color: Colors.white, size: 16),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(color: _bgCream, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEAE8E4))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              final idx = cart.items.indexWhere((e) => e.name == item.name);
              cart.decrementQuantity(idx);
            },
            child: const Icon(Icons.remove, size: 14, color: _darkGreen),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: _darkGreen)),
          ),
          GestureDetector(
            onTap: () {
              final idx = cart.items.indexWhere((e) => e.name == item.name);
              cart.incrementQuantity(idx);
            },
            child: const Icon(Icons.add, size: 14, color: _darkGreen),
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
            
            // Search Bar Placeholder (consistent style)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 48,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)]),
                child: const Row(
                  children: [
                    Icon(Icons.search, size: 20, color: Color(0xFFB0AEAA)),
                    SizedBox(width: 12),
                    Text('Search in Dine-In Menu...', style: TextStyle(color: Color(0xFFB0AEAA), fontSize: 13)),
                  ],
                ),
              ),
            ),

            // Category Scroll
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  itemBuilder: (ctx, i) {
                    final cat = _categories[i];
                    final active = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(color: active ? _darkGreen : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: active ? Colors.transparent : const Color(0xFFEAE8E4))),
                        alignment: Alignment.center,
                        child: Text(cat.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: active ? Colors.white : const Color(0xFF6A6865), letterSpacing: 0.5)),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Item Grid
            Expanded(
              child: items.isEmpty 
              ? const Center(child: Text('No items found.'))
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.58,
                  ),
                  itemCount: items.length,
                  itemBuilder: (ctx, i) => _buildGridCard(items[i], cart),
                ),
            ),
          ],
        ),
      ),

      // ── Cart Bottom Sheet ─────────────────────────────────────────────
      bottomSheet: cart.totalItems > 0 
        ? Container(
            padding: const EdgeInsets.fromLTRB(25, 12, 25, 25),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -10))]),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen())),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: _darkGreen, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${cart.totalItems} ITEMS', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800)),
                        Text('₹${cart.subtotal}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const Spacer(),
                    const Text('CHECKOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                    const Icon(Icons.arrow_right_alt_rounded, color: Colors.white),
                  ],
                ),
              ),
            ),
          )
        : null,

      bottomNavigationBar: const CustomBottomNavBar(activeIndex: 0),
    );
  }
}
