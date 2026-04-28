import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../services/api/order_service.dart';
import '../shared/custom_bottom_nav_bar.dart';
import 'order_tracker_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Fetch order history from backend
    Future.microtask(() {
      context.read<OrderProvider>().loadOrderHistory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Filter orders based on selected tab
  List<Order> _getFilteredOrders(List<Order> orders, int tabIndex) {
    switch (tabIndex) {
      case 0: // All
        return orders;
      case 1: // Active (In Progress)
        return orders
            .where((o) =>
                !['COMPLETED', 'SERVED', 'CANCELLED'].contains(o.status.toUpperCase()))
            .toList();
      case 2: // Past (Completed or Cancelled)
        return orders
            .where((o) =>
                ['COMPLETED', 'SERVED', 'CANCELLED'].contains(o.status.toUpperCase()))
            .toList();
      default:
        return orders;
    }
  }

  /// Get status display info
  ({Color bg, Color text, Color border, IconData icon, String label})
  _getStatusInfo(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
      case 'SERVED':
        return (
          bg: const Color(0xFFE8F9EE),
          text: const Color(0xFF1E5C3A),
          border: const Color(0xFF2D8653),
          icon: Icons.check_circle_rounded,
          label: 'Delivered',
        );
      case 'CANCELLED':
        return (
          bg: const Color(0xFFFFEDED),
          text: const Color(0xFFDC2626),
          border: const Color(0xFFDC2626),
          icon: Icons.cancel_rounded,
          label: 'Cancelled',
        );
      default:
        return (
          bg: const Color(0xFFFFF8E1),
          text: const Color(0xFFC88B1A),
          border: const Color(0xFFC88B1A),
          icon: Icons.schedule_rounded,
          label: 'In Progress',
        );
    }
  }

  /// Build order card from backend Order object
  Widget _buildOrderCardFromOrder(Order order) {
    final status = _getStatusInfo(order.status);
    final itemNames = order.items.isNotEmpty
        ? order.items.map((e) => e.name).join(', ')
        : 'Order';
    final firstItemImage =
        'https://via.placeholder.com/400x300?text=${order.items.isNotEmpty ? order.items[0].name : 'Order'}';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full-width image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Stack(
              children: [
                Image.network(
                  firstItemImage,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: const Color(0xFFEFEFEA),
                    child: const Center(
                      child: Icon(
                        Icons.restaurant_rounded,
                        size: 48,
                        color: Color(0xFFCECCC8),
                      ),
                    ),
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xCC0F1A14)],
                        stops: [0.4, 1.0],
                      ),
                    ),
                  ),
                ),
                // Status chip
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: status.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: status.border.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(status.icon, size: 12, color: status.text),
                        const SizedBox(width: 5),
                        Text(
                          status.label.toUpperCase(),
                          style: TextStyle(
                            color: status.text,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Mode badge
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      order.orderType.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                // Bottom text
                Positioned(
                  bottom: 14,
                  left: 16,
                  right: 16,
                  child: Text(
                    itemNames,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Card body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID & date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Georgia',
                        color: Color(0xFF1D1B18),
                      ),
                    ),
                    Text(
                      order.createdAt.toString().split(' ')[0],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9A9690),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Details row
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F5F0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _detailChip(
                        Icons.shopping_bag_rounded,
                        '${order.items.length} Items',
                      ),
                      Container(
                        height: 20,
                        width: 1,
                        color: const Color(0xFFE0DDD8),
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      _detailChip(
                        Icons.attach_money_rounded,
                        '₹${order.total.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    if (order.status.toUpperCase() != 'CANCELLED')
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (['PLACED', 'PREPARING', 'READY']
                                .contains(order.status.toUpperCase())) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      OrderTrackerScreen(orderId: order.id),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0F2A1A), Color(0xFF1E5C3A)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1E5C3A)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                ['PLACED', 'PREPARING', 'READY']
                                        .contains(order.status.toUpperCase())
                                    ? 'Track Now'
                                    : 'Reorder',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (order.status.toUpperCase() != 'CANCELLED')
                      const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0EFEB),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              order.status.toUpperCase() == 'CANCELLED'
                                  ? 'Get Support'
                                  : 'Details',
                              style: const TextStyle(
                                color: Color(0xFF3A3835),
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
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

  Widget _detailChip(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6A6865)),
        const SizedBox(width: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1A17),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EC),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
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
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Color(0xFF1C1A17),
                      ),
                    ),
                  ),
                  const Text(
                    'Past Orders',
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F2A1A),
                    ),
                  ),
                  Container(
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
                      Icons.tune_rounded,
                      size: 18,
                      color: Color(0xFF1C1A17),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Intro text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The Artisan History',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Georgia',
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D8653),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Every bite tells a story.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8A8884),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tab Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F2A1A), Color(0xFF1E5C3A)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(4),
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF6A6865),
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  splashFactory: NoSplash.splashFactory,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Active'),
                    Tab(text: 'Past'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Orders List
            Expanded(
              child: Consumer<OrderProvider>(
                builder: (context, orderProvider, _) {
                  if (orderProvider.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF0F2A1A).withValues(alpha: 0.8),
                        ),
                      ),
                    );
                  }

                  final filteredOrders = _getFilteredOrders(
                    orderProvider.orderHistory,
                    _tabController.index,
                  );

                  if (filteredOrders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 48,
                            color: const Color(0xFF8A8884).withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No orders yet',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: const Color(0xFF6B7280),
                                ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: filteredOrders.length + 1,
                    itemBuilder: (context, index) {
                      if (index == filteredOrders.length) {
                        return const SizedBox(height: 24);
                      }
                      return _buildOrderCardFromOrder(filteredOrders[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(activeIndex: 2),
    );
  }
}
