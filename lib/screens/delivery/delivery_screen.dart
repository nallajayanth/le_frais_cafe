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

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  static const Color _darkGreen = Color(0xFF1E3D2A);
  static const Color _accentGreen = Color(0xFF2D8653);
  static const Color _bgCream = Color(0xFFFDFCF9);
  static const Color _gold = Color(0xFFC77A1A);

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final featuredItem = MenuData.getAllItems().first;
    final dailySpecialities = MenuData.getAllItems().skip(1).take(4).toList();

    return Scaffold(
      backgroundColor: _bgCream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(cart),
              _buildLocationBanner(),
              _buildHeroSection(featuredItem),
              _buildSectionHeader('Daily Specialities'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: dailySpecialities.map((item) => _buildSpecialityCard(item, cart)).toList(),
                ),
              ),
              const SizedBox(height: 100), // Space for bottom sheet
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          Column(
            children: [
              Hero(
                tag: 'app_logo',
                child: Image.asset(
                  'assets/logo.jpg',
                  height: 38,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _accentGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'DELIVERY MODE',
                  style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          _circleButton(
            icon: Icons.shopping_cart_outlined,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EFE8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.location_on_rounded, size: 16, color: _accentGreen),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Delivering to: Current Location',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _darkGreen),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: _darkGreen),
        ],
      ),
    );
  }

  Widget _buildHeroSection(MenuItem item) {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        image: DecorationImage(
          image: NetworkImage(item.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(10)),
              child: const Text('FEATURED NOW', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Georgia'),
            ),
            const Text(
              'Order now for 20% off on your first delivery.',
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Georgia', color: _darkGreen)),
          const Text('View all', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _gold)),
        ],
      ),
    );
  }

  Widget _buildSpecialityCard(MenuItem item, CartProvider cart) {
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    item.imageUrl, 
                    width: 90, 
                    height: 90, 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 90,
                      height: 90,
                      color: const Color(0xFFF2EFE8),
                      child: const Center(
                        child: Icon(Icons.fastfood_rounded, color: Color(0xFFC77A1A), size: 32),
                      ),
                    ),
                  ),
                ),
                Positioned(top: 8, left: 8, child: _vegIndicator(item.isVeg)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Georgia', color: _darkGreen)),
                  const SizedBox(height: 4),
                  Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Color(0xFF8A8884), height: 1.3)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹${item.price}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _accentGreen)),
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
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: isVeg ? Colors.green : Colors.red, width: 1.5), borderRadius: BorderRadius.circular(3)),
      child: Container(width: 6, height: 6, decoration: BoxDecoration(color: isVeg ? Colors.green : Colors.red, shape: BoxShape.circle)),
    );
  }

  Widget _quantityControls(MenuItem item, CartProvider cart, int qty) {
    if (qty == 0) {
      return GestureDetector(
        onTap: () => cart.addItem(CartEntry(name: item.name, price: item.price, imageUrl: item.imageUrl, qty: 1)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: _darkGreen, borderRadius: BorderRadius.circular(15)),
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(color: _bgCream, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFEAE8E4))),
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
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: _darkGreen)),
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

  Widget _buildCartBanner(CartProvider cart) {
    return Container(
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
}
