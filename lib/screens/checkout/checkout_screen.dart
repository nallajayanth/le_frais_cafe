import 'package:flutter/material.dart';
import '../../models/cart_entry.dart';
import '../order/order_success_screen.dart';

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

enum PaymentMethod { upi, card, netbanking }

class _CheckoutScreenState extends State<CheckoutScreen> {
  PaymentMethod _selectedPayment = PaymentMethod.upi;

  static const Color _bgCream = Color(0xFFF9F8F5);
  static const Color _darkGreen = Color(0xFF1A3B2B);
  static const Color _textGrey = Color(0xFF6B6A66);
  static const Color _headerLightGreen = Color(0xFF90A597);

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 24),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _headerLightGreen,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildServiceDetails() {
    IconData icon;
    String title;
    String subtitle;
    String statusLabel;

    switch (widget.orderMode) {
      case OrderMode.dineIn:
        icon = Icons.restaurant_rounded;
        title = 'Table 12, Window View';
        subtitle = 'Le Frais – Downtown Atelier';
        statusLabel = 'IMMEDIATE SERVICE';
        break;
      case OrderMode.pickup:
        icon = Icons.shopping_bag_outlined;
        title = 'Store Pickup';
        subtitle = 'Le Frais – Downtown Atelier';
        statusLabel = 'READY IN 10 MIN';
        break;
      case OrderMode.delivery:
        icon = Icons.delivery_dining_rounded;
        title = 'Home Delivery';
        subtitle = '123 Avenue des Champs-Élysées';
        statusLabel = 'ASAP (~30 MIN)';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFE6E8E3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _darkGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Georgia',
                    color: _darkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _textGrey,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 12, color: Color(0xFF9E7745)),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9E7745),
                        letterSpacing: 0.5,
                      ),
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

  Widget _buildPaymentOption({
    required PaymentMethod value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final bool isSelected = _selectedPayment == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFEFEFEA),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _darkGreen, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2B2A28),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _textGrey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _darkGreen : const Color(0xFFD4D2CD),
                  width: isSelected ? 6 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F1EC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Items
          ...widget.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.name} (x${item.qty})',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4A4946),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '₹${(item.price * item.qty).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2B2A28),
                      fontFamily: 'Courier', // monospace for exact look
                    ),
                  ),
                ],
              ),
            );
          }),
          
          if (widget.subtotal > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Taxes & Charges',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4A4946),
                    ),
                  ),
                  Text(
                    '₹${(widget.gst + widget.serviceCharge).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2B2A28),
                      fontFamily: 'Courier',
                    ),
                  ),
                ],
              ),
            ),

          if (widget.loyaltyDiscount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Loyalty Discount',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4A4946),
                    ),
                  ),
                  Text(
                    '-₹${widget.loyaltyDiscount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D8653),
                      fontFamily: 'Courier',
                    ),
                  ),
                ],
              ),
            ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(color: Color(0xFFE2E0D8), height: 1),
          ),
          
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Georgia',
                    color: _darkGreen,
                  ),
                ),
                Text(
                  '₹${widget.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _darkGreen,
                  ),
                ),
              ],
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
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back_rounded,
                        size: 24, color: _darkGreen),
                  ),
                  const Text(
                    'Checkout',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.w900,
                      color: _darkGreen,
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1F2926),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),

            // ── Scrollable content ──────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('SERVICE DETAILS'),
                    _buildServiceDetails(),
                    
                    _buildSectionHeader('PAYMENT METHOD'),
                    _buildPaymentOption(
                      value: PaymentMethod.upi,
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'Unified Payments Interface (UPI)',
                      subtitle: 'GPay, PhonePe, Paytm',
                    ),
                    _buildPaymentOption(
                      value: PaymentMethod.card,
                      icon: Icons.credit_card_rounded,
                      title: 'Credit / Debit Card',
                      subtitle: 'Visa, Mastercard, Amex',
                    ),
                    _buildPaymentOption(
                      value: PaymentMethod.netbanking,
                      icon: Icons.account_balance_rounded,
                      title: 'Net Banking',
                      subtitle: 'All major Indian banks',
                    ),

                    _buildSectionHeader('ORDER SUMMARY'),
                    _buildOrderSummary(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Bottom Pay Button ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              decoration: BoxDecoration(
                color: _bgCream,
                boxShadow: [
                  BoxShadow(
                    color: _bgCream.withValues(alpha: 0.8),
                    blurRadius: 10,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Place order action
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const OrderSuccessScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF285C42), // slightly lighter dark green
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline_rounded,
                              color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Place Order & Pay',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'SECURE ENCRYPTED PAYMENT BY LE FRAIS',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFA1A09B),
                      letterSpacing: 1.0,
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
}
