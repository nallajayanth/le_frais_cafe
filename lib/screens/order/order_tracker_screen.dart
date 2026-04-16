import 'package:flutter/material.dart';
import '../shared/custom_bottom_nav_bar.dart';

class OrderTrackerScreen extends StatefulWidget {
  const OrderTrackerScreen({super.key});

  @override
  State<OrderTrackerScreen> createState() => _OrderTrackerScreenState();
}

class _OrderTrackerScreenState extends State<OrderTrackerScreen> {


  Widget _buildTimelineDot({
    required IconData icon,
    required String label,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    Color ringColor = Colors.transparent;
    Color bgColor = const Color(0xFFE5E5DF);
    Color iconColor = const Color(0xFF9B9A96);
    Color textColor = const Color(0xFF908F8B);

    if (isCompleted) {
      bgColor = const Color(0xFF0F442D);
      iconColor = Colors.white;
      textColor = const Color(0xFF0F442D);
    } else if (isCurrent) {
      ringColor = const Color(0xFF0F442D).withValues(alpha: 0.15);
      bgColor = const Color(0xFF0F442D);
      iconColor = Colors.white;
      textColor = const Color(0xFF0F442D);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ringColor,
          ),
          child: Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgColor,
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isCurrent || isCompleted ? FontWeight.w700 : FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderLines() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Base light grey line
        Container(
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 36, vertical: 22),
          color: const Color(0xFFE5E5DF),
        ),
        // Active green line
        Positioned(
          left: 36,
          child: Container(
            height: 2,
            width: 100, // Roughly connecting steps 1 and 2
            color: const Color(0xFF0F442D),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimelineDot(
              icon: Icons.check_rounded,
              label: 'Received',
              isCompleted: true,
              isCurrent: false,
            ),
            _buildTimelineDot(
              icon: Icons.restaurant_rounded,
              label: 'Preparing',
              isCompleted: false,
              isCurrent: true,
            ),
            _buildTimelineDot(
              icon: Icons.shopping_bag_outlined,
              label: 'Ready',
              isCompleted: false,
              isCurrent: false,
            ),
            _buildTimelineDot(
              icon: Icons.check_circle_outline_rounded,
              label: 'Served',
              isCompleted: false,
              isCurrent: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemRow({
    required String imagePath,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (ctx, _, __) => Container(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D1B18),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B6861),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '1x',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1B19),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      body: Stack(
        children: [
          // Background Gradient at Top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 450,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF9DEFE3), // Light Cyan/Mint
                    Color(0xFFF9F9F6), // Matches scaffold bg
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── App Bar ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          size: 26,
                          color: Color(0xFF0F442D),
                        ),
                      ),
                      const Text(
                        'Le Frais Cafe',
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F442D),
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.network(
                            'https://i.pravatar.cc/150?img=5',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Scrollable Body ─────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header Text
                        const Text(
                          'ORDER #LF-8829 • TABLE 14',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: Color(0xFF0F442D),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Bon Appétit\nSoon',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Georgia',
                            color: Color(0xFF0F442D),
                            height: 1.1,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Main Estimated Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF9DEFE3).withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                right: -20,
                                top: -20,
                                child: Icon(
                                  Icons.timer_outlined,
                                  size: 110,
                                  color: const Color(0xFFEAE8E2).withValues(alpha: 0.8),
                                ),
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'ESTIMATED READY IN',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                      color: Color(0xFF6B6861),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: const [
                                      Text(
                                        '08',
                                        style: TextStyle(
                                          fontSize: 72,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF0F442D),
                                          height: 1.0,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'MINS',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F442D),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 28),
                                  // Progress Bar
                                  Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE5E5DF),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: 0.7,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F442D),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Timeline State
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F2EB),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: _buildOrderLines(),
                        ),

                        const SizedBox(height: 24),

                        // Artisan Selection
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Artisan Selection',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Georgia',
                                  color: Color(0xFF385E47),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildItemRow(
                                imagePath:
                                    'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?q=80&w=200&auto=format&fit=crop',
                                title: 'Double Origin Espresso',
                                subtitle: 'Batch #402 • Medium Roast',
                                status: 'Ready',
                                statusColor: const Color(0xFF888681),
                              ),
                              _buildItemRow(
                                imagePath:
                                    'https://images.unsplash.com/photo-1555507054-d6edcd01362e?q=80&w=200&auto=format&fit=crop',
                                title: 'Almond Croissant',
                                subtitle: 'Artisan Crafted • Warm',
                                status: 'Baking',
                                statusColor: const Color(0xFF1C6342),
                              ),
                              _buildItemRow(
                                imagePath:
                                    'https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=200&auto=format&fit=crop',
                                title: 'Avocado Tartine',
                                subtitle: 'House Sourdough • Vegan',
                                status: 'Plating',
                                statusColor: const Color(0xFF1C6342),
                              ),

                              const SizedBox(height: 12),
                              const Divider(color: Color(0xFFF0EFEB)),
                              const SizedBox(height: 20),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Subtotal',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF184C32),
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'TAXES AND SERVICE INCLUDED',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.0,
                                          color: Color(0xFF888681),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Text(
                                    '₹34.50',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF184C32),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 100), // Space for bottom call waiter
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Call Waiter Floating Button ────────────────────────────────────
          Positioned(
            bottom: 24, // above nav bar area
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF6B420C), // Deep brownish-gold
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B420C).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.person_pin_circle_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'CALL WAITER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom Navigation ──────────────────────────────────────────────────
      bottomNavigationBar: const CustomBottomNavBar(activeIndex: 2),
    );
  }
}
