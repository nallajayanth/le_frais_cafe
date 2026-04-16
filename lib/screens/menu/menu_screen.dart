import 'package:flutter/material.dart';
import '../shared/item_detail_screen.dart';
import '../cart/cart_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_entry.dart';
import '../../models/menu_item.dart';
import '../../data/menu_data.dart';

import '../shared/custom_bottom_nav_bar.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const Color _darkGreen = Color(0xFF1E3D2A);
  static const Color _accentGreen = Color(0xFF2D8653);
  static const Color _bgCream = Color(0xFFFDFCF9);
  static const Color _gold = Color(0xFFC77A1A);

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<MenuItem> get _allItems => MenuData.getAllItems();

  List<String> get _categories => [
    'All',
    'Appetizers',
    'Chinese Starters',
    'Momos',
    'Burgers',
    'Noodles',
    'Rice',
  ];

  List<MenuItem> get _visibleItems {
    List<MenuItem> items;
    if (_selectedCategory == 'All') {
      items = _allItems;
    } else {
      items = _allItems.where((i) => i.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items.where((i) =>
        i.name.toLowerCase().contains(q) ||
        i.description.toLowerCase().contains(q)).toList();
    }
    return items;
  }

  // ── Header Component ───────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        children: [
          _circleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          Hero(
            tag: 'app_logo',
            child: Image.asset(
              'assets/logo.jpg',
              height: 38,
              fit: BoxFit.contain,
            ),
          ),
          const Spacer(),
          _circleButton(
            icon: _showSearch ? Icons.close_rounded : Icons.search_rounded,
            active: _showSearch,
            onTap: () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchQuery = '';
                _searchController.clear();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap, bool active = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: active ? _darkGreen : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: active ? Colors.white : _darkGreen),
      ),
    );
  }

  // ── Category Chip ──────────────────────────────────────────────────────
  Widget _categoryChip(String label) {
    final active = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? _darkGreen : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: active ? Colors.transparent : const Color(0xFFEAE8E4),
            width: 1,
          ),
          boxShadow: active ? [
            BoxShadow(
              color: _darkGreen.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 5),
            )
          ] : [],
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: active ? Colors.white : const Color(0xFF6A6865),
          ),
        ),
      ),
    );
  }

  // ── Item Card ─────────────────────────────────────────────────────────
  Widget _buildItemCard(MenuItem item, CartProvider cart) {
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
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image with Veg Indicator
            Stack(
              children: [
                Hero(
                  tag: 'item_${item.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      item.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 100,
                        height: 100,
                        color: const Color(0xFFF2EFEE),
                        child: const Center(
                          child: Icon(Icons.image_not_supported_outlined, color: Color(0xFFB0AEAA), size: 32),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: _vegIndicator(item.isVeg),
                ),
                if (item.tag != null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: _gold,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(12)),
                      ),
                      child: Text(
                        item.tag!,
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Georgia',
                      color: _darkGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8A8884), height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${item.price}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: _accentGreen,
                        ),
                      ),
                      _quantityControls(item, cart, qty),
                    ],
                  ),
                ],
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
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: isVeg ? Colors.green : Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: isVeg ? Colors.green : Colors.red,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _darkGreen,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Row(
            children: [
              Icon(Icons.add, color: Colors.white, size: 14),
              SizedBox(width: 4),
              Text('ADD', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: _bgCream,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFEAE8E4)),
      ),
      child: Row(
        children: [
          _stepperPart(Icons.remove, () {
            final idx = cart.items.indexWhere((e) => e.name == item.name);
            cart.decrementQuantity(idx);
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: _darkGreen)),
          ),
          _stepperPart(Icons.add, () {
            final idx = cart.items.indexWhere((e) => e.name == item.name);
            cart.incrementQuantity(idx);
          }),
        ],
      ),
    );
  }

  Widget _stepperPart(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: 14, color: _darkGreen),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = _visibleItems;

    return Scaffold(
      backgroundColor: _bgCream,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            
            // ── Search Bar ──────────────────────────────────────────────────
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search for flavors...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

            // ── Categories ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  itemBuilder: (ctx, i) => _categoryChip(_categories[i]),
                ),
              ),
            ),

            // ── Menu Items ──────────────────────────────────────────────────
            Expanded(
              child: items.isEmpty 
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant_rounded, size: 64, color: Colors.black.withValues(alpha: 0.1)),
                    const SizedBox(height: 16),
                    const Text('No items found in this category.', style: TextStyle(color: Color(0xFF6A6865))),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  itemCount: items.length,
                  itemBuilder: (ctx, i) => _buildItemCard(items[i], cart),
                ),
            ),
          ],
        ),
      ),
      
      // ── Cart Bottom Sheet ─────────────────────────────────────────────
      bottomSheet: cart.totalItems > 0 
        ? Container(
            padding: const EdgeInsets.fromLTRB(25, 12, 25, 25),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen())),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _darkGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
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
                    const Text('VIEW CART', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                    const Icon(Icons.arrow_right_alt_rounded, color: Colors.white),
                  ],
                ),
              ),
            ),
          )
        : null,

      bottomNavigationBar: const CustomBottomNavBar(activeIndex: 1),
    );
  }
}
