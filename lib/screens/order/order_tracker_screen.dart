import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../services/api/order_service.dart';
import '../../services/websocket_service.dart';
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
  late WebSocketService _wsService;

  int _localEta = 15;
  Timer? _pollTimer;
  Timer? _etaTimer;

  static const List<_TrackStep> _steps = [
    _TrackStep(icon: Icons.receipt_long_rounded, label: 'Received'),
    _TrackStep(icon: Icons.check_circle_outline_rounded, label: 'Confirmed'),
    _TrackStep(icon: Icons.restaurant_rounded, label: 'Preparing'),
    _TrackStep(icon: Icons.shopping_bag_rounded, label: 'Ready'),
    _TrackStep(icon: Icons.check_circle_rounded, label: 'Done'),
  ];

  static const _terminalStatuses = {
    'DELIVERED',
    'COMPLETED',
    'CANCELLED',
    'SERVED',
  };

  int _getStepIndex(String status) {
    switch (status.toUpperCase()) {
      case 'PLACED':
        return 0;
      case 'ACCEPTED':
        return 1;
      case 'PREPARING':
        return 2;
      case 'READY':
      case 'OUT_FOR_DELIVERY':
        return 3;
      case 'DELIVERED':
      case 'COMPLETED':
        return 4;
      default:
        return 0;
    }
  }

  bool _isTerminal(String status) =>
      _terminalStatuses.contains(status.toUpperCase());

  String _formatOrderType(String orderType) {
    switch (orderType.toLowerCase()) {
      case 'dinein':
        return 'DINE IN';
      case 'pickup':
        return 'PICKUP';
      case 'delivery':
        return 'DELIVERY';
      default:
        return orderType.toUpperCase();
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

    _wsService = WebSocketService();

    if (widget.orderId != null) {
      Future.microtask(() async {
        final orderProvider = context.read<OrderProvider>();
        await orderProvider.loadOrder(widget.orderId!);

        if (mounted) {
          final order = orderProvider.currentOrder;
          if (order != null) {
            setState(() {
              _localEta = order.estimatedTime > 0 ? order.estimatedTime : 15;
            });
            if (!_isTerminal(order.status)) {
              _connectWebSocket();
              _startPolling();
              _startEtaCountdown();
            }
          }
        }
      });
    }
  }

  void _connectWebSocket() {
    if (!mounted) return;
    final token =
        context.read<OrderProvider>().orderService.apiClient.getToken() ?? '';
    _doConnectWebSocket(token);
  }

  Future<void> _doConnectWebSocket(String token) async {
    try {
      await _wsService.connectToOrder(widget.orderId!, token);
      _wsService.addListener(_onWsUpdate);
    } catch (_) {}
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _pollStatus(),
    );
  }

  void _startEtaCountdown() {
    _etaTimer?.cancel();
    _etaTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_localEta > 1) _localEta--;
      });
    });
  }

  Future<void> _pollStatus() async {
    if (!mounted || widget.orderId == null) return;
    final provider = context.read<OrderProvider>();
    final ok = await provider.loadOrderStatus(widget.orderId!);
    if (ok && mounted) {
      final status = provider.currentOrderStatus;
      if (status != null) {
        if (status.estimatedTimeRemaining > 0) {
          setState(() => _localEta = status.estimatedTimeRemaining);
        }
        if (_isTerminal(status.status)) {
          _pollTimer?.cancel();
          _etaTimer?.cancel();
        }
      }
    }
  }

  void _onWsUpdate() {
    if (!mounted) return;
    final update = _wsService.lastStatusUpdate;
    if (update == null) return;

    final status = update['status'] as String?;
    final etaRaw = update['estimatedTimeRemaining'];
    final eta = etaRaw is int
        ? etaRaw
        : (etaRaw is double ? etaRaw.toInt() : null);

    if (status != null) {
      context.read<OrderProvider>().updateOrderStatus(
            OrderStatus(
              orderId: widget.orderId ?? '',
              status: status,
              statusUpdatedAt: DateTime.now(),
              estimatedTimeRemaining: eta ?? _localEta,
            ),
          );
      if (mounted) {
        if (eta != null) setState(() => _localEta = eta);
        if (_isTerminal(status)) {
          _pollTimer?.cancel();
          _etaTimer?.cancel();
        }
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pollTimer?.cancel();
    _etaTimer?.cancel();
    _wsService.removeListener(_onWsUpdate);
    _wsService.disconnect();
    _wsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EC),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          final order = orderProvider.currentOrder;

          if (orderProvider.isLoading && order == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F2A1A)),
              ),
            );
          }

          if (order == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: Color(0xFFCECCC8),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Order not found',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 18,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final displayStatus = order.status;
          final currentStep = _getStepIndex(displayStatus);
          final isCancelled = displayStatus.toUpperCase() == 'CANCELLED';
          final isCompleted = currentStep >= 4;

          return Stack(
            children: [
              // Top gradient background
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 380,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isCancelled
                          ? [const Color(0xFF3D1212), const Color(0xFFF4F2EC)]
                          : [const Color(0xFF1A4A2E), const Color(0xFFF4F2EC)],
                      stops: const [0.0, 0.9],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // App Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
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
                          // Live indicator — only shown while actively tracking
                          if (!isCancelled && !isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _PulseDot(),
                                  SizedBox(width: 6),
                                  Text(
                                    'LIVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            const SizedBox(width: 40),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'ORDER #${order.id.length >= 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase()}  ·  ${_formatOrderType(order.orderType)}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2.0,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isCancelled
                                  ? 'Order\nCancelled'
                                  : isCompleted
                                      ? 'Order\nCompleted!'
                                      : 'Bon Appétit\nSoon',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Georgia',
                                color: Colors.white,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 28),

                            if (!isCancelled) ...[
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
                                    Text(
                                      isCompleted
                                          ? 'ORDER COMPLETED'
                                          : 'ESTIMATED READY IN',
                                      style: const TextStyle(
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
                                        scale: !isCompleted
                                            ? 0.97 +
                                                (_pulseAnim.value - 1.0) * 0.3
                                            : 1.0,
                                        child: child,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            isCompleted
                                                ? '✓'
                                                : _localEta
                                                    .toString()
                                                    .padLeft(2, '0'),
                                            style: TextStyle(
                                              fontSize: isCompleted ? 60 : 80,
                                              fontWeight: FontWeight.w900,
                                              color: isCompleted
                                                  ? const Color(0xFF1E5C3A)
                                                  : const Color(0xFF0F2A1A),
                                              height: 1.0,
                                            ),
                                          ),
                                          if (!isCompleted) ...[
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFE9F5EC,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(8),
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
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE5E5DF),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor:
                                            (currentStep / (_steps.length - 1))
                                                .clamp(0.02, 1.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF0F2A1A),
                                                Color(0xFF2D8653),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(3),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: _buildTimeline(currentStep),
                              ),
                            ] else ...[
                              // Cancelled card
                              Container(
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: const Color(0xFFFFCACA),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.cancel_rounded,
                                      size: 56,
                                      color: Color(0xFFDC2626),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'This order has been cancelled.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1C1A17),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'If a payment was made, a refund will be\nprocessed within 5-7 business days.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF6A6865),
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

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
                                  const Text(
                                    'Your Order',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'Georgia',
                                      color: Color(0xFF0F2A1A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF8A8884),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...order.items.map(
                                    (item) =>
                                        _buildItemRow(item, displayStatus),
                                  ),
                                  const Divider(color: Color(0xFFF0EFEB)),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF1C1A17),
                                        ),
                                      ),
                                      Text(
                                        '₹${order.total.toStringAsFixed(0)}',
                                        style: const TextStyle(
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

              // Call Waiter button — only while order is active
              if (!isCancelled && !isCompleted)
                Positioned(
                  bottom: 28,
                  right: 24,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5A10), Color(0xFFC88B1A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFC88B1A).withValues(alpha: 0.45),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_pin_circle_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
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

  Widget _buildItemRow(OrderItem item, String status) {
    Color statusColor;
    String statusLabel;
    if (status.toUpperCase() == 'CANCELLED') {
      statusColor = Colors.red;
      statusLabel = 'Cancelled';
    } else if (['READY', 'DELIVERED', 'COMPLETED']
        .contains(status.toUpperCase())) {
      statusColor = const Color(0xFF2D8653);
      statusLabel = 'Ready';
    } else if (status.toUpperCase() == 'PREPARING') {
      statusColor = const Color(0xFFC88B1A);
      statusLabel = 'Cooking';
    } else {
      statusColor = const Color(0xFF5B6AF0);
      statusLabel = 'Queued';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEFEEEA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: Color(0xFFCECCC8),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D1B18),
                  ),
                ),
                Text(
                  '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B6861),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.quantity}×',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6A6865),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
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
          final index = i ~/ 2;
          final step = _steps[index];
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, child) => Transform.scale(
                    scale: isCurrent ? _pulseAnim.value : 1.0,
                    child: child,
                  ),
                  child: Container(
                    width: isCurrent ? 44 : 36,
                    height: isCurrent ? 44 : 36,
                    decoration: BoxDecoration(
                      gradient: (isCompleted || isCurrent)
                          ? const LinearGradient(
                              colors: [Color(0xFF0F2A1A), Color(0xFF1E5C3A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: (isCompleted || isCurrent)
                          ? null
                          : const Color(0xFFE5E5DF),
                      shape: BoxShape.circle,
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: const Color(0xFF1E5C3A)
                                    .withValues(alpha: 0.4),
                                blurRadius: 14,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      step.icon,
                      size: isCurrent ? 20 : 15,
                      color: (isCompleted || isCurrent)
                          ? Colors.white
                          : const Color(0xFF9B9A96),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  step.label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: (isCompleted || isCurrent)
                        ? FontWeight.w800
                        : FontWeight.w500,
                    color: (isCompleted || isCurrent)
                        ? const Color(0xFF0F2A1A)
                        : const Color(0xFF9B9A96),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
      }),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: Color(0xFF4ADE80),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _TrackStep {
  final IconData icon;
  final String label;
  const _TrackStep({required this.icon, required this.label});
}
