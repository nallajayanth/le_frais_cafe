import 'package:flutter/material.dart';
import '../shared/item_detail_screen.dart';
import '../cart/cart_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/menu_provider.dart';
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
  // null = "All" selected
  String? _selectedCategoryId;
  String _searchQuery = '';
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const Color _darkGreen = Color(0xFF0F2A1A);
  static const Color _accentGreen = Color(0xFF1E5C3A);
  static const Color _lightGreen = Color(0xFF2D8653);
  static const Color _bgCream = Color(0xFFF4F2EC);
  static const Color _gold = Color(0xFFC88B1A);

  @override
  void initState() {
    super.initState();
    // Load menu items from backend when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().loadMenuItems();
      context.read<MenuProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<MenuItem> get _allItems {
    final provider = context.read<MenuProvider>();
    final items = provider.menuItems;
    return items.isEmpty 
        ? MenuData.getAllItems() 
        : List<MenuItem>.from(items);
  }

  // Returns (filterId, displayName) — filterId null = All
  List<(String?, String)> get _categories {
    final provider = context.read<MenuProvider>();
    if (provider.categories.isEmpty) {
      const fallback = ['Appetizers', 'Chinese Starters', 'Momos', 'Burgers', 'Noodles', 'Rice'];
      return [(null, 'All'), ...fallback.map((n) => (n, n))];
    }
    return [(null, 'All'), ...provider.categories.map((c) => (c.id, c.name))];
  }

  List<MenuItem> get _visibleItems {
    List<MenuItem> items;
    if (_selectedCategoryId == null) {
      items = _allItems;
    } else {
      items = _allItems.where((i) => i.category == _selectedCategoryId).toList();
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
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(18),
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
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
            ),
          ),
          const Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/logo.jpg', height: 28, fit: BoxFit.contain),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _gold.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  'FULL MENU',
                  style: TextStyle(color: Color(0xFFC88B1A), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchQuery = '';
                _searchController.clear();
              }
            }),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _showSearch
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                _showSearch ? Icons.close_rounded : Icons.search_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
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
  Widget _categoryChip((String?, String) option) {
    final (filterId, label) = option;
    final active = filterId == _selectedCategoryId;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedCategoryId = filterId;
        if (filterId != null) {
          _searchQuery = '';
          _searchController.clear();
          _showSearch = false;
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [Color(0xFF0F2A1A), Color(0xFF1E5C3A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: active ? null : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: active ? Colors.transparent : const Color(0xFFE0DDD8),
            width: 1.5,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F2A1A).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : const Color(0xFF6A6865),
          ),
        ),
      ),
    );
  }

  // ── Item Card ─────────────────────────────────────────────────────────
  Widget _buildItemCard(MenuItem item, CartProvider cart) {
    final qty = cart.getItemQuantity(item.name);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ItemDetailScreen(
            menuItemId: item.id,
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
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            // Image with Veg Indicator
            Stack(
              children: [
                Hero(
                  tag: 'item_${item.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      item.imageUrl,
                      width: 108,
                      height: 108,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 108,
                        height: 108,
                        color: const Color(0xFFF2EFEE),
                        child: const Center(
                          child: Icon(Icons.image_not_supported_outlined, color: Color(0xFFB0AEAA), size: 32),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(top: 8, left: 8, child: _vegIndicator(item.isVeg)),
                if (item.tag != null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: _gold,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomRight: Radius.circular(18)),
                      ),
                      child: Text(
                        item.tag!.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Georgia',
                      color: _darkGreen,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF8A8884), height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 12, color: Color(0xFFC88B1A)),
                      const SizedBox(width: 3),
                      Text(
                        '${item.rating}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF6A6865)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${item.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
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
            final idx = cart.findFirstIndexByName(item.name);
            cart.decrementQuantity(idx);
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: _darkGreen)),
          ),
          _stepperPart(Icons.add, () {
            final idx = cart.findFirstIndexByName(item.name);
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
    context.watch<MenuProvider>(); // triggers rebuild when menu items / categories load
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
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (v) => setState(() {
                      _searchQuery = v;
                      if (v.isNotEmpty) _selectedCategoryId = null;
                    }),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1C1A17),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search menu items...',
                      hintStyle: const TextStyle(
                        color: Color(0xFFB0AEAA),
                        fontSize: 14,
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 14, right: 8),
                        child: Icon(Icons.search_rounded,
                            size: 20, color: Color(0xFF1E5C3A)),
                      ),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 44, minHeight: 44),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () => setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                              }),
                              child: const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(Icons.close_rounded,
                                    size: 18, color: Color(0xFF9A9690)),
                              ),
                            )
                          : null,
                      suffixIconConstraints:
                          const BoxConstraints(minWidth: 40, minHeight: 40),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                            color: Color(0xFF1E5C3A), width: 1.5),
                      ),
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
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.restaurant_rounded,
                            size: 34, color: Color(0xFFCECCC8)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'No results for "$_searchQuery"'
                            : 'Nothing here yet',
                        style: const TextStyle(
                          fontSize: 15,
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3A3835),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Try a different search term.'
                            : 'Check back soon for new additions.',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF9A9690)),
                      ),
                    ],
                  ),
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
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen())),
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
          )
        : null,

      bottomNavigationBar: const CustomBottomNavBar(activeIndex: 1),
    );
  }
}
