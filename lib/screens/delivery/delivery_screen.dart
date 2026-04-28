import 'package:flutter/material.dart';
import '../shared/item_detail_screen.dart';
import '../cart/cart_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_entry.dart';
import '../../models/menu_item.dart';
import '../../data/menu_data.dart';
import '../profile/profile_screen.dart';
import '../shared/custom_bottom_nav_bar.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen>
    with SingleTickerProviderStateMixin {
  static const Color _darkGreen = Color(0xFF0F2A1A);
  static const Color _accentGreen = Color(0xFF1E5C3A);
  static const Color _lightGreen = Color(0xFF2D8653);
  static const Color _gold = Color(0xFFC88B1A);
  static const Color _bgCream = Color(0xFFF4F2EC);

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final featuredItem = MenuData.getAllItems().first;
    final dailySpecialities = MenuData.getAllItems().skip(1).take(4).toList();

    return Scaffold(
      backgroundColor: _bgCream,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              _buildHeader(cart),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildLocationBanner(),
                      const SizedBox(height: 14),
                      _buildHeroSection(featuredItem),
                      const SizedBox(height: 8),
                      _buildSectionHeader('Today\'s Specials'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: dailySpecialities.map((item) => _buildSpecialityCard(item, cart)).toList(),
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: cart.totalItems > 0 ? _buildCartBanner(cart) : null,
      bottomNavigationBar: const CustomBottomNavBar(activeIndex: 0),
    );
  }

  Widget _buildHeader(CartProvider cart) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
                  color: _gold.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _gold.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delivery_dining_rounded, size: 10, color: Color(0xFFC88B1A)),
                    SizedBox(width: 4),
                    Text(
                      'DELIVERY MODE',
                      style: TextStyle(color: Color(0xFFC88B1A), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.0),
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
                        border: Border.all(color: _darkGreen, width: 2),
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

  Widget _buildLocationBanner() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEAE8E2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFE9F5EC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.location_on_rounded, size: 18, color: _accentGreen),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'DELIVERING TO',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF9A9690),
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Current Location',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1A17),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0EC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('CHANGE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF6A6865), letterSpacing: 0.5)),
                  SizedBox(width: 3),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF6A6865)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(MenuItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        image: DecorationImage(
          image: NetworkImage(item.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_darkGreen.withValues(alpha: 0.05), _darkGreen.withValues(alpha: 0.88)],
                stops: const [0.3, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _gold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'FEATURED NOW',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Georgia',
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Free delivery on your first order today',
                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    GestureDetector(
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
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'Order Now — ₹${item.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: _darkGreen,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'Georgia',
              color: _darkGreen,
              letterSpacing: -0.3,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF3E5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'VIEW ALL',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _gold, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialityCard(MenuItem item, CartProvider cart) {
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    item.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 100,
                      color: const Color(0xFFF2EFE8),
                      child: const Center(
                        child: Icon(Icons.fastfood_rounded, color: Color(0xFFC88B1A), size: 32),
                      ),
                    ),
                  ),
                ),
                Positioned(top: 8, left: 8, child: _vegIndicator(item.isVeg)),
              ],
            ),
            const SizedBox(width: 14),
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
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF8A8884), height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 12, color: _gold),
                      const SizedBox(width: 3),
                      Text(
                        '${item.rating}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6A6865)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${item.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _lightGreen),
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
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: isVeg ? const Color(0xFF2D8653) : Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 1))],
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
        onTap: () => cart.addItem(CartEntry(name: item.name, price: item.price, imageUrl: item.imageUrl, qty: 1)),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F2A1A), Color(0xFF1E5C3A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(12),
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
              padding: EdgeInsets.all(7),
              child: Icon(Icons.remove_rounded, size: 14, color: _accentGreen),
            ),
          ),
          Text('$qty', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: _darkGreen)),
          GestureDetector(
            onTap: () {
              final idx = cart.findFirstIndexByName(item.name);
              cart.incrementQuantity(idx);
            },
            child: const Padding(
              padding: EdgeInsets.all(7),
              child: Icon(Icons.add_rounded, size: 14, color: _accentGreen),
            ),
          ),
        ],
      ),
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
                  color: _gold,
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
