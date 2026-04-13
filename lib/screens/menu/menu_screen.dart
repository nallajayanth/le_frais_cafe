import 'package:flutter/material.dart';
import '../shared/item_detail_screen.dart';
import '../cart/cart_screen.dart';
import '../../models/app_cart.dart';
import '../../models/cart_entry.dart';
import '../../models/menu_item.dart';
import '../order/order_history_screen.dart';
import '../profile/profile_screen.dart';

// ── Data Models ────────────────────────────────────────────────────────────────

enum _TagType { houseMix, v60, organic, bestseller, vegetarian, superfood, newItem, outOfStock }

class _MenuItem {
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final _TagType? tag;
  final bool outOfStock;
  final double? rating;

  const _MenuItem({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.tag,
    this.outOfStock = false,
    this.rating,
  });
}

class _MenuCategory {
  final String name;
  final IconData icon;
  final List<_MenuItem> items;

  const _MenuCategory({
    required this.name,
    required this.icon,
    required this.items,
  });
}

// ── Menu Data ─────────────────────────────────────────────────────────────────

final List<_MenuCategory> _menuCategories = [
  _MenuCategory(
    name: 'Coffees',
    icon: Icons.coffee_rounded,
    items: [
      _MenuItem(
        name: 'Artisan Flat White',
        description: 'Double shot of our house-roasted espresso with silky micro-foam.',
        price: 5.50,
        imageUrl: 'https://images.unsplash.com/photo-1570968915860-54d5c301fa9f?q=80&w=600',
        tag: _TagType.houseMix,
        rating: 4.8,
      ),
      _MenuItem(
        name: 'Single Origin Pour Over',
        description: 'Roasting beans sourced from Ethiopia, slow-brewed with precision.',
        price: 7.00,
        imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?q=80&w=600',
        tag: _TagType.v60,
        rating: 4.9,
      ),
      _MenuItem(
        name: 'Cold Brew Reserve',
        description: '18-hour steeped cold brew with notes of dark chocolate & cherry.',
        price: 6.50,
        imageUrl: 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?q=80&w=600',
        tag: _TagType.newItem,
        rating: 4.7,
      ),
      _MenuItem(
        name: 'Matcha Latte',
        description: 'Ceremonial grade matcha with oat milk, lightly sweetened.',
        price: 6.00,
        imageUrl: 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?q=80&w=600',
        tag: _TagType.vegetarian,
        rating: 4.6,
      ),
    ],
  ),
  _MenuCategory(
    name: 'Pastries',
    icon: Icons.bakery_dining_rounded,
    items: [
      _MenuItem(
        name: 'Butter Croissant',
        description: 'Classic laminated dough, 72-hour fermentation, golden & flaky.',
        price: 4.50,
        imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?q=80&w=600',
        tag: _TagType.organic,
        outOfStock: true,
        rating: 4.9,
      ),
      _MenuItem(
        name: 'Pain au Chocolat',
        description: 'Flaky layers with 70% dark Valrhona chocolate folded inside.',
        price: 5.25,
        imageUrl: 'https://images.unsplash.com/photo-1530610476181-d83430b64dcd?q=80&w=600',
        tag: _TagType.bestseller,
        rating: 4.8,
      ),
      _MenuItem(
        name: 'Almond Frangipane',
        description: 'Buttery almond cream tart with seasonal berry glaze.',
        price: 6.75,
        imageUrl: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?q=80&w=600',
        tag: _TagType.newItem,
        rating: 4.7,
      ),
      _MenuItem(
        name: 'Pistachio Éclair',
        description: 'Choux pastry with pistachio cream, gold leaf and praline crunch.',
        price: 7.50,
        imageUrl: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?q=80&w=600',
        tag: _TagType.houseMix,
        rating: 4.9,
      ),
    ],
  ),
  _MenuCategory(
    name: 'Breakfast',
    icon: Icons.breakfast_dining_rounded,
    items: [
      _MenuItem(
        name: 'Sourdough Avocado Toast',
        description: 'Crushed hass avocado, poached egg, dukkah & micro herbs.',
        price: 14.00,
        imageUrl: 'https://images.unsplash.com/photo-1603048297172-c92544798d5e?q=80&w=600',
        tag: _TagType.vegetarian,
        rating: 4.7,
      ),
      _MenuItem(
        name: 'Acai Granola Bowl',
        description: 'Seasonal berries, raw honey, coconut flakes & house granola.',
        price: 12.50,
        imageUrl: 'https://images.unsplash.com/photo-1590301157890-4810ed352733?q=80&w=600',
        tag: _TagType.superfood,
        rating: 4.8,
      ),
      _MenuItem(
        name: 'Truffle Scrambled Eggs',
        description: 'Farm-fresh eggs, mascarpone, black truffle shavings on brioche.',
        price: 16.00,
        imageUrl: 'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?q=80&w=600',
        tag: _TagType.bestseller,
        rating: 4.9,
      ),
    ],
  ),
  _MenuCategory(
    name: 'Bowls',
    icon: Icons.rice_bowl_rounded,
    items: [
      _MenuItem(
        name: 'Harvest Power Bowl',
        description: 'Roasted sweet potato, farro, kale, tahini & pomegranate.',
        price: 15.90,
        imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=600',
        tag: _TagType.superfood,
        rating: 4.8,
      ),
      _MenuItem(
        name: 'Mediterranean Grain Bowl',
        description: 'Quinoa, heirloom tomatoes, kalamata olives, feta & herb oil.',
        price: 14.50,
        imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600',
        tag: _TagType.vegetarian,
        rating: 4.6,
      ),
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────

Color _tagBg(_TagType t) {
  switch (t) {
    case _TagType.houseMix:  return const Color(0xFFFFF0D6);
    case _TagType.v60:       return const Color(0xFFE8F0FE);
    case _TagType.organic:   return const Color(0xFFE8F5EE);
    case _TagType.bestseller:return const Color(0xFFFDECD4);
    case _TagType.vegetarian:return const Color(0xFFD8F3E3);
    case _TagType.superfood: return const Color(0xFFF3E8FF);
    case _TagType.newItem:   return const Color(0xFFE8F0FE);
    case _TagType.outOfStock:return const Color(0xFFF0EFEC);
  }
}

Color _tagFg(_TagType t) {
  switch (t) {
    case _TagType.houseMix:  return const Color(0xFFC88B1A);
    case _TagType.v60:       return const Color(0xFF3A6BC8);
    case _TagType.organic:   return const Color(0xFF2D8653);
    case _TagType.bestseller:return const Color(0xFFB8620A);
    case _TagType.vegetarian:return const Color(0xFF1E7A47);
    case _TagType.superfood: return const Color(0xFF7C3AED);
    case _TagType.newItem:   return const Color(0xFF3A6BC8);
    case _TagType.outOfStock:return const Color(0xFF9A9690);
  }
}

String _tagLabel(_TagType t) {
  switch (t) {
    case _TagType.houseMix:  return 'House Blend';
    case _TagType.v60:       return 'V60';
    case _TagType.organic:   return 'Organic';
    case _TagType.bestseller:return 'Bestseller';
    case _TagType.vegetarian:return 'Vegetarian';
    case _TagType.superfood: return 'Superfood';
    case _TagType.newItem:   return 'New';
    case _TagType.outOfStock:return 'Out of Stock';
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _showSearch = false;
  final Map<String, int> _cart = {};
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const Color _darkGreen = Color(0xFF1E3D2A);
  static const Color _priceGreen = Color(0xFF2D8653);
  static const Color _bgCream = Color(0xFFF5F4F0);

  @override
  void initState() {
    super.initState();
    for (final item in AppCart.items) {
      _cart[item.name] = item.qty;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int get _totalCartItems => _cart.values.fold(0, (a, b) => a + b);
  double get _totalCartPrice {
    double total = 0;
    for (final cat in _menuCategories) {
      for (final item in cat.items) {
        total += item.price * (_cart[item.name] ?? 0);
      }
    }
    return total;
  }

  List<_MenuItem> _allItems() =>
      _menuCategories.expand((c) => c.items).toList();

  List<_MenuCategory> get _visibleCategories {
    if (_selectedCategory == 'All') return _menuCategories;
    return _menuCategories
        .where((c) => c.name == _selectedCategory)
        .toList();
  }

  List<_MenuItem> get _searchResults {
    if (_searchQuery.isEmpty) return [];
    final q = _searchQuery.toLowerCase();
    return _allItems()
        .where((i) =>
            i.name.toLowerCase().contains(q) ||
            i.description.toLowerCase().contains(q))
        .toList();
  }

  // ── Tag chip ────────────────────────────────────────────────────────────
  Widget _tag(_TagType t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: _tagBg(t),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _tagLabel(t),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: _tagFg(t),
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  // ── Add/Stepper button ──────────────────────────────────────────────────
  Widget _addStepper(_MenuItem item) {
    final qty = _cart[item.name] ?? 0;
    if (item.outOfStock) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFE8E6E2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.block_rounded,
            size: 16, color: Color(0xFFAFADAA)),
      );
    }
    if (qty == 0) {
      return GestureDetector(
        onTap: () => setState(() => _cart[item.name] = 1),
        child: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: _priceGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 20),
        ),
      );
    }
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: _darkGreen,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() {
              if (qty > 1) {
                _cart[item.name] = qty - 1;
              } else {
                _cart.remove(item.name);
              }
            }),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.remove, color: Colors.white, size: 14),
            ),
          ),
          Text(
            '$qty',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _cart[item.name] = qty + 1),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.add, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ── Menu Item Row ───────────────────────────────────────────────────────
  Widget _buildItemRow(_MenuItem item) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ItemDetailScreen(
            name: item.name,
            description: item.description,
            price: item.price,
            imageUrl: item.imageUrl,
            tag: item.tag != null ? _tagLabel(item.tag!) : null,
            rating: item.rating,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.outOfStock
              ? const Color(0xFFF5F4F0)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: item.outOfStock
                ? const Color(0xFFE4E2DE)
                : Colors.transparent,
          ),
          boxShadow: item.outOfStock
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: ColorFiltered(
                    colorFilter: item.outOfStock
                        ? const ColorFilter.matrix([
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0,      0,      0,      1, 0,
                          ])
                        : const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.multiply,
                          ),
                    child: Image.network(
                      item.imageUrl,
                      width: 78,
                      height: 78,
                      fit: BoxFit.cover,
                      loadingBuilder: (ctx, child, progress) =>
                          progress == null
                              ? child
                              : Container(
                                  width: 78,
                                  height: 78,
                                  color: const Color(0xFFEFEEEA),
                                ),
                      errorBuilder: (ctx, error, stackTrace) => Container(
                        width: 78,
                        height: 78,
                        color: const Color(0xFFEFEEEA),
                        child: const Icon(
                          Icons.image_not_supported_rounded,
                          color: Color(0xFFCECCC8),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                if (item.outOfStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Center(
                        child: Text(
                          'OUT OF\nSTOCK',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF9A9690),
                            letterSpacing: 0.5,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: item.outOfStock
                          ? const Color(0xFFAFADAA)
                          : const Color(0xFF1C1A17),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: item.outOfStock
                          ? const Color(0xFFCECCC8)
                          : const Color(0xFF9A9690),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  if (item.tag != null) _tag(item.tag!),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Price + Add
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '₹${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: item.outOfStock
                        ? const Color(0xFFAFADAA)
                        : _priceGreen,
                    decoration: item.outOfStock
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                _addStepper(item),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Category section ────────────────────────────────────────────────────
  Widget _buildCategorySection(_MenuCategory cat) {
    final itemsToShow = cat.items;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 0, 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _darkGreen.withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
                child: Icon(cat.icon, color: _darkGreen, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                cat.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF1C1A17),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAE8E4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${itemsToShow.length} ITEMS',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6A6865),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...itemsToShow.map(_buildItemRow),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Search result item ──────────────────────────────────────────────────
  Widget _buildSearchResults() {
    final results = _searchResults;
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            children: [
              Icon(Icons.search_off_rounded,
                  size: 48,
                  color: Colors.black.withValues(alpha: 0.15)),
              const SizedBox(height: 12),
              Text(
                'No items found for "$_searchQuery"',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9A9690),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            '${results.length} result${results.length == 1 ? '' : 's'} for "$_searchQuery"',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6A6865),
            ),
          ),
        ),
        ...results.map(_buildItemRow),
      ],
    );
  }

  // ── Bottom nav item ─────────────────────────────────────────────────────
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
                color: _darkGreen,
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
              color:
                  active ? _darkGreen : const Color(0xFFB0AEAA),
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
      backgroundColor: _bgCream,
      body: Column(
        children: [
          // ── Sticky header ─────────────────────────────────────────────
          Container(
            color: _bgCream,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App bar row
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: 0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 16,
                                color: Color(0xFF1C1A17)),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Le Frais',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Georgia',
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E3D2A),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _showSearch = !_showSearch),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: _showSearch
                                      ? _darkGreen
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.06),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.search_rounded,
                                    size: 18,
                                    color: _showSearch
                                        ? Colors.white
                                        : const Color(0xFF1C1A17)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    final entries = _allItems()
                                        .where((item) =>
                                            (_cart[item.name] ?? 0) > 0)
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
                                        settings: const RouteSettings(
                                            name: '/cart'),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.06),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                        Icons.shopping_cart_outlined,
                                        size: 18,
                                        color: Color(0xFF1C1A17)),
                                  ),
                                ),
                                if (_totalCartItems > 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: const BoxDecoration(
                                        color: _priceGreen,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$_totalCartItems',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                          ),
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

                  // Title + description
                  if (!_showSearch) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Text(
                        'Our Menu',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Georgia',
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF1E3D2A),
                          height: 1.1,
                        ),
                      ),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.fromLTRB(20, 6, 20, 0),
                      child: Text(
                        'Curated with artisan precision, our menu features house-roasted beans and daily small-batch bakes from our workshop.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6A6865),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          onChanged: (v) =>
                              setState(() => _searchQuery = v),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1C1A17),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search menu items...',
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFB0AEAA),
                            ),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: Color(0xFFB0AEAA), size: 20),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      setState(
                                          () => _searchQuery = '');
                                    },
                                    child: const Icon(Icons.close_rounded,
                                        color: Color(0xFFB0AEAA),
                                        size: 18),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 14),
                          ),
                        ),
                      ),
                    ),

                  // Category chips
                  if (!_showSearch || _searchQuery.isEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 38,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          'All',
                          ..._menuCategories.map((c) => c.name)
                        ]
                            .map((cat) => _categoryChip(cat))
                            .toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // ── Scrollable content ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              child: _showSearch && _searchQuery.isNotEmpty
                  ? _buildSearchResults()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _visibleCategories
                          .map(_buildCategorySection)
                          .toList(),
                    ),
            ),
          ),
        ],
      ),

      // ── Cart Banner ───────────────────────────────────────────────────
      bottomSheet: _totalCartItems > 0
          ? GestureDetector(
              onTap: () {
                final entries = _allItems()
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
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: _darkGreen,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _darkGreen.withValues(alpha: 0.4),
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

      // ── Bottom Navigation ─────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navItem(Icons.home_outlined, 'HOME', false,
                  onTap: () => Navigator.of(context).popUntil(
                      (r) => r.settings.name == '/home' || r.isFirst)),
              _navItem(
                  Icons.restaurant_menu_rounded, 'MENU', true),
              _navItem(Icons.receipt_long_outlined, 'ORDERS', false,
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
              _navItem(
                Icons.shopping_cart_rounded,
                'CART',
                false,
                onTap: () {
                  final entries = _allItems()
                      .where(
                          (item) => (_cart[item.name] ?? 0) > 0)
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
                  onTap: () {
                    Navigator.of(context).popUntil(
                        (r) => r.settings.name == '/home' || r.isFirst);
                    Future.microtask(() => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                            settings: const RouteSettings(name: '/profile'),
                          ),
                        ));
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(String label) {
    final active = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? _darkGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _darkGreen.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? Colors.white : const Color(0xFF6A6865),
          ),
        ),
      ),
    );
  }
}
