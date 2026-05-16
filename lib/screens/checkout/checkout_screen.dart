import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart_entry.dart';
import '../../providers/order_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/delivery_provider.dart';
import '../../providers/dine_in_provider.dart';
import '../../services/api/order_service.dart';
import '../../services/api/payment_service.dart';
import '../order/payment_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartEntry> items;
  final OrderMode orderMode;
  final double subtotal;
  final double gst;
  final double serviceCharge;
  final double loyaltyDiscount;
  final double total;
  final String? tableNumber;

  const CheckoutScreen({
    super.key,
    required this.items,
    required this.orderMode,
    required this.subtotal,
    required this.gst,
    required this.serviceCharge,
    required this.loyaltyDiscount,
    required this.total,
    this.tableNumber,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

enum PaymentMethod { upi, card, netbanking, cash }

class _CheckoutScreenState extends State<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  PaymentMethod _selectedPayment = PaymentMethod.upi;
  bool _loyaltyApplied = false;
  late AnimationController _ctaController;
  late Animation<double> _ctaScale;

  final _discountCtrl = TextEditingController();
  bool _isApplyingDiscount = false;
  double _discountAmount = 0;
  String? _appliedCode;
  String? _discountError;

  bool _isPlacingOrder = false;

  static const Color _darkGreen = Color(0xFF0F2A1A);
  static const Color _accentGreen = Color(0xFF1E5C3A);
  static const Color _gold = Color(0xFFC88B1A);
  static const Color _bgCream = Color(0xFFF4F2EC);

  double get _deliveryCharge {
    final estimate = context.read<DeliveryProvider>().deliveryEstimate;
    if (widget.orderMode == OrderMode.delivery && estimate != null) {
      return estimate.deliveryCharge;
    }
    return 0;
  }

  double get _finalTotal {
    return widget.subtotal +
        widget.gst +
        widget.serviceCharge +
        _deliveryCharge -
        _discountAmount -
        (widget.loyaltyDiscount > 0 && _loyaltyApplied
            ? widget.loyaltyDiscount
            : 0);
  }

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().loadAvailableDiscounts();
    });
  }

  @override
  void dispose() {
    _ctaController.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  // Called by the backend after order creation to officially record the discount.
  Future<void> _applyDiscount(String orderId) async {
    final code = _appliedCode ?? _discountCtrl.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() => _isApplyingDiscount = true);

    final paymentProvider = context.read<PaymentProvider>();
    final ok = await paymentProvider.applyDiscount(
      orderId: orderId,
      discountCode: code,
    );

    if (!mounted) return;
    if (ok && paymentProvider.appliedDiscount != null) {
      setState(() {
        _discountAmount = paymentProvider.appliedDiscount!.discountAmount;
        _appliedCode = code;
        _discountError = null;
      });
    } else {
      setState(() {
        _discountError = paymentProvider.error ?? 'Invalid discount code';
        _discountAmount = 0;
        _appliedCode = null;
      });
    }
    setState(() => _isApplyingDiscount = false);
  }

  // Client-side validation for immediate UI feedback before order creation.
  // If discounts haven't loaded yet (e.g. Render cold start), retries once
  // and falls back to tentative acceptance so the server validates at order time.
  Future<void> _validateAndApplyCode() async {
    final code = _discountCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _discountError = 'Please enter a discount code');
      return;
    }

    setState(() {
      _isApplyingDiscount = true;
      _discountError = null;
    });

    final paymentProvider = context.read<PaymentProvider>();
    var discounts = paymentProvider.availableDiscounts;

    // Discounts not loaded yet — fetch them now (handles Render cold-start)
    if (discounts.isEmpty) {
      await paymentProvider.loadAvailableDiscounts();
      if (!mounted) return;
      discounts = paymentProvider.availableDiscounts;
    }

    // Server still unreachable: accept tentatively, server validates on placement
    if (discounts.isEmpty) {
      setState(() {
        _appliedCode = code;
        _discountAmount = 0;
        _discountError = null;
        _isApplyingDiscount = false;
      });
      return;
    }

    final discount = discounts.where((d) => d.code == code).firstOrNull;

    if (discount == null || !discount.isValid) {
      setState(() {
        _discountError = 'Invalid or expired discount code';
        _discountAmount = 0;
        _appliedCode = null;
        _isApplyingDiscount = false;
      });
      return;
    }

    if (widget.subtotal < discount.minOrderValue) {
      setState(() {
        _discountError =
            'Minimum order of ₹${discount.minOrderValue.toStringAsFixed(0)} required';
        _discountAmount = 0;
        _appliedCode = null;
        _isApplyingDiscount = false;
      });
      return;
    }

    setState(() {
      _discountAmount = discount.calculateDiscount(widget.subtotal);
      _appliedCode = code;
      _discountError = null;
      _isApplyingDiscount = false;
    });
  }

  Future<void> _placeOrder() async {
    if (_isPlacingOrder) return;
    setState(() => _isPlacingOrder = true);

    try {
      final orderProvider = context.read<OrderProvider>();
      final paymentProvider = context.read<PaymentProvider>();
      final deliveryProvider = context.read<DeliveryProvider>();
      final dineInProvider = context.read<DineInProvider>();
      final dineInTable = dineInProvider.currentTable;

      if (widget.orderMode == OrderMode.dineIn && dineInTable == null) {
        setState(() => _isPlacingOrder = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please scan your table QR code first.'),
            backgroundColor: Colors.red[700],
          ),
        );
        return;
      }

      final orderItems = widget.items
          .map(
            (item) => OrderItem(
              itemId: item.itemId ?? item.name.hashCode.abs().toString(),
              name: item.name,
              quantity: item.qty,
              price: item.price,
            ),
          )
          .toList();

      // Map payment method
      final paymentMethodStr = switch (_selectedPayment) {
        PaymentMethod.upi => 'UPI',
        PaymentMethod.card => 'CARD',
        PaymentMethod.netbanking => 'NETBANKING',
        PaymentMethod.cash => 'CASH',
      };

      final orderResult = await orderProvider.createOrder(
        orderType: _getOrderTypeString(widget.orderMode),
        items: orderItems,
        tableId: dineInTable?.id,
        tableNumber: dineInTable?.tableName ?? widget.tableNumber,
        deliveryAddressId: deliveryProvider.selectedAddress?.id,
        // Discount is applied via apply-discount API below to avoid double-counting.
        paymentMethod: paymentMethodStr,
      );
      final orderId = orderResult.orderId;
      final orderNumber = orderResult.orderNumber;

      if (orderId == null) {
        if (!mounted) return;
        setState(() => _isPlacingOrder = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order failed: ${orderProvider.error}'),
            backgroundColor: Colors.red[700],
          ),
        );
        return;
      }
      if (!mounted) return;

      // Apply discount code via backend API (records it on the order).
      if (_appliedCode != null || _discountCtrl.text.trim().isNotEmpty) {
        await _applyDiscount(orderId);
      }

      // Initiate payment (skip for cash)
      if (_selectedPayment != PaymentMethod.cash) {
        final payOk = await paymentProvider.initiatePayment(
          orderId: orderId,
          amount: _finalTotal,
          paymentMethod: paymentMethodStr,
        );

        if (!payOk) {
          if (!mounted) return;
          setState(() => _isPlacingOrder = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed: ${paymentProvider.error}'),
              backgroundColor: Colors.red[700],
            ),
          );
          return;
        }
        if (!mounted) return;

        final paymentId = paymentProvider.currentPayment?.paymentId ?? '';

        // Verify payment (mock mode auto-completes)
        await paymentProvider.verifyPayment(
          paymentId: paymentId,
          transactionId: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        );
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            orderId: orderId,
            orderNumber: orderNumber,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  String _getOrderTypeString(OrderMode mode) {
    switch (mode) {
      case OrderMode.dineIn:
        return 'dine_in';
      case OrderMode.pickup:
        return 'pickup';
      case OrderMode.delivery:
        return 'delivery';
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliveryProvider = context.watch<DeliveryProvider>();
    final deliveryEstimate = widget.orderMode == OrderMode.delivery
        ? deliveryProvider.deliveryEstimate
        : null;

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
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F2A1A),
                        ),
                      ),
                      Text(
                        'Almost there!',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8A8884),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('SERVICE DETAILS'),
                    _buildServiceCard(deliveryEstimate),

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
                      title: widget.orderMode == OrderMode.dineIn
                          ? 'Pay At Counter'
                          : 'Cash on Delivery',
                      subtitle: widget.orderMode == OrderMode.dineIn
                          ? 'Settle after your meal'
                          : 'Pay when you receive',
                      iconBg: const Color(0xFFF0FDF4),
                      iconColor: const Color(0xFF22C55E),
                    ),

                    _sectionLabel('DISCOUNT CODE'),
                    _buildDiscountSection(),

                    if (widget.loyaltyDiscount > 0) ...[
                      _sectionLabel('REWARDS'),
                      _buildLoyaltyBanner(),
                    ],

                    _sectionLabel('ORDER SUMMARY'),
                    _buildOrderSummary(deliveryEstimate),
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
                      await _placeOrder();
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
                        child: _isPlacingOrder
                            ? const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
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
                                      '₹${_finalTotal.toStringAsFixed(0)}',
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

  Widget _buildServiceCard(dynamic deliveryEstimate) {
    final dineInTable = context.watch<DineInProvider>().currentTable;
    IconData icon;
    String title;
    String subtitle;
    String statusLabel;
    Color iconBg;

    switch (widget.orderMode) {
      case OrderMode.dineIn:
        icon = Icons.restaurant_rounded;
        title = dineInTable?.tableName ?? widget.tableNumber ?? 'Dine In';
        subtitle = dineInTable == null
            ? 'Scan table QR before placing order'
            : 'Le Frais Restaurant';
        statusLabel = dineInTable == null
            ? 'TABLE REQUIRED'
            : 'IMMEDIATE SERVICE';
        iconBg = const Color(0xFFE9F5EC);
        break;
      case OrderMode.pickup:
        icon = Icons.shopping_bag_outlined;
        title = 'Store Pickup';
        subtitle = 'Le Frais Restaurant';
        statusLabel = 'READY IN ~10 MIN';
        iconBg = const Color(0xFFFFF8E1);
        break;
      case OrderMode.delivery:
        icon = Icons.delivery_dining_rounded;
        final address = context.read<DeliveryProvider>().selectedAddress;
        title = 'Home Delivery';
        subtitle = address?.fullAddress ?? 'Select delivery address';
        statusLabel = deliveryEstimate != null
            ? '~${deliveryEstimate.estimatedTime} MIN · ₹${deliveryEstimate.deliveryCharge.toStringAsFixed(0)}'
            : 'ASAP · ~45 MIN';
        iconBg = const Color(0xFFEDF2FF);
        break;
    }

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
              color: iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: _accentGreen, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Georgia',
                    color: Color(0xFF1C1A17),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A8884),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                        statusLabel,
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
    final isSelected = _selectedPayment == value;
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

  Widget _buildDiscountSection() {
    final availableDiscounts = context
        .watch<PaymentProvider>()
        .availableDiscounts;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_appliedCode != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F5EC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _accentGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_offer_rounded,
                    size: 16,
                    color: _accentGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$_appliedCode applied — saving ₹${_discountAmount.toStringAsFixed(0)}!',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _accentGreen,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _appliedCode = null;
                        _discountAmount = 0;
                        _discountCtrl.clear();
                        _discountError = null;
                      });
                      context.read<PaymentProvider>().clearDiscount();
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: _accentGreen,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _discountCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Enter discount code',
                      hintStyle: const TextStyle(
                        color: Color(0xFFCECCC8),
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.local_offer_outlined,
                        size: 18,
                        color: Color(0xFF9A9690),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF6F5F0),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: _accentGreen,
                          width: 1.5,
                        ),
                      ),
                      errorText: _discountError,
                    ),
                    onSubmitted: (_) => _validateAndApplyCode(),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _isApplyingDiscount ? null : _validateAndApplyCode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: _accentGreen,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: _isApplyingDiscount
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Apply',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            if (availableDiscounts.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Available offers',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9A9690),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: availableDiscounts
                      .map((d) => _buildDiscountChip(d))
                      .toList(),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildDiscountChip(DiscountCode d) {
    return GestureDetector(
      onTap: () {
        _discountCtrl.text = d.code;
        _validateAndApplyCode();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F9F4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _accentGreen.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_offer_outlined,
              size: 11,
              color: _accentGreen,
            ),
            const SizedBox(width: 5),
            Text(
              '${d.code}  ·  ${d.displayValue}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _accentGreen,
              ),
            ),
          ],
        ),
      ),
    );
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
                        : 'Use your loyalty points',
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

  Widget _buildOrderSummary(dynamic deliveryEstimate) {
    final deliveryCharge =
        widget.orderMode == OrderMode.delivery && deliveryEstimate != null
        ? deliveryEstimate.deliveryCharge as double
        : 0.0;

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
                          SizedBox(
                            width: 160,
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Divider(
              color: Colors.white.withValues(alpha: 0.1),
              height: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              children: [
                _billRow('Subtotal', '₹${widget.subtotal.toStringAsFixed(0)}'),
                const SizedBox(height: 8),
                _billRow('GST (5%)', '₹${widget.gst.toStringAsFixed(0)}'),
                if (widget.serviceCharge > 0) ...[
                  const SizedBox(height: 8),
                  _billRow(
                    'Service Charge',
                    '₹${widget.serviceCharge.toStringAsFixed(0)}',
                  ),
                ],
                if (deliveryCharge > 0) ...[
                  const SizedBox(height: 8),
                  _billRow(
                    'Delivery Charge',
                    '₹${deliveryCharge.toStringAsFixed(0)}',
                  ),
                ],
                if (_discountAmount > 0) ...[
                  const SizedBox(height: 8),
                  _billRow(
                    'Discount ($_appliedCode)',
                    '-₹${_discountAmount.toStringAsFixed(0)}',
                    isDiscount: true,
                  ),
                ],
                if (_loyaltyApplied && widget.loyaltyDiscount > 0) ...[
                  const SizedBox(height: 8),
                  _billRow(
                    'Loyalty Points',
                    '-₹${widget.loyaltyDiscount.toStringAsFixed(0)}',
                    isDiscount: true,
                  ),
                ],
              ],
            ),
          ),
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
                  '₹${_finalTotal.toStringAsFixed(0)}',
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
}
