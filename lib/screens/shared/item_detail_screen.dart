import 'package:flutter/material.dart';
import '../../models/app_cart.dart';
import '../../models/cart_entry.dart';
import '../cart/cart_screen.dart';

// ── Review model ──────────────────────────────────────────────────────────────

class _Review {
  final String initials;
  final Color avatarColor;
  final String name;
  final String timeAgo;
  final double rating;
  final String text;

  const _Review({
    required this.initials,
    required this.avatarColor,
    required this.name,
    required this.timeAgo,
    required this.rating,
    required this.text,
  });
}

const List<_Review> _reviews = [
  _Review(
    initials: 'AM',
    avatarColor: Color(0xFF6B8F71),
    name: 'Ananya M.',
    timeAgo: 'YESTERDAY',
    rating: 5,
    text:
        '"The truffle aroma is divine. Bread was perfectly toasted. Highly recommend!"',
  ),
  _Review(
    initials: 'RK',
    avatarColor: Color(0xFF5B7FA6),
    name: 'Rohan K.',
    timeAgo: '3 DAYS AGO',
    rating: 4,
    text:
        '"Good flavour but could use a bit more salt. Truffle oil is top tier."',
  ),
  _Review(
    initials: 'SL',
    avatarColor: Color(0xFFB07D62),
    name: 'Sarah L.',
    timeAgo: '1 WEEK AGO',
    rating: 5,
    text:
        '"Absolutely delicious! Worth every penny. The wild mushrooms were so fresh."',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class ItemDetailScreen extends StatefulWidget {
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final String? tag;
  final double? rating;
  final int? ratingCount;
  final OrderMode orderMode;

  const ItemDetailScreen({
    super.key,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.tag,
    this.rating,
    this.ratingCount,
    this.orderMode = OrderMode.delivery,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _qty = 1;
  String _milkType = 'Oat Milk';
  bool _extraParmesan = false;
  bool _chilliFlakes = false;
  bool _descExpanded = false;
  final TextEditingController _instructionsController = TextEditingController();

  static const _milkOptions = ['Oat Milk', 'Soy Milk'];
  static const Color _darkGreen = Color(0xFF1E5C3A);
  static const Color _priceGreen = Color(0xFF2D8653);
  static const Color _bgCream = Color(0xFFF8F7F4);

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  // ── Star row ──────────────────────────────────────────────────────────────
  Widget _buildStars(double rating, double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return Icon(Icons.star_rounded, size: size, color: const Color(0xFFE8A317));
        } else if (i < rating) {
          return Icon(Icons.star_half_rounded, size: size, color: const Color(0xFFE8A317));
        }
        return Icon(Icons.star_outline_rounded, size: size, color: const Color(0xFFDDDDDD));
      }),
    );
  }

  // ── Review card ───────────────────────────────────────────────────────────
  Widget _buildReviewCard(_Review review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: review.avatarColor,
            child: Text(
              review.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      review.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1A17),
                      ),
                    ),
                    _buildStars(review.rating, 13),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  review.timeAgo,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9A9690),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  review.text,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4A4845),
                    height: 1.5,
                    fontStyle: FontStyle.italic,
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
    final double rating = widget.rating ?? 4.7;
    final int reviewCount = widget.ratingCount ?? 238;
    final String price = '₹${widget.price.toStringAsFixed(0)}';
    final desc = widget.description;
    final bool longDesc = desc.length > 90;
    final displayDesc = (!_descExpanded && longDesc)
        ? '${desc.substring(0, 90)}...'
        : desc;

    return Scaffold(
      backgroundColor: const Color(0xFF1C1A17),
      body: Stack(
        children: [
          // ── Hero Image (top half) ─────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.42,
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (ctx, child, progress) => progress == null
                  ? child
                  : Container(color: const Color(0xFF2A2826)),
            ),
          ),

          // ── Top Action Bar ────────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _iconBtn(Icons.arrow_back, () => Navigator.of(context).pop()),
                Row(
                  children: [
                    _iconBtn(Icons.share_outlined, () {}),
                    const SizedBox(width: 8),
                    _iconBtn(Icons.favorite_border_rounded, () {}),
                  ],
                ),
              ],
            ),
          ),

          // ── Sliding White Content Card ────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).size.height * 0.34,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F7F4),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Tags row ─────────────────────────────────────────────
                    Row(
                      children: [
                        _tag('VEG', const Color(0xFFDFF2E8), const Color(0xFF2D8653)),
                        const SizedBox(width: 8),
                        _tag('ARTISAN', const Color(0xFFFDF3E3), const Color(0xFFC88B1A)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Name + Price row ──────────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Georgia',
                              color: Color(0xFF1C1A17),
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              price,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: _priceGreen,
                              ),
                            ),
                            if (widget.originalPrice != null)
                              Text(
                                '₹${widget.originalPrice!.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFAFADAA),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: _priceGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '~15 min',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _priceGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ── Rating ────────────────────────────────────────────────
                    Row(
                      children: [
                        _buildStars(rating, 15),
                        const SizedBox(width: 6),
                        Text(
                          '$rating',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4A4845),
                          ),
                        ),
                        Text(
                          ' ($reviewCount reviews)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9A9690),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Description ───────────────────────────────────────────
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5A5853),
                          height: 1.55,
                        ),
                        children: [
                          TextSpan(text: displayDesc),
                          if (longDesc)
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _descExpanded = !_descExpanded),
                                child: Text(
                                  _descExpanded ? '  Show less' : '  Read more',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _darkGreen,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    _sectionDivider(),

                    // ── Customise Your Order ──────────────────────────────────
                    const Text(
                      'Customise Your Order',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Georgia',
                        color: Color(0xFF1C1A17),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Milk Type
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Milk Type',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C1A17),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEEDE8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'OPTIONAL',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF9A9690),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: _milkOptions.map((milk) {
                        final sel = _milkType == milk;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () => setState(() => _milkType = milk),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: sel
                                    ? const Color(0xFFE8F5EE)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: sel
                                      ? _darkGreen
                                      : const Color(0xFFDEDCDA),
                                  width: sel ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    milk,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: sel
                                          ? _darkGreen
                                          : const Color(0xFF5A5853),
                                    ),
                                  ),
                                  if (sel) ...[
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.check_circle,
                                      size: 15,
                                      color: _darkGreen,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Add-ons
                    const Text(
                      'Add-ons',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1A17),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildAddon(
                      label: 'Extra Parmesan',
                      price: '+\$4',
                      value: _extraParmesan,
                      onChanged: (v) => setState(() => _extraParmesan = v),
                    ),
                    const SizedBox(height: 8),
                    _buildAddon(
                      label: 'Chilli Flakes',
                      price: 'Free',
                      value: _chilliFlakes,
                      onChanged: (v) => setState(() => _chilliFlakes = v),
                      freeLabel: true,
                    ),

                    const SizedBox(height: 20),

                    // Special Instructions
                    const Text(
                      'Special Instructions',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1A17),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE8E6E2),
                        ),
                      ),
                      child: TextField(
                        controller: _instructionsController,
                        maxLines: 3,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1C1A17),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'E.g. No onions, extra crispy bread...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFBBB9B6),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                    _sectionDivider(),

                    // ── Customer Reviews ──────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Customer Reviews',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Georgia',
                            color: Color(0xFF1C1A17),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _darkGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._reviews.map(_buildReviewCard),
                  ],
                ),
              ),
            ),
          ),

          // ── Fixed Bottom Bar ──────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  20, 14, 20, MediaQuery.of(context).padding.bottom + 14),
              decoration: BoxDecoration(
                color: _bgCream,
                border: Border(
                  top: BorderSide(
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Qty stepper
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFDEDCDA)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _qtyBtn(Icons.remove, () {
                          if (_qty > 1) setState(() => _qty--);
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '$_qty',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1C1A17),
                            ),
                          ),
                        ),
                        _qtyBtn(Icons.add, () => setState(() => _qty++)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Add to Cart button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Merge into AppCart (increment if item already exists)
                        final currentItems =
                            List<CartEntry>.from(AppCart.items);
                        final existing = currentItems
                            .where((e) => e.name == widget.name)
                            .firstOrNull;
                        if (existing != null) {
                          existing.qty += _qty;
                        } else {
                          currentItems.add(CartEntry(
                            name: widget.name,
                            price: widget.price,
                            imageUrl: widget.imageUrl,
                            qty: _qty,
                          ));
                        }
                        AppCart.update(currentItems, widget.orderMode);

                        // Navigate to CartScreen
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CartScreen(
                              items: currentItems,
                              orderMode: widget.orderMode,
                            ),
                            settings:
                                const RouteSettings(name: '/cart'),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF253D2C),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Add to Cart',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '₹${(widget.price * _qty).toStringAsFixed(0)}',
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF1C1A17), size: 20),
      ),
    );
  }

  Widget _tag(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _sectionDivider() {
    return Column(
      children: [
        Container(
          height: 1,
          color: const Color(0xFFEAE8E4),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAddon({
    required String label,
    required String price,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool freeLabel = false,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value ? const Color(0xFF1E5C3A) : const Color(0xFFE8E6E2),
            width: value ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value ? const Color(0xFF1E5C3A) : Colors.transparent,
                border: Border.all(
                  color: value
                      ? const Color(0xFF1E5C3A)
                      : const Color(0xFFCECCC8),
                  width: 1.5,
                ),
              ),
              child: value
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1A17),
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: freeLabel
                    ? const Color(0xFFDFF2E8)
                    : const Color(0xFFF1F0E8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                price,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: freeLabel
                      ? const Color(0xFF2D8653)
                      : const Color(0xFF5A5853),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Icon(icon, size: 18, color: const Color(0xFF1C1A17)),
      ),
    );
  }
}
