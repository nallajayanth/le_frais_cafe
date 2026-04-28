import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../services/api/order_service.dart';
import '../shared/custom_bottom_nav_bar.dart';
import '../support/support_screen.dart';
import '../reviews/review_screen.dart';
import 'order_tracker_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _refreshTimer;

  static const _activeStatuses = {
    'PLACED', 'ACCEPTED', 'PREPARING', 'READY', 'OUT_FOR_DELIVERY',
  };
  static const _doneStatuses = {
    'DELIVERED', 'COMPLETED', 'SERVED', 'CANCELLED',
  };
  static const _trackableStatuses = {
    'PLACED', 'ACCEPTED', 'PREPARING', 'READY', 'OUT_FOR_DELIVERY',
  };
  static const _cancellableStatuses = {'PLACED', 'ACCEPTED'};
  static const _reviewableStatuses = {'DELIVERED', 'COMPLETED', 'SERVED'};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    Future.microtask(() async {
      if (!mounted) return;
      await context.read<OrderProvider>().loadOrderHistory();
      if (mounted) _startRefreshTimer();
    });
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (!mounted) return;
      final provider = context.read<OrderProvider>();
      final hasActive = provider.orderHistory.any(
        (o) => _activeStatuses.contains(o.status.toUpperCase()),
      );
      if (hasActive) await provider.loadOrderHistory();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  List<Order> _getFilteredOrders(List<Order> orders, int tabIndex) {
    switch (tabIndex) {
      case 1:
        return orders
            .where((o) => _activeStatuses.contains(o.status.toUpperCase()))
            .toList();
      case 2:
        return orders
            .where((o) => _doneStatuses.contains(o.status.toUpperCase()))
            .toList();
      default:
        return orders;
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final isToday = now.year == dt.year &&
        now.month == dt.month &&
        now.day == dt.day;
    final isYesterday = now.year == dt.year &&
        now.month == dt.month &&
        now.day - 1 == dt.day;
    if (isToday) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return 'Today $h:$m';
    }
    if (isYesterday) return 'Yesterday';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  String _formatOrderType(String orderType) {
    switch (orderType.toLowerCase()) {
      case 'dinein': // cspell:disable-line
        return 'DINE IN';
      case 'pickup':
        return 'PICKUP';
      case 'delivery':
        return 'DELIVERY';
      default:
        return orderType.toUpperCase();
    }
  }

  ({Color bg, Color text, Color border, IconData icon, String label})
  _getStatusInfo(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
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
      case 'ACCEPTED':
        return (
          bg: const Color(0xFFE8F9EE),
          text: const Color(0xFF1E5C3A),
          border: const Color(0xFF2D8653),
          icon: Icons.thumb_up_rounded,
          label: 'Accepted',
        );
      case 'PREPARING':
        return (
          bg: const Color(0xFFFFF8E1),
          text: const Color(0xFFC88B1A),
          border: const Color(0xFFC88B1A),
          icon: Icons.outdoor_grill_rounded,
          label: 'Preparing',
        );
      case 'READY':
        return (
          bg: const Color(0xFFE8F9EE),
          text: const Color(0xFF1E5C3A),
          border: const Color(0xFF2D8653),
          icon: Icons.done_all_rounded,
          label: 'Ready',
        );
      case 'OUT_FOR_DELIVERY':
        return (
          bg: const Color(0xFFEDF2FF),
          text: const Color(0xFF3B5BDB),
          border: const Color(0xFF3B5BDB),
          icon: Icons.delivery_dining_rounded,
          label: 'On the Way',
        );
      default:
        return (
          bg: const Color(0xFFFFF8E1),
          text: const Color(0xFFC88B1A),
          border: const Color(0xFFC88B1A),
          icon: Icons.schedule_rounded,
          label: 'Placed',
        );
    }
  }

  Future<void> _showCancelDialog(Order order) async {
    String? selectedReason;
    final reasons = [
      'Changed my mind',
      'Ordered by mistake',
      'Wait time too long',
      'Found a better option',
      'Other',
    ];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cancel Order?',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Color(0xFF0F2A1A),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Please tell us why you want to cancel.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF8A8884)),
                ),
                const SizedBox(height: 16),
                ...reasons.map(
                  (r) => GestureDetector(
                    onTap: () => setDialogState(() => selectedReason = r),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: selectedReason == r
                            ? const Color(0xFFE8F9EE)
                            : const Color(0xFFF6F5F0),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selectedReason == r
                              ? const Color(0xFF1E5C3A)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              r,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selectedReason == r
                                    ? const Color(0xFF1E5C3A)
                                    : const Color(0xFF3A3835),
                              ),
                            ),
                          ),
                          if (selectedReason == r)
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: Color(0xFF1E5C3A),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0EC),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Text(
                              'Keep Order',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: selectedReason == null
                            ? null
                            : () => Navigator.of(ctx).pop(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: selectedReason == null
                                ? const Color(0xFFFFEDED).withValues(alpha: 0.5)
                                : const Color(0xFFFFEDED),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel Order',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: selectedReason == null
                                    ? const Color(0xFFDC2626)
                                        .withValues(alpha: 0.4)
                                    : const Color(0xFFDC2626),
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
        ),
      ),
    );

    if (confirmed == true && mounted) {
      final ok = await context
          .read<OrderProvider>()
          .cancelOrder(order.id, reason: selectedReason);
      if (mounted) {
        if (ok) {
          context.read<OrderProvider>().loadOrderHistory();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order cancelled successfully'),
              backgroundColor: Color(0xFF1E5C3A),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not cancel the order. Please try support.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildOrderCard(Order order) {
    final status = _getStatusInfo(order.status);
    final isActive = _activeStatuses.contains(order.status.toUpperCase());
    final isDone = _reviewableStatuses.contains(order.status.toUpperCase());
    final isCancellable =
        _cancellableStatuses.contains(order.status.toUpperCase());
    final isTrackable =
        _trackableStatuses.contains(order.status.toUpperCase());
    final isCancelled = order.status.toUpperCase() == 'CANCELLED';
    final itemNames = order.items.isNotEmpty
        ? order.items.map((e) => e.name).join(', ')
        : 'Order';
    final shortId = order.id.length >= 8
        ? order.id.substring(0, 8).toUpperCase()
        : order.id.toUpperCase();

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
          // Image header
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            child: Stack(
              children: [
                Container(
                  height: 160,
                  color: const Color(0xFFEFEFEA),
                  child: const Center(
                    child: Icon(
                      Icons.restaurant_rounded,
                      size: 48,
                      color: Color(0xFFCECCC8),
                    ),
                  ),
                ),
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
                // Status chip — top left
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: status.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: status.border.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isActive)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 5),
                            decoration: BoxDecoration(
                              color: status.text,
                              shape: BoxShape.circle,
                            ),
                          ),
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
                // Order type badge — top right
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
                      _formatOrderType(order.orderType),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                // Item names — bottom
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

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #$shortId',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Georgia',
                        color: Color(0xFF1D1B18),
                      ),
                    ),
                    Text(
                      _formatDate(order.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9A9690),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
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
                        '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                      ),
                      Container(
                        height: 20,
                        width: 1,
                        color: const Color(0xFFE0DDD8),
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      _detailChip(
                        Icons.currency_rupee_rounded,
                        '₹${order.total.toStringAsFixed(0)}',
                      ),
                      if (order.tableNumber != null) ...[
                        Container(
                          height: 20,
                          width: 1,
                          color: const Color(0xFFE0DDD8),
                          margin: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        _detailChip(
                          Icons.table_restaurant_rounded,
                          'T${order.tableNumber}',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    if (isTrackable)
                      Expanded(
                        child: _actionButton(
                          label: 'Track Now',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F2A1A), Color(0xFF1E5C3A)],
                          ),
                          textColor: Colors.white,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  OrderTrackerScreen(orderId: order.id),
                            ),
                          ),
                        ),
                      ),
                    if (isDone)
                      Expanded(
                        child: _actionButton(
                          label: 'Write Review',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F2A1A), Color(0xFF1E5C3A)],
                          ),
                          textColor: Colors.white,
                          onTap: () => _openReview(order),
                        ),
                      ),
                    if (isCancelled)
                      Expanded(
                        child: _actionButton(
                          label: 'Get Support',
                          color: const Color(0xFFF0EFEB),
                          textColor: const Color(0xFF3A3835),
                          onTap: () => _openSupport(order.id),
                        ),
                      ),
                    if (isTrackable || isDone) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: _actionButton(
                          label: isCancellable ? 'Cancel' : 'Get Support',
                          color: isCancellable
                              ? const Color(0xFFFFEDED)
                              : const Color(0xFFF0EFEB),
                          textColor: isCancellable
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF3A3835),
                          onTap: isCancellable
                              ? () => _showCancelDialog(order)
                              : () => _openSupport(order.id),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openReview(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReviewScreen(order: order)),
    );
  }

  void _openSupport(String orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupportScreen(prefilledOrderId: orderId),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    LinearGradient? gradient,
    Color? color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? color : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: gradient != null
              ? [
                  BoxShadow(
                    color: const Color(0xFF1E5C3A).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 52,
            color: const Color(0xFF8A8884).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 14),
          const Text(
            'No orders here',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Georgia',
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Orders you place will show up here.',
            style: TextStyle(fontSize: 13, color: Color(0xFF9A9690)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EC),
      body: SafeArea(
        child: Column(
          children: [
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
                    'My Orders',
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F2A1A),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 16),

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

            Expanded(
              child: Consumer<OrderProvider>(
                builder: (context, orderProvider, _) {
                  if (orderProvider.isLoading &&
                      orderProvider.orderHistory.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF0F2A1A),
                        ),
                      ),
                    );
                  }

                  if (orderProvider.error != null &&
                      orderProvider.orderHistory.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.wifi_off_rounded,
                            size: 48,
                            color: Color(0xFFCECCC8),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Could not load orders',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Georgia',
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () =>
                                context.read<OrderProvider>().loadOrderHistory(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF0F2A1A),
                                    Color(0xFF1E5C3A),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Text(
                                'Try Again',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final filtered = _getFilteredOrders(
                    orderProvider.orderHistory,
                    _tabController.index,
                  );

                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<OrderProvider>().loadOrderHistory(),
                    color: const Color(0xFF0F2A1A),
                    child: filtered.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.55,
                              child: _buildEmptyState(),
                            ),
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding:
                                const EdgeInsets.fromLTRB(20, 4, 20, 24),
                            itemCount: filtered.length,
                            itemBuilder: (_, i) =>
                                _buildOrderCard(filtered[i]),
                          ),
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
