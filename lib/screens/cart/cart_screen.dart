import 'package:flutter/material.dart';
import '../../models/cart_entry.dart';
import '../../models/delivery_address.dart';
import '../../services/address_service.dart';
import '../address/address_picker_sheet.dart';
import '../checkout/checkout_screen.dart';
import '../menu/menu_screen.dart';
import '../order/order_history_screen.dart';
import '../profile/profile_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../shared/custom_bottom_nav_bar.dart';

// ── "You might also like" suggestion ─────────────────────────────────────────

class _Suggestion {
  final String name;
  final double price;
  final String imageUrl;
  final bool isNew;

  const _Suggestion({
    required this.name,
    required this.price,
    required this.imageUrl,
    this.isNew = false,
  });
}

const List<_Suggestion> _suggestions = [
  _Suggestion(
    name: 'Macaron Vanille',
    price: 2.80,
    imageUrl:
        'https://images.unsplash.com/photo-1569864358642-9d1684040f43?q=80&w=400&auto=format&fit=crop',
  ),
  _Suggestion(
    name: 'Pain au Choc',
    price: 4.80,
    imageUrl:
        'https://images.unsplash.com/photo-1530610476181-d83430b64dcd?q=80&w=400&auto=format&fit=crop',
    isNew: true,
  ),
  _Suggestion(
    name: 'Éclair Noisette',
    price: 5.50,
    imageUrl:
        'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?q=80&w=400&auto=format&fit=crop',
  ),
  _Suggestion(
    name: 'Lemon Tart',
    price: 6.20,
    imageUrl:
        'https://images.unsplash.com/photo-1519915028121-7d3463d20b13?q=80&w=400&auto=format&fit=crop',
  ),
];

// ── Cart Screen ───────────────────────────────────────────────────────────────

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _useLoyalty = false;
  DeliveryAddress? _deliveryAddress; // for delivery mode

  static const Color _darkGreen = Color(0xFF0F2A1A);
  static const Color _accentGreen = Color(0xFF1E5C3A);
  static const Color _priceGreen = Color(0xFF2D8653);
  static const Color _gold = Color(0xFFC88B1A);
  static const Color _bgCream = Color(0xFFF4F2EC);

  @override
  void initState() {
    super.initState();
    // Pre-load selected delivery address if mode is delivery
    Future.microtask(() {
      final orderMode = context.read<CartProvider>().orderMode;
      if (orderMode == OrderMode.delivery) {
        setState(() {
          _deliveryAddress = AddressService().selectedAddress;
        });
      }
    });
  }

  // ── Computed subtotal ─────────────────────────────────────────────────────
  double _subtotal(CartProvider cart) => cart.subtotal;
  double _gst(CartProvider cart) => cart.subtotal * 0.05;
  static const double _serviceCharge = 1.00;
  static const double _loyaltyDiscount = 2.25;
  double _total(CartProvider cart) =>
      cart.subtotal +
      _gst(cart) +
      _serviceCharge -
      (_useLoyalty ? _loyaltyDiscount : 0);

  // ── Order mode banner data ────────────────────────────────────────────────
  ({IconData icon, String label, Color bg}) _getModeData(OrderMode mode) {
    switch (mode) {
      case OrderMode.dineIn:
        return (
          icon: Icons.table_restaurant_rounded,
          label: 'Dine-In — Table 7',
          bg: _darkGreen,
        );
      case OrderMode.pickup:
        return (
          icon: Icons.shopping_bag_outlined,
          label: 'Pickup — Ready in 10 min',
          bg: const Color(0xFF2B4C35),
        );
      case OrderMode.delivery:
        return (
          icon: Icons.delivery_dining_rounded,
          label: 'Delivery — 30–40 min',
          bg: const Color(0xFF3B3220),
        );
    }
  }

  // ── Cart item row ─────────────────────────────────────────────────────────
  Widget _buildCartItem(CartProvider cart, CartEntry entry, int index) {
    return Dismissible(
      key: Key(entry.name + index.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFECEC), Color(0xFFFFD6D6)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.delete_outline_rounded, color: Color(0xFFD44040), size: 26),
            SizedBox(height: 4),
            Text('Remove', style: TextStyle(color: Color(0xFFD44040), fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      onDismissed: (_) => cart.removeItemAt(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Item image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                entry.imageUrl,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                loadingBuilder: (ctx, child, progress) => progress == null
                    ? child
                    : Container(
                        width: 76,
                        height: 76,
                        color: const Color(0xFFEFEEEA),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _priceGreen,
                          ),
                        ),
                      ),
                errorBuilder: (ctx, err, stack) => Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EFEA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.restaurant_rounded,
                      color: Color(0xFFCECCC8), size: 28),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Name + price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1A17),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (entry.selectedOptions.isNotEmpty) ...[
                    Text(
                      entry.selectedOptions.join(', '),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8A8884),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (entry.instructions != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.edit_note_rounded, size: 14, color: Color(0xFFC77A1A)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            entry.instructions!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFFC77A1A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    '₹${entry.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _priceGreen,
                    ),
                  ),
                ],
              ),
            ),

            // Delete + stepper
            SizedBox(
              width: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => cart.removeItemAt(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: Color(0xFFCECCC8)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // − qty +
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F6F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _stepBtn(Icons.remove, () {
                          cart.decrementQuantity(index);
                        }),
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${entry.qty}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1C1A17),
                            ),
                          ),
                        ),
                        _stepBtn(Icons.add, () {
                          cart.incrementQuantity(index);
                        }),
                      ],
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

  // ── Suggestion card ───────────────────────────────────────────────────────
  Widget _buildSuggestion(CartProvider cart, _Suggestion s) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  s.imageUrl,
                  width: 110,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    width: 110,
                    height: 90,
                    color: const Color(0xFFF0EFEA),
                    child: const Icon(Icons.restaurant_rounded,
                        color: Color(0xFFCECCC8), size: 30),
                  ),
                ),
              ),
              if (s.isNew)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8A317),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () {
                    cart.addItem(CartEntry(
                      name: s.name,
                      price: s.price,
                      imageUrl: s.imageUrl,
                      qty: 1,
                    ));
                  },
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: _priceGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add,
                        color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            s.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1A17),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '₹${s.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _priceGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ── Step button ───────────────────────────────────────────────────────────
  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE8E5DF)),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 12, color: _priceGreen),
      ),
    );
  }

  // ── Summary row ───────────────────────────────────────────────────────────
  Widget _summaryRow(String label, double amount,
      {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: color ?? const Color(0xFF6A6865),
              letterSpacing: bold ? 0 : 0.3,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: color ?? const Color(0xFF1C1A17),
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary row (dark theme for bill card) ─────────────────────────────────
  Widget _summaryRowDark(String label, double amount, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white60,
            ),
          ),
          Text(
            isDiscount ? '-₹${amount.abs().toStringAsFixed(2)}' : '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDiscount ? const Color(0xFF8FCF8F) : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final mode = _getModeData(cart.orderMode);
    final totalItems = cart.totalItems;

    // ── Empty cart state ──────────────────────────────────────────────────────
    if (cart.isEmpty) {
      return Scaffold(
        backgroundColor: _bgCream,
        body: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF1C1A17)),
                      ),
                    ),
                    const Spacer(),
                    Image.asset('assets/logo.jpg', height: 32, fit: BoxFit.contain),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              // Empty state illustration
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        size: 50,
                        color: Color(0xFF1E3D2A),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF1C1A17),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Add artisan items from the menu\nto start your order.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8A8880),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 36),
                    GestureDetector(
                      onTap: () => Navigator.of(context).popUntil(
                          (r) => r.settings.name == '/home' || r.isFirst),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 36, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3D2A),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E3D2A)
                                  .withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Text(
                          'BROWSE MENU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(activeIndex: 3),
      );
    }

    return Scaffold(
      backgroundColor: _bgCream,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF1C1A17)),
                    ),
                  ),
                  Image.asset('assets/logo.jpg', height: 32, fit: BoxFit.contain),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F2A1A), Color(0xFF1E5C3A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // ── Delivery address banner (delivery mode only) ─────────────────
            if (cart.orderMode == OrderMode.delivery)
              _buildDeliveryAddressBanner(),

            // ── Scrollable body ─────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Order Mode Banner ──────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [mode.bg, Color.lerp(mode.bg, Colors.black, 0.2)!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: mode.bg.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(mode.icon, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ORDER MODE',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white60,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  mode.label,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'CHANGE',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Panier header ──────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Cart',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Georgia',
                            color: Color(0xFF1C1A17),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAE8E4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$totalItems ${totalItems == 1 ? 'Item' : 'Items'}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6A6865),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Cart items ─────────────────────────────────────────
                    if (cart.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            children: [
                              Icon(Icons.shopping_cart_outlined,
                                  size: 54,
                                  color: Colors.black.withValues(alpha: 0.15)),
                              const SizedBox(height: 12),
                              const Text(
                                'Your cart is empty',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF9A9690),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Add items from the menu to get started.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFB0AEAA),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...List.generate(
                        cart.items.length,
                        (i) => _buildCartItem(cart, cart.items[i], i),
                      ),

                    const SizedBox(height: 8),

                    // ── You might also like ────────────────────────────────
                    const Text(
                      'You might also like',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Georgia',
                        color: Color(0xFF1C1A17),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _suggestions.length,
                        itemBuilder: (_, i) =>
                            _buildSuggestion(cart, _suggestions[i]),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Loyalty points toggle ──────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF3D6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.star_rounded,
                                color: Color(0xFFE8A317), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Use 450 Loyalty Points',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1C1A17),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Save ₹${_loyaltyDiscount.toStringAsFixed(2)} on this order',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9A9690),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _useLoyalty,
                            onChanged: (v) => setState(() => _useLoyalty = v),
                            activeColor: Colors.white,
                            activeTrackColor: _priceGreen,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: const Color(0xFFEAE8E4),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Bill summary ───────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F2A1A), Color(0xFF163C25)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F2A1A).withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.receipt_long_rounded, color: Colors.white54, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'BILL SUMMARY',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white54,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _summaryRowDark('Subtotal', _subtotal(cart)),
                            _summaryRowDark('GST (5%)', _gst(cart)),
                            _summaryRowDark('Service charge', _serviceCharge),
                            if (_useLoyalty)
                              _summaryRowDark('Loyalty discount', -_loyaltyDiscount, isDiscount: true),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(color: Colors.white12, height: 1),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    fontFamily: 'Georgia',
                                  ),
                                ),
                                Text(
                                  '₹${_total(cart).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFC88B1A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Proceed to Checkout ────────────────────────────────
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB8860B), Color(0xFFDAA520), Color(0xFFC88B1A)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC88B1A).withValues(alpha: 0.45),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CheckoutScreen(
                                  items: cart.items,
                                  orderMode: cart.orderMode,
                                  subtotal: _subtotal(cart),
                                  gst: _gst(cart),
                                  serviceCharge: _serviceCharge,
                                  loyaltyDiscount:
                                      _useLoyalty ? _loyaltyDiscount : 0,
                                  total: _total(cart),
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(22),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 10),
                              const Text(
                                'Proceed to Checkout',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom Navigation ───────────────────────────────────────────
            const CustomBottomNavBar(activeIndex: 3),
          ],
        ),
      ),
    );
  }

  // ── Delivery address banner ───────────────────────────────────────────────
  Widget _buildDeliveryAddressBanner() {
    final addr = _deliveryAddress;
    final hasAddr = addr != null;

    return GestureDetector(
      onTap: _showAddressPicker,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8E5DF), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Location icon chip
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF1E5C3A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_pin,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            // Address text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        hasAddr ? 'Delivering to  ${addr.label}' : 'Add delivery address',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9A9690),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hasAddr ? addr.shortAddress : 'Tap to choose or add an address',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: hasAddr
                          ? const Color(0xFF1C1A17)
                          : const Color(0xFF9A9690),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Chevron
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F2EE),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: Color(0xFF6A6865)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Show address picker sheet ─────────────────────────────────────────────
  void _showAddressPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddressPickerSheet(
        selected: _deliveryAddress,
        onSelected: (addr) {
          setState(() => _deliveryAddress = addr);
        },
      ),
    );
  }

}
