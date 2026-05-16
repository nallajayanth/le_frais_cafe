import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/review_provider.dart';
import '../../services/api/order_service.dart';

class ReviewScreen extends StatefulWidget {
  final Order order;

  const ReviewScreen({super.key, required this.order});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 0;
  final _titleCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();
  String? _selectedItemId;

  static const _darkGreen = Color(0xFF0F2A1A);
  static const _accentGreen = Color(0xFF1E5C3A);
  static const _gold = Color(0xFFC88B1A);
  static const _cream = Color(0xFFF4F2EC);

  @override
  void initState() {
    super.initState();
    // Auto-select the item when there is only one so the review is always
    // linked to a menu item and shows up on the item detail screen.
    if (widget.order.items.length == 1) {
      _selectedItemId = widget.order.items.first.itemId;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    if (widget.order.items.length > 1 && _selectedItemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the item you are reviewing')),
      );
      return;
    }

    final provider = context.read<ReviewProvider>();
    final ok = await provider.submitReview(
      orderId: widget.order.id,
      rating: _rating,
      menuItemId: _selectedItemId,
      title: _titleCtrl.text.trim(),
      comment: _commentCtrl.text.trim(),
    );

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your review!'),
          backgroundColor: Color(0xFF1E5C3A),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to submit review'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReviewProvider>();

    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
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
                  const Expanded(
                    child: Text(
                      'Rate Your Order',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.w900,
                        color: _darkGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order header
                    Container(
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
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9F5EC),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              color: _accentGreen,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order ${widget.order.displayNumber}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: _darkGreen,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${widget.order.items.length} items · ₹${widget.order.total.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF8A8884),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Star rating
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'How was your experience?',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Georgia',
                              fontWeight: FontWeight.w700,
                              color: _darkGreen,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (i) {
                              final filled = i < _rating;
                              return GestureDetector(
                                onTap: () => setState(() => _rating = i + 1),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: AnimatedScale(
                                    scale: filled ? 1.15 : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                                      size: 44,
                                      color: filled ? _gold : const Color(0xFFD0CEC9),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _rating == 0
                                ? 'Tap to rate'
                                : ['', 'Poor', 'Fair', 'Good', 'Great', 'Excellent!'][_rating],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _rating == 0
                                  ? const Color(0xFFCECCC8)
                                  : _rating >= 4
                                      ? _accentGreen
                                      : _gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Item selector: hidden for single-item orders (auto-selected), required for multi-item orders
                    if (widget.order.items.length > 1) ...[
                      Row(
                        children: [
                          const Text(
                            'Select item to review',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6A6865),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(required)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.red[400],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.order.items
                            .map((item) => _itemChip(item.itemId, item.name))
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Title
                    const Text(
                      'Review Title (optional)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6A6865),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleCtrl,
                      decoration: _inputDec('e.g. "Amazing food and fast service"'),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 20),

                    // Comment
                    const Text(
                      'Tell us more (optional)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6A6865),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _commentCtrl,
                      decoration: _inputDec('Share your experience...'),
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 32),

                    // Submit
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        child: provider.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Submit Review',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemChip(String? itemId, String label) {
    final selected = _selectedItemId == itemId;
    return GestureDetector(
      onTap: () => setState(() => _selectedItemId = itemId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _accentGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _accentGreen : const Color(0xFFE0DDD8),
          ),
          boxShadow: selected
              ? [BoxShadow(color: _accentGreen.withValues(alpha: 0.3), blurRadius: 8)]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : const Color(0xFF3A3835),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  InputDecoration _inputDec(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFCECCC8), fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE8E6E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE8E6E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _accentGreen, width: 1.5),
      ),
    );
  }
}
