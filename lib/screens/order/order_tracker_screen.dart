import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../shared/custom_bottom_nav_bar.dart';

class OrderTrackerScreen extends StatefulWidget {
  final String? orderId;

  const OrderTrackerScreen({super.key, this.orderId});

  @override
  State<OrderTrackerScreen> createState() => _OrderTrackerScreenState();
}

class _OrderTrackerScreenState extends State<OrderTrackerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  static const List<_TrackStep> _steps = [
    _TrackStep(icon: Icons.receipt_long_rounded, label: 'Received'),
    _TrackStep(icon: Icons.restaurant_rounded, label: 'Preparing'),
    _TrackStep(icon: Icons.shopping_bag_rounded, label: 'Ready'),
    _TrackStep(icon: Icons.check_circle_outline_rounded, label: 'Served'),
  ];

  int _getStepIndex(String status) {
    switch (status.toUpperCase()) {
      case 'PLACED':
      case 'PENDING':
        return 0;
      case 'PREPARING':
      case 'CONFIRMED':
        return 1;
      case 'READY':
        return 2;
      case 'COMPLETED':
      case 'SERVED':
        return 3;
      default:
        return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Fetch order data from backend
    if (widget.orderId != null) {
      Future.microtask(() {
        context.read<OrderProvider>().loadOrder(widget.orderId!);
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildTimelineStep(int index, int currentStep) {
    final step = _steps[index];
    final isCompleted = index < currentStep;
    final isCurrent = index == currentStep;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Step circle
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, child) => Transform.scale(
              scale: isCurrent ? _pulseAnim.value : 1.0,
              child: child,
            ),
            child: Container(
              width: isCurrent ? 48 : 38,
              height: isCurrent ? 48 : 38,
              decoration: BoxDecoration(
                gradient: (isCompleted || isCurrent)
                    ? const LinearGradient(
                        colors: [Color(0xFF0F2A1A), Color(0xFF1E5C3A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: (isCompleted || isCurrent) ? null : const Color(0xFFE5E5DF),
                shape: BoxShape.circle,
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: const Color(0xFF1E5C3A).withValues(alpha: 0.4),
                          blurRadius: 14,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
              child: Icon(
                step.icon,
                size: isCurrent ? 22 : 17,
                color: (isCompleted || isCurrent) ? Colors.white : const Color(0xFF9B9A96),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            step.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: (isCompleted || isCurrent) ? FontWeight.w800 : FontWeight.w500,
              color: (isCompleted || isCurrent)
                  ? const Color(0xFF0F2A1A)
                  : const Color(0xFF9B9A96),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(int currentStep) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final stepBefore = i ~/ 2;
          final isCompleted = stepBefore < currentStep;
          return Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.only(bottom: 26),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: isCompleted
                    ? const LinearGradient(
                        colors: [Color(0xFF0F2A1A), Color(0xFF1E5C3A)],
                      )
                    : null,
                color: isCompleted ? null : const Color(0xFFE5E5DF),
              ),
            ),
          );
        } else {
          return _buildTimelineStep(i ~/ 2, currentStep);
        }
      }),
    );
  }

  Widget _buildItemRow({
    required String imagePath,
    required String title,
    required String subtitle,
    required int quantity,
    required String status,
    required Color statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (ctx, _, __) => Container(
                  color: const Color(0xFFEFEEEA),
                  child: const Icon(Icons.restaurant_rounded, color: Color(0xFFCECCC8), size: 24),
                ),
              ),
            ),
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
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D1B18),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
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
              Text(
                '${quantity}×',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6A6865),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                    letterSpacing: 0.3,
                  ),
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
      backgroundColor: const Color(0xFFF4F2EC),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          final order = orderProvider.currentOrder;
          if (orderProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF0F2A1A).withValues(alpha: 0.8),
                ),
              ),
            );
          }

          if (order == null) {
            return Center(
              child: Text(
                'Order not found',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
              ),
            );
          }

          final currentStep = _getStepIndex(order.status);
          final estimatedMinutes = order.estimatedTime;

          return Stack(
        children: [
          // Top gradient background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 380,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A4A2E),
                    Color(0xFFF4F2EC),
                  ],
                  stops: [0.0, 0.9],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/logo.jpg',
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Order ID
                        Text(
                          'ORDER #${order.id.substring(0, 8).toUpperCase()}  ·  ${order.orderType.toUpperCase()}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Bon Appétit\nSoon',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Georgia',
                            color: Colors.white,
                            height: 1.05,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ETA Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                                spreadRadius: -4,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            children: [
                              const Text(
                                'ESTIMATED READY IN',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  color: Color(0xFF8A8884),
                                ),
                              ),
                              const SizedBox(height: 10),
                              AnimatedBuilder(
                                animation: _pulseAnim,
                                builder: (_, child) => Transform.scale(
                                  scale: 0.97 + (_pulseAnim.value - 1.0) * 0.3,
                                  child: child,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      estimatedMinutes.toString().padLeft(2, '0'),
                                      style: const TextStyle(
                                        fontSize: 80,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF0F2A1A),
                                        height: 1.0,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE9F5EC),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'MINS',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF1E5C3A),
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Progress bar
                              Container(
                                height: 5,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E5DF),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: 0.70,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF0F2A1A), Color(0xFF2D8653)],
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Timeline
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _buildTimeline(currentStep),
                        ),

                        const SizedBox(height: 20),

                        // Items card
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.items.isNotEmpty ? order.items[0].name : 'Order',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Georgia',
                                  color: Color(0xFF0F2A1A),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ...order.items.map((item) {
                                return _buildItemRow(
                                  imagePath: 'https://via.placeholder.com/200?text=${item.name}',
                                  title: item.name,
                                  subtitle: 'Item #${item.itemId}',
                                  quantity: item.quantity,
                                  status: 'Ready',
                                  statusColor: const Color(0xFF2D8653),
                                );
                              }).toList(),
                              const SizedBox(height: 10),
                              const Divider(color: Color(0xFFF0EFEB)),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Subtotal',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF1C1A17),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'TAXES & SERVICE INCLUDED',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.0,
                                          color: Color(0xFFAFADAA),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Text(
                                    '₹34.50',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F2A1A),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Call Waiter floating button
          Positioned(
            bottom: 28,
            right: 24,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5A10), Color(0xFFC88B1A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC88B1A).withValues(alpha: 0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_pin_circle_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'CALL WAITER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(activeIndex: 2),
    );
  }
}

class _TrackStep {
  final IconData icon;
  final String label;
  const _TrackStep({required this.icon, required this.label});
}
