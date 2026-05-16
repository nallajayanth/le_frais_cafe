import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/payment_provider.dart';
import '../../services/api/payment_service.dart';

class CouponsSheet extends StatefulWidget {
  const CouponsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CouponsSheet(),
    );
  }

  @override
  State<CouponsSheet> createState() => _CouponsSheetState();
}

class _CouponsSheetState extends State<CouponsSheet> {
  final TextEditingController _codeCtrl = TextEditingController();
  bool _isValidating = false;
  String? _inputError;
  String? _inputSuccess;

  static const _darkGreen = Color(0xFF0F2A1A);
  static const _accentGreen = Color(0xFF1E5C3A);
  static const _gold = Color(0xFFC88B1A);
  static const _bgCream = Color(0xFFF4F2EC);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().loadAvailableDiscounts();
    });
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  double get _subtotal => context.read<CartProvider>().subtotal;

  Future<void> _applyManualCode() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _inputError = 'Please enter a coupon code');
      return;
    }

    setState(() {
      _isValidating = true;
      _inputError = null;
      _inputSuccess = null;
    });

    final paymentProvider = context.read<PaymentProvider>();
    final cartProvider = context.read<CartProvider>();

    // First check locally (fast)
    DiscountCode? found = paymentProvider.findDiscount(code);

    // Fall back to server validation
    if (found == null) {
      final validation = await paymentProvider.validateDiscount(
        code: code,
        subtotal: _subtotal,
      );
      if (!mounted) return;
      if (validation == null || !validation.valid) {
        setState(() {
          _inputError = validation?.message ?? 'Invalid or expired coupon code';
          _isValidating = false;
        });
        return;
      }
      found = validation.discount;
    }

    if (found == null) {
      setState(() {
        _inputError = 'Invalid or expired coupon code';
        _isValidating = false;
      });
      return;
    }

    if (found.minOrderValue > _subtotal) {
      setState(() {
        _inputError =
            'Add ₹${(found!.minOrderValue - _subtotal).ceil()} more to use this code';
        _isValidating = false;
      });
      return;
    }

    cartProvider.applyCoupon(found);
    HapticFeedback.mediumImpact();
    if (!mounted) return;

    setState(() {
      _isValidating = false;
      _inputSuccess =
          '${found!.code} applied — saving ₹${found.calculateDiscount(_subtotal).toStringAsFixed(0)}!';
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) Navigator.of(context).pop();
  }

  void _applyCard(DiscountCode coupon) {
    if (coupon.amountNeeded(_subtotal) > 0) return; // locked
    context.read<CartProvider>().applyCoupon(coupon);
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = context.watch<PaymentProvider>();
    final cartProvider = context.watch<CartProvider>();
    final discounts = paymentProvider.availableDiscounts;
    final appliedCoupon = cartProvider.appliedCoupon;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: _bgCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F5EC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_offer_rounded,
                        color: _accentGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coupons & Offers',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Georgia',
                              color: _darkGreen,
                            ),
                          ),
                          Text(
                            'Apply a promo code or pick an offer below',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8A8884),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Color(0xFF1C1A17),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Code input row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _codeCtrl,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 1.5,
                          color: _darkGreen,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter promo code',
                          hintStyle: const TextStyle(
                            color: Color(0xFFCECCC8),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0,
                          ),
                          prefixIcon: const Icon(
                            Icons.confirmation_number_outlined,
                            size: 18,
                            color: Color(0xFF9A9690),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFE8E6E0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFE8E6E0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: _accentGreen,
                              width: 1.5,
                            ),
                          ),
                          errorText: _inputError,
                          errorStyle: const TextStyle(fontSize: 11),
                        ),
                        onSubmitted: (_) => _applyManualCode(),
                        onChanged: (_) {
                          if (_inputError != null || _inputSuccess != null) {
                            setState(() {
                              _inputError = null;
                              _inputSuccess = null;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _isValidating ? null : _applyManualCode,
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: _accentGreen,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: _isValidating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'APPLY',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_inputSuccess != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: _accentGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _inputSuccess!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _accentGreen,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Section header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text(
                      'AVAILABLE OFFERS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF9A9690),
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color(0xFFE8E6E0),
                      ),
                    ),
                    if (discounts.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          '${discounts.length} offers',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _accentGreen,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Coupon list
              Expanded(
                child: paymentProvider.isLoading && discounts.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(color: _accentGreen),
                      )
                    : discounts.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: discounts.length,
                        itemBuilder: (_, i) => _buildCouponCard(
                          discounts[i],
                          isApplied: appliedCoupon?.id == discounts[i].id,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              size: 36,
              color: Color(0xFFCECCC8),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No offers available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6A6865),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Check back later for exclusive deals',
            style: TextStyle(fontSize: 13, color: Color(0xFF9A9690)),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(DiscountCode coupon, {required bool isApplied}) {
    final needed = coupon.amountNeeded(_subtotal);
    final isLocked = needed > 0;
    final savingsAmount = coupon.calculateDiscount(_subtotal);
    final isPercentage = coupon.discountType == 'percentage';

    final accentColor = isApplied
        ? _accentGreen
        : isLocked
        ? const Color(0xFF9A9690)
        : _darkGreen;
    final accentBg = isApplied
        ? const Color(0xFFE9F5EC)
        : isLocked
        ? const Color(0xFFF0EFEB)
        : const Color(0xFFEAF2ED);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isApplied
              ? _accentGreen.withValues(alpha: 0.6)
              : isLocked
              ? const Color(0xFFE8E6E0)
              : const Color(0xFFD4EAD8),
          width: isApplied ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isApplied
                ? _accentGreen.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main coupon body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Discount badge
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: accentBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isPercentage
                            ? '${coupon.discountValue.toStringAsFixed(0)}%'
                            : '₹${coupon.discountValue.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: isPercentage ? 20 : 18,
                          fontWeight: FontWeight.w900,
                          color: accentColor,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'OFF',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: accentColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              coupon.code,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: isLocked
                                    ? const Color(0xFF9A9690)
                                    : _darkGreen,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          if (isApplied)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _accentGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'APPLIED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coupon.shortDescription,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isLocked
                              ? const Color(0xFFAFADAA)
                              : const Color(0xFF4A4845),
                        ),
                      ),
                      if (coupon.description.isNotEmpty &&
                          coupon.description != coupon.shortDescription) ...[
                        const SizedBox(height: 3),
                        Text(
                          coupon.description,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9A9690),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (coupon.minOrderValue > 0)
                            _tag(
                              'Min ₹${coupon.minOrderValue.toStringAsFixed(0)}',
                              isLocked
                                  ? const Color(0xFFF0EFEB)
                                  : const Color(0xFFEAF2ED),
                              isLocked
                                  ? const Color(0xFF9A9690)
                                  : _accentGreen,
                            ),
                          if (coupon.maxDiscount > 0 && isPercentage)
                            _tag(
                              'Max ₹${coupon.maxDiscount.toStringAsFixed(0)}',
                              const Color(0xFFFBF3E0),
                              _gold,
                            ),
                          if (coupon.validTillFormatted != null)
                            _tag(
                              'Till ${coupon.validTillFormatted}',
                              const Color(0xFFF6F5F0),
                              const Color(0xFF9A9690),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Dashed divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(
                30,
                (i) => Expanded(
                  child: Container(
                    height: 1,
                    color: i.isEven
                        ? const Color(0xFFE8E6E0)
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),

          // Footer: eligibility + action
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: isLocked
                      ? Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3D6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.add_shopping_cart_rounded,
                                    size: 12,
                                    color: Color(0xFFC88B1A),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Add ₹${needed.toStringAsFixed(0)} more to unlock',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFC88B1A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : isApplied
                      ? Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: _accentGreen,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Saving ₹${savingsAmount.toStringAsFixed(0)} on this order!',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _accentGreen,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            const Icon(
                              Icons.savings_rounded,
                              size: 14,
                              color: _accentGreen,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'You save ₹${savingsAmount.toStringAsFixed(0)}!',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _accentGreen,
                              ),
                            ),
                          ],
                        ),
                ),
                if (isApplied)
                  GestureDetector(
                    onTap: () {
                      context.read<CartProvider>().removeCoupon();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEEEE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'REMOVE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFD44040),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: isLocked ? null : () => _applyCard(coupon),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isLocked
                            ? const Color(0xFFF0EFEB)
                            : _accentGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'APPLY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isLocked
                              ? const Color(0xFFBEBCB8)
                              : Colors.white,
                          letterSpacing: 0.5,
                        ),
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

  Widget _tag(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
