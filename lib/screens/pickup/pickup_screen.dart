import 'package:flutter/material.dart';
import '../shared/item_detail_screen.dart';
import '../cart/cart_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_entry.dart';
import '../../models/menu_item.dart';
import '../../data/menu_data.dart';
import '../shared/custom_bottom_nav_bar.dart';

class PickupScreen extends StatefulWidget {
  const PickupScreen({super.key});

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  String _selectedCategory = 'All';

  static const Color _darkGreen = Color(0xFF0F2A1A);
  static const Color _accentGreen = Color(0xFF1E5C3A);
  static const Color _lightGreen = Color(0xFF2D8653);
  static const Color _bgCream = Color(0xFFF4F2EC);
  static const Color _gold = Color(0xFFC88B1A);

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
    return MenuData.getAllItems()
        .where((item) => item.category == _selectedCategory)
        .toList();
  }

  Widget _buildHeader(CartProvider cart) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C1A00), Color(0xFF4A3000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C1A00).withValues(alpha: 0.4),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _gold.withValues(alpha: 0.5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 10, color: Color(0xFFF5C842)),
                    SizedBox(width: 4),
                    Text(
                      'PICKUP MODE',
                      style: TextStyle(
                        color: Color(0xFFF5C842),
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
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
                        border: Border.all(color: const Color(0xFF2C1A00), width: 2),
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
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, 6),
              spreadRadius: -2,
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
                    tag: 'item_pickup_${item.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
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
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(14)),
                        ),
                        child: Text(
                          item.tag!.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 7,
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
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
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
                      style: const TextStyle(fontSize: 10, color: Color(0xFF8A8884), height: 1.3),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 11, color: _gold),
                        const SizedBox(width: 2),
                        Text(
                          '${item.rating}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF6A6865)),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${item.price.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: _lightGreen),
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Container(
        width: 6,
        height: 6,
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
        onTap: () => cart.addItem(
          CartEntry(name: item.name, price: item.price, imageUrl: item.imageUrl, qty: 1),
        ),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_darkGreen, _accentGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: _accentGreen.withValues(alpha: 0.35),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 16),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EFEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0DDD8)),
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
              padding: EdgeInsets.all(4),
              child: Icon(Icons.remove_rounded, size: 12, color: _accentGreen),
            ),
          ),
          Text(
            '$qty',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: _darkGreen),
          ),
          GestureDetector(
            onTap: () {
              final idx = cart.findFirstIndexByName(item.name);
              cart.incrementQuantity(idx);
            },
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.add_rounded, size: 12, color: _accentGreen),
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

            // Pickup Info Banner
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF5C842).withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5C842).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF8B5A00)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'ESTIMATED PICKUP TIME',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9A7020),
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Ready in ~20 minutes',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF3D2B00),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.store_rounded, size: 20, color: Color(0xFFC88B1A)),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Category Scroll
            SizedBox(
              height: 40,
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
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: active
                            ? const LinearGradient(
                                colors: [Color(0xFF2C1A00), Color(0xFF4A3000)],
                              )
                            : null,
                        color: active ? null : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active ? Colors.transparent : const Color(0xFFE0DDD8),
                          width: 1.5,
                        ),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF2C1A00).withValues(alpha: 0.3),
                                  blurRadius: 8,
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
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Item Grid
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_menu_rounded, size: 64, color: Colors.black.withValues(alpha: 0.1)),
                          const SizedBox(height: 12),
                          const Text('No items in this category.', style: TextStyle(color: Color(0xFF6A6865))),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.62,
                      ),
                      itemCount: items.length,
                      itemBuilder: (ctx, i) => _buildGridCard(items[i], cart),
                    ),
            ),
          ],
        ),
      ),

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
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2C1A00), Color(0xFF4A3000)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2C1A00).withValues(alpha: 0.4),
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
                          color: _gold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'CHECKOUT',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
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

      bottomNavigationBar: const CustomBottomNavBar(activeIndex: 0),
    );
  }
}
