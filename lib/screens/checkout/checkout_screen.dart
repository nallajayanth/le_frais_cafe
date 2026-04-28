import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart_entry.dart';
import '../../providers/order_provider.dart';
import '../../services/api/order_service.dart';
import '../order/payment_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartEntry> items;
  final OrderMode orderMode;
  final double subtotal;
  final double gst;
  final double serviceCharge;
  final double loyaltyDiscount;
  final double total;

  const CheckoutScreen({
    super.key,
    required this.items,
    required this.orderMode,
    required this.subtotal,
    required this.gst,
    required this.serviceCharge,
    required this.loyaltyDiscount,
    required this.total,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

enum PaymentMethod { upi, card, netbanking, cash }

class _CheckoutScreenState extends State<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  PaymentMethod _selectedPayment = PaymentMethod.upi;
  bool _loyaltyApplied = true;
  late AnimationController _ctaController;
  late Animation<double> _ctaScale;

  static const Color _darkGreen = Color(0xFF0F2A1A);
  static const Color _accentGreen = Color(0xFF1E5C3A);
  static const Color _gold = Color(0xFFC88B1A);
  static const Color _bgCream = Color(0xFFF4F2EC);

  @override
  void initState() {
    super.initState();
    _ctaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _ctaScale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _ctaController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctaController.dispose();
    super.dispose();
  }

  ({
    IconData icon,
    String title,
    String subtitle,
    String statusLabel,
    Color iconBg,
  })
  _modeInfo() {
    switch (widget.orderMode) {
      case OrderMode.dineIn:
        return (
          icon: Icons.restaurant_rounded,
          title: 'Table 12 — Window View',
          subtitle: 'Le Frais · Downtown Atelier',
          statusLabel: 'IMMEDIATE SERVICE',
          iconBg: const Color(0xFFE9F5EC),
        );
      case OrderMode.pickup:
        return (
          icon: Icons.shopping_bag_outlined,
          title: 'Store Pickup',
          subtitle: 'Le Frais · Downtown Atelier',
          statusLabel: 'READY IN ~10 MIN',
          iconBg: const Color(0xFFFFF8E1),
        );
      case OrderMode.delivery:
        return (
          icon: Icons.delivery_dining_rounded,
          title: 'Home Delivery',
          subtitle: '123 Avenue des Champs-Élysées',
          statusLabel: 'ASAP · ~30 MIN',
          iconBg: const Color(0xFFEDF2FF),
        );
    }
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, top: 28),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Color(0xFF9A9690),
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 1, color: const Color(0xFFE8E6E0))),
        ],
      ),
    );
  }

  Widget _buildServiceCard() {
    final info = _modeInfo();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: info.iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(info.icon, color: _accentGreen, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Georgia',
                    color: Color(0xFF1C1A17),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  info.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A8884),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F5EC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_filled_rounded,
                        size: 11,
                        color: Color(0xFF2D8653),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        info.statusLabel,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2D8653),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.edit_outlined, size: 16, color: Color(0xFFAFADAA)),
        ],
      ),
    );
  }

  Widget _buildPaymentTile({
    required PaymentMethod value,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBg,
    required Color iconColor,
  }) {
    final bool isSelected = _selectedPayment == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _accentGreen : Colors.transparent,
            width: isSelected ? 1.5 : 0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _accentGreen.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
              spreadRadius: isSelected ? 0 : -2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE9F5EC) : iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected ? _accentGreen : iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? _darkGreen : const Color(0xFF2B2A28),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8A8884),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _accentGreen : Colors.transparent,
                border: Border.all(
                  color: isSelected ? _accentGreen : const Color(0xFFD0CEC9),
                  width: isSelected ? 0 : 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 13,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2A1A), Color(0xFF1A4030)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2A1A).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          // Items
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              children: widget.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${item.qty}x',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Text(
                        '₹${(item.price * item.qty).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Divider(
              color: Colors.white.withValues(alpha: 0.1),
              height: 1,
            ),
          ),

          // Bill details
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              children: [
                _billRow('Subtotal', '₹${widget.subtotal.toStringAsFixed(0)}'),
                const SizedBox(height: 8),
                _billRow(
                  'Taxes & Charges',
                  '₹${(widget.gst + widget.serviceCharge).toStringAsFixed(0)}',
                ),
                if (widget.loyaltyDiscount > 0 && _loyaltyApplied) ...[
                  const SizedBox(height: 8),
                  _billRow(
                    'Loyalty Discount',
                    '-₹${widget.loyaltyDiscount.toStringAsFixed(0)}',
                    isDiscount: true,
                  ),
                ],
              ],
            ),
          ),

          // Total
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Georgia',
                    color: Colors.white,
                  ),
                ),
                Text(
                  '₹${(_loyaltyApplied ? widget.total : widget.total + widget.loyaltyDiscount).toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFC88B1A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _billRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white60,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDiscount ? const Color(0xFF8FCF8F) : Colors.white60,
          ),
        ),
      ],
    );
  }

  String _getOrderTypeString(OrderMode mode) {
    switch (mode) {
      case OrderMode.dineIn:
        return 'Dine In';
      case OrderMode.pickup:
        return 'Pickup';
      case OrderMode.delivery:
        return 'Delivery';
    }
  }

  Widget _buildLoyaltyBanner() {
    return GestureDetector(
      onTap: () => setState(() => _loyaltyApplied = !_loyaltyApplied),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _loyaltyApplied ? const Color(0xFFFFF8E1) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _loyaltyApplied
                ? const Color(0xFFF5C842).withValues(alpha: 0.5)
                : const Color(0xFFE8E6E0),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _loyaltyApplied
                    ? const Color(0xFFF5C842).withValues(alpha: 0.2)
                    : const Color(0xFFF0EFEB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.card_giftcard_rounded,
                size: 20,
                color: _loyaltyApplied
                    ? const Color(0xFF8B5A00)
                    : const Color(0xFF9A9690),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _loyaltyApplied
                        ? 'Loyalty discount applied!'
                        : 'Use your 2,400 pts',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _loyaltyApplied
                          ? const Color(0xFF4A3000)
                          : const Color(0xFF1C1A17),
                    ),
                  ),
                  Text(
                    _loyaltyApplied
                        ? 'Saving ₹${widget.loyaltyDiscount.toStringAsFixed(0)} on this order'
                        : 'Tap to redeem for ₹${widget.loyaltyDiscount.toStringAsFixed(0)} off',
                    style: TextStyle(
                      fontSize: 11,
                      color: _loyaltyApplied
                          ? const Color(0xFF9A7020)
                          : const Color(0xFF8A8884),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 26,
              decoration: BoxDecoration(
                color: _loyaltyApplied
                    ? const Color(0xFFC88B1A)
                    : const Color(0xFFE0DDD8),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Align(
                alignment: _loyaltyApplied
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(3),
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgCream,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
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
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Color(0xFF1C1A17),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F2A1A),
                        ),
                      ),
                      const Text(
                        'Almost there!',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8A8884),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _darkGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _darkGreen.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        'https://i.pravatar.cc/150?img=5',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('SERVICE DETAILS'),
                    _buildServiceCard(),

                    _sectionLabel('PAYMENT METHOD'),
                    _buildPaymentTile(
                      value: PaymentMethod.upi,
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'UPI',
                      subtitle: 'GPay, PhonePe, Paytm',
                      iconBg: const Color(0xFFF0F0FD),
                      iconColor: const Color(0xFF5B6AF0),
                    ),
                    _buildPaymentTile(
                      value: PaymentMethod.card,
                      icon: Icons.credit_card_rounded,
                      title: 'Credit / Debit Card',
                      subtitle: 'Visa, Mastercard, Amex',
                      iconBg: const Color(0xFFFFF0F6),
                      iconColor: const Color(0xFFE64980),
                    ),
                    _buildPaymentTile(
                      value: PaymentMethod.netbanking,
                      icon: Icons.account_balance_rounded,
                      title: 'Net Banking',
                      subtitle: 'All major Indian banks',
                      iconBg: const Color(0xFFF0F9FF),
                      iconColor: const Color(0xFF0EA5E9),
                    ),
                    _buildPaymentTile(
                      value: PaymentMethod.cash,
                      icon: Icons.payments_rounded,
                      title: 'Cash on Delivery',
                      subtitle: 'Pay when you receive',
                      iconBg: const Color(0xFFF0FDF4),
                      iconColor: const Color(0xFF22C55E),
                    ),

                    if (widget.loyaltyDiscount > 0) ...[
                      _sectionLabel('REWARDS'),
                      _buildLoyaltyBanner(),
                    ],

                    _sectionLabel('ORDER SUMMARY'),
                    _buildOrderSummary(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // CTA
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                MediaQuery.of(context).padding.bottom + 14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTapDown: (_) => _ctaController.forward(),
                    onTapUp: (_) async {
                      _ctaController.reverse();
                      
                      // Create order on backend
                      try {
                        final orderProvider = context.read<OrderProvider>();
                        
                        // Prepare order items using OrderItem class
                        final orderItems = widget.items
                            .map((item) => OrderItem(
                              itemId: item.name.hashCode.toString(),
                              name: item.name,
                              quantity: item.qty,
                              price: item.price,
                            ))
                            .toList();

                        // Create order (returns orderId or null)
                        final orderId = await orderProvider.createOrder(
                          items: orderItems,
                          orderType: _getOrderTypeString(widget.orderMode),
                          specialInstructions: '',
                        );

                        if (orderId != null && mounted) {
                          // Navigate to payment success screen
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => PaymentSuccessScreen(
                                orderId: orderId,
                              ),
                            ),
                          );
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed: ${orderProvider.error}')),
                            );
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    onTapCancel: () => _ctaController.reverse(),
                    child: ScaleTransition(
                      scale: _ctaScale,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F2A1A), Color(0xFF1E5C3A)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _darkGreen.withValues(alpha: 0.45),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.lock_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Place Order & Pay',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _gold,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '₹${(_loyaltyApplied ? widget.total : widget.total + widget.loyaltyDiscount).toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 11,
                        color: Color(0xFFAFADAA),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'SECURE ENCRYPTED PAYMENT BY LE FRAIS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFAFADAA),
                          letterSpacing: 1.0,
                        ),
                      ),
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
}
