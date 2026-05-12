import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/delivery_provider.dart';
import '../../services/api/order_service.dart';
import '../../services/websocket_service.dart';
import '../shared/custom_bottom_nav_bar.dart';
import '../../game/game_integration.dart';

// ── Restaurant anchor coordinates (Hitech City, Hyderabad) ──────────────────
const _kRestaurantLat = 17.4379;
const _kRestaurantLng = 78.3489;

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
  double _riderProgress = 0.0; // 0.0 = restaurant, 1.0 = customer
  Timer? _pollTimer;
  Timer? _etaTimer;
  Timer? _riderTimer;
  String? _billPopupShownForStatus;

  // Kitchen / dine-in steps
  static const List<_TrackStep> _kitchenSteps = [
    _TrackStep(icon: Icons.receipt_long_rounded, label: 'Received'),
    _TrackStep(icon: Icons.check_circle_outline_rounded, label: 'Confirmed'),
    _TrackStep(icon: Icons.restaurant_rounded, label: 'Preparing'),
    _TrackStep(icon: Icons.shopping_bag_rounded, label: 'Ready'),
    _TrackStep(icon: Icons.check_circle_rounded, label: 'Done'),
  ];

  // Delivery-specific steps
  static const List<_TrackStep> _deliverySteps = [
    _TrackStep(icon: Icons.receipt_long_rounded, label: 'Placed'),
    _TrackStep(icon: Icons.restaurant_rounded, label: 'Preparing'),
    _TrackStep(icon: Icons.delivery_dining_rounded, label: 'On the Way'),
    _TrackStep(icon: Icons.home_rounded, label: 'Delivered'),
  ];

  static const _terminalStatuses = {
    'DELIVERED',
    'COMPLETED',
    'CANCELLED',
    'SERVED',
  };

  bool _isDeliveryOrder(String orderType) =>
      orderType.toLowerCase().contains('delivery');

  int _getKitchenStepIndex(String status) {
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

  int _getDeliveryStepIndex(String status) {
    switch (status.toUpperCase()) {
      case 'PLACED':
      case 'ACCEPTED':
        return 0;
      case 'PREPARING':
      case 'CONFIRMED':
        return 1;
      case 'OUT_FOR_DELIVERY':
        return 2;
      case 'DELIVERED':
      case 'COMPLETED':
        return 3;
      default:
        return 0;
    }
  }

  bool _isTerminal(String status) =>
      _terminalStatuses.contains(status.toUpperCase());

  String _formatOrderType(String orderType) {
    switch (orderType.toLowerCase()) {
      case 'dinein':
      case 'dine in':
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
      final orderProvider = context.read<OrderProvider>();
      Future.microtask(() async {
        await orderProvider.loadOrder(widget.orderId!);

        if (mounted) {
          final order = orderProvider.currentOrder;
          if (order != null) {
            setState(() {
              _localEta = order.estimatedTime > 0 ? order.estimatedTime : 15;
            });
            _maybeShowBillPopup(order);
            if (!_isTerminal(order.status)) {
              _connectWebSocket();
              _startPolling();
              _startEtaCountdown();
              if (_isDeliveryOrder(order.orderType)) {
                _initRiderProgress(order.status);
              }
            }
          }
        }
      });
    }
  }

  void _initRiderProgress(String status) {
    switch (status.toUpperCase()) {
      case 'OUT_FOR_DELIVERY':
        _riderProgress = 0.10;
        _startRiderAnimation();
      case 'DELIVERED':
      case 'COMPLETED':
        _riderProgress = 1.0;
      default:
        _riderProgress = 0.0;
    }
  }

  void _startRiderAnimation() {
    _riderTimer?.cancel();
    _riderTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      if (_riderProgress < 0.95) {
        setState(() => _riderProgress += 0.025);
      }
    });
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
        final order = provider.currentOrder;
        if (order != null) {
          _maybeShowBillPopup(order);
          if (_isDeliveryOrder(order.orderType)) {
            _syncRiderProgress(status.status);
          }
        }
        if (_isTerminal(status.status)) {
          _pollTimer?.cancel();
          _etaTimer?.cancel();
          _riderTimer?.cancel();
        }
      }
    }
  }

  void _syncRiderProgress(String status) {
    switch (status.toUpperCase()) {
      case 'OUT_FOR_DELIVERY':
        if (_riderProgress < 0.10) {
          setState(() => _riderProgress = 0.10);
          _startRiderAnimation();
        }
      case 'DELIVERED':
      case 'COMPLETED':
        _riderTimer?.cancel();
        setState(() => _riderProgress = 1.0);
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
        final order = context.read<OrderProvider>().currentOrder;
        if (order != null) {
          _maybeShowBillPopup(order);
          if (_isDeliveryOrder(order.orderType)) {
            _syncRiderProgress(status);
          }
        }
        if (_isTerminal(status)) {
          _pollTimer?.cancel();
          _etaTimer?.cancel();
          _riderTimer?.cancel();
        }
      }
    }
  }

  void _maybeShowBillPopup(Order order) {
    final s = order.status.toUpperCase();
    final isBillable = s == 'READY' || s == 'DELIVERED' || s == 'COMPLETED';
    final isCash =
        order.paymentMethod.toUpperCase() == 'CASH' ||
        order.paymentMethod.toUpperCase() == 'COD';
    final alreadyPaid =
        order.paymentStatus.toUpperCase() == 'PAID' ||
        order.paymentStatus.toUpperCase() == 'COMPLETED';

    if (isBillable && isCash && !alreadyPaid && _billPopupShownForStatus != s) {
      _billPopupShownForStatus = s;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showBillSheet(order);
      });
    }
  }

  void _showBillSheet(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ChangeNotifierProvider<PaymentProvider>.value(
        value: context.read<PaymentProvider>(),
        child: _BillBottomSheet(order: order),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pollTimer?.cancel();
    _etaTimer?.cancel();
    _riderTimer?.cancel();
    _wsService.removeListener(_onWsUpdate);
    _wsService.disconnect();
    _wsService.dispose();
    super.dispose();
  }

  // ── Main build ────────────────────────────────────────────────────────────

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

          final isDelivery = _isDeliveryOrder(order.orderType);
          final displayStatus = order.status;
          final isCancelled = displayStatus.toUpperCase() == 'CANCELLED';
          final currentStep = isDelivery
              ? _getDeliveryStepIndex(displayStatus)
              : _getKitchenStepIndex(displayStatus);
          final isCompleted = isDelivery
              ? currentStep >= (_deliverySteps.length - 1)
              : currentStep >= (_kitchenSteps.length - 1);

          return Stack(
            children: [
              // Top gradient
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: isDelivery ? 280 : 380,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isCancelled
                          ? [const Color(0xFF3D1212), const Color(0xFFF4F2EC)]
                          : isDelivery
                          ? [const Color(0xFF0D2B4F), const Color(0xFFF4F2EC)]
                          : [const Color(0xFF1A4A2E), const Color(0xFFF4F2EC)],
                      stops: const [0.0, 0.9],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(order, isCancelled, isCompleted),
                    Expanded(
                      child: isDelivery
                          ? _buildDeliveryBody(
                              order,
                              currentStep,
                              isCancelled,
                              isCompleted,
                            )
                          : _buildKitchenBody(
                              order,
                              currentStep,
                              isCancelled,
                              isCompleted,
                            ),
                    ),
                  ],
                ),
              ),

              // Floating action button
              if (!isCancelled && !isCompleted)
                Positioned(
                  bottom: 28,
                  right: 24,
                  child: _buildFab(order, isDelivery),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(activeIndex: 2),
    );
  }

  // ── App bar (shared) ─────────────────────────────────────────────────────

  Widget _buildAppBar(Order order, bool isCancelled, bool isCompleted) {
    return Padding(
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
          Image.asset('assets/logo.jpg', height: 32, fit: BoxFit.contain),
          if (!isCancelled && !isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
    );
  }

  // ── Delivery body ────────────────────────────────────────────────────────

  Widget _buildDeliveryBody(
    Order order,
    int currentStep,
    bool isCancelled,
    bool isCompleted,
  ) {
    final deliveryProvider = context.watch<DeliveryProvider>();
    final address = deliveryProvider.selectedAddress;

    final restaurantPos = const LatLng(_kRestaurantLat, _kRestaurantLng);
    final customerPos = address != null && address.latitude != 0
        ? LatLng(address.latitude, address.longitude)
        : LatLng(_kRestaurantLat + 0.012, _kRestaurantLng + 0.015);

    final riderPos = LatLng(
      restaurantPos.latitude +
          _riderProgress * (customerPos.latitude - restaurantPos.latitude),
      restaurantPos.longitude +
          _riderProgress * (customerPos.longitude - restaurantPos.longitude),
    );

    final deliveryStatusText = isCancelled
        ? 'Order\nCancelled'
        : isCompleted
        ? 'Delivered!'
        : currentStep >= 2
        ? 'On the\nWay!'
        : 'Being\nPrepared';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Order label
          Text(
            'ORDER #${order.id.length >= 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase()}  ·  DELIVERY',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            deliveryStatusText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              fontFamily: 'Georgia',
              color: Colors.white,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 16),

          if (!isCancelled) ...[
            // ── Live map card ────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  height: 230,
                  child: Stack(
                    children: [
                      FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(
                            (restaurantPos.latitude + customerPos.latitude) / 2,
                            (restaurantPos.longitude + customerPos.longitude) /
                                2,
                          ),
                          initialZoom: 13.5,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.lefrais.app',
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: [restaurantPos, customerPos],
                                color: const Color(0xFF1E5C3A),
                                strokeWidth: 3.5,
                              ),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              // Restaurant pin
                              Marker(
                                point: restaurantPos,
                                width: 40,
                                height: 40,
                                child: _buildMapPin(
                                  Icons.store_rounded,
                                  const Color(0xFF1E5C3A),
                                ),
                              ),
                              // Customer pin
                              Marker(
                                point: customerPos,
                                width: 40,
                                height: 40,
                                child: _buildMapPin(
                                  Icons.home_rounded,
                                  const Color(0xFFC88B1A),
                                ),
                              ),
                              // Rider pin
                              if (currentStep >= 2)
                                Marker(
                                  point: riderPos,
                                  width: 48,
                                  height: 48,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.25,
                                          ),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.delivery_dining_rounded,
                                      color: Color(0xFF0D2B4F),
                                      size: 26,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      // Map overlay gradient at bottom
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 60,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Color(0x33000000)],
                            ),
                          ),
                        ),
                      ),
                      // Legend chips
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Row(
                          children: [
                            _mapLegendChip(
                              Icons.store_rounded,
                              const Color(0xFF1E5C3A),
                              'Restaurant',
                            ),
                            const SizedBox(width: 6),
                            _mapLegendChip(
                              Icons.home_rounded,
                              const Color(0xFFC88B1A),
                              'Your Location',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── ETA + address strip ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F5EC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.access_time_rounded,
                      color: Color(0xFF1E5C3A),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCompleted
                              ? 'Delivered'
                              : currentStep >= 2
                              ? 'Arriving in $_localEta mins'
                              : 'Ready in $_localEta mins',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F2A1A),
                          ),
                        ),
                        if (address != null)
                          Text(
                            address.street.isNotEmpty
                                ? '${address.street}, ${address.city}'
                                : 'Your delivery location',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8A8884),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFFE9F5EC)
                          : const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isCompleted ? 'DONE' : '$_localEta MIN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: isCompleted
                            ? const Color(0xFF1E5C3A)
                            : const Color(0xFF3B5BDB),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Delivery timeline ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildTimeline(_deliverySteps, currentStep),
            ),
            const SizedBox(height: 14),

            // ── Rider card (shown once out for delivery or later) ──────
            if (currentStep >= 2)
              _buildRiderCard(order.id)
            else
              _buildPreparingBanner(),
            const SizedBox(height: 14),
          ] else
            _buildCancelledCard(),

          // ── Items card (shared) ──────────────────────────────────────
          _buildItemsCard(order),
          const SizedBox(height: 14),

          // ── Game button (during certain statuses) ──────────────────────
          if (!isCancelled &&
              !isCompleted &&
              (order.status.toUpperCase() == 'PLACED' ||
                  order.status.toUpperCase() == 'RECEIVED' ||
                  order.status.toUpperCase() == 'CONFIRMED' ||
                  order.status.toUpperCase() == 'PREPARING' ||
                  order.status.toUpperCase() == 'READY' ||
                  order.status.toUpperCase() == 'OUT_FOR_DELIVERY'))
            GamePlayButton(
              onGameClosed: () {
                // Refresh order status after game
                if (widget.orderId != null) {
                  context.read<OrderProvider>().loadOrder(widget.orderId!);
                }
              },
              onCoinsEarned: (coins) {
                // Show notification
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '🎉 Earned $coins coins!',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: const Color(0xFFFFEB3B),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
            ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ── Kitchen / Dine-in / Pickup body ─────────────────────────────────────

  Widget _buildKitchenBody(
    Order order,
    int currentStep,
    bool isCancelled,
    bool isCompleted,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
            // ETA card
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
                    isCompleted ? 'ORDER COMPLETED' : 'ESTIMATED READY IN',
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
                    builder: (context, child) => Transform.scale(
                      scale: !isCompleted
                          ? 0.97 + (_pulseAnim.value - 1.0) * 0.3
                          : 1.0,
                      child: child,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          isCompleted
                              ? '✓'
                              : _localEta.toString().padLeft(2, '0'),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
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
                      widthFactor: (currentStep / (_kitchenSteps.length - 1))
                          .clamp(0.02, 1.0),
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

            // Kitchen timeline
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
              child: _buildTimeline(_kitchenSteps, currentStep),
            ),
          ] else
            _buildCancelledCard(),

          const SizedBox(height: 20),
          _buildItemsCard(order),
          const SizedBox(height: 14),

          // ── Game button (during certain statuses) ──────────────────────
          if (!isCancelled &&
              !isCompleted &&
              (order.status.toUpperCase() == 'PREPARING' ||
                  order.status.toUpperCase() == 'CONFIRMED' ||
                  order.status.toUpperCase() == 'READY' ||
                  order.status.toUpperCase() == 'OUT_FOR_DELIVERY'))
            GamePlayButton(
              onGameClosed: () {
                // Refresh order status after game
                if (widget.orderId != null) {
                  context.read<OrderProvider>().loadOrder(widget.orderId!);
                }
              },
              onCoinsEarned: (coins) {
                // Show notification
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '🎉 Earned $coins coins!',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: const Color(0xFFFFEB3B),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
            ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ── Shared sub-widgets ───────────────────────────────────────────────────

  Widget _buildCancelledCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFFCACA), width: 1.5),
      ),
      child: const Column(
        children: [
          Icon(Icons.cancel_rounded, size: 56, color: Color(0xFFDC2626)),
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
    );
  }

  Widget _buildItemsCard(Order order) {
    final displayStatus = order.status;
    return Container(
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
            style: const TextStyle(fontSize: 12, color: Color(0xFF8A8884)),
          ),
          const SizedBox(height: 16),
          ...order.items.map((item) => _buildItemRow(item, displayStatus)),
          const Divider(color: Color(0xFFF0EFEB)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    );
  }

  Widget _buildFab(Order order, bool isDelivery) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDelivery
                ? [const Color(0xFF0D2B4F), const Color(0xFF1A4A8A)]
                : [const Color(0xFF8B5A10), const Color(0xFFC88B1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color:
                  (isDelivery
                          ? const Color(0xFF1A4A8A)
                          : const Color(0xFFC88B1A))
                      .withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 6),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDelivery
                  ? Icons.delivery_dining_rounded
                  : Icons.person_pin_circle_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              isDelivery ? 'CALL RIDER' : 'CALL WAITER',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiderCard(String orderId) {
    // Deterministic mock data from orderId
    final namePool = [
      'Rajesh Kumar',
      'Arjun Singh',
      'Priya Sharma',
      'Mohammed Ali',
      'Suresh Babu',
    ];
    final hash = orderId.hashCode.abs();
    final riderName = namePool[hash % namePool.length];
    final riderRating = (4.1 + (hash % 9) * 0.1).toStringAsFixed(1);
    final vehicleNum =
        'TS ${(hash % 90 + 10).toString().padLeft(2, '0')} BX ${(1000 + hash % 9000)}';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D2B4F), Color(0xFF1A4A8A)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                riderName.substring(0, 1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Georgia',
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
                  riderName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F2A1A),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFC88B1A),
                      size: 14,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      riderRating,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6A6865),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.two_wheeler_rounded,
                      color: Color(0xFF8A8884),
                      size: 14,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      vehicleNum,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8A8884),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Call button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE9F5EC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.call_rounded,
                color: Color(0xFF1E5C3A),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreparingBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF5C842).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.restaurant_rounded, color: Color(0xFF8B5A00), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your order is being freshly prepared. A delivery rider will be assigned shortly.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A3000),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPin(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _mapLegendChip(IconData icon, Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(OrderItem item, String status) {
    Color statusColor;
    String statusLabel;
    if (status.toUpperCase() == 'CANCELLED') {
      statusColor = Colors.red;
      statusLabel = 'Cancelled';
    } else if ([
      'READY',
      'DELIVERED',
      'COMPLETED',
    ].contains(status.toUpperCase())) {
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

  Widget _buildTimeline(List<_TrackStep> steps, int currentStep) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length * 2 - 1, (i) {
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
          final step = steps[index];
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (context, child) => Transform.scale(
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
                                color: const Color(
                                  0xFF1E5C3A,
                                ).withValues(alpha: 0.4),
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

// ── Pulse dot (live indicator) ───────────────────────────────────────────────

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
      builder: (context, child) => Opacity(
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

// ── Bill bottom sheet ────────────────────────────────────────────────────────

class _BillBottomSheet extends StatefulWidget {
  final Order order;
  const _BillBottomSheet({required this.order});

  @override
  State<_BillBottomSheet> createState() => _BillBottomSheetState();
}

class _BillBottomSheetState extends State<_BillBottomSheet> {
  bool _confirming = false;
  bool _confirmed = false;

  static const _darkGreen = Color(0xFF0F2A1A);
  static const _accentGreen = Color(0xFF1E5C3A);
  static const _gold = Color(0xFFC88B1A);

  Future<void> _confirmPayment() async {
    setState(() => _confirming = true);
    final paymentProvider = context.read<PaymentProvider>();
    final ok = await paymentProvider.confirmCashPayment(
      orderId: widget.order.id,
      amount: widget.order.total,
    );
    if (!mounted) return;
    if (ok) {
      setState(() {
        _confirming = false;
        _confirmed = true;
      });
    } else {
      setState(() => _confirming = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(paymentProvider.error ?? 'Failed to confirm payment'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0DDD8),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          if (_confirmed) ...[
            const Icon(
              Icons.check_circle_rounded,
              size: 64,
              color: _accentGreen,
            ),
            const SizedBox(height: 12),
            const Text(
              'Payment Confirmed!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontFamily: 'Georgia',
                color: _darkGreen,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Thank you! Your cash payment has been recorded.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF6A6865)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Bill',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Georgia',
                    color: _darkGreen,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF9A9690),
                  ),
                ),
              ],
            ),
            Text(
              'ORDER #${order.id.length >= 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase()}',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF8A8884),
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9F5EC),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Center(
                            child: Text(
                              '${item.quantity}×',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: _accentGreen,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 175,
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1A17),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1A17),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Color(0xFFEEECE8), height: 24),
            _billRow('Subtotal', '₹${order.subtotal.toStringAsFixed(0)}'),
            const SizedBox(height: 6),
            _billRow('GST', '₹${order.gst.toStringAsFixed(0)}'),
            if (order.serviceCharge > 0) ...[
              const SizedBox(height: 6),
              _billRow(
                'Service Charge',
                '₹${order.serviceCharge.toStringAsFixed(0)}',
              ),
            ],
            if (order.deliveryCharge > 0) ...[
              const SizedBox(height: 6),
              _billRow(
                'Delivery Charge',
                '₹${order.deliveryCharge.toStringAsFixed(0)}',
              ),
            ],
            if (order.discount > 0) ...[
              const SizedBox(height: 6),
              _billRow(
                'Discount',
                '-₹${order.discount.toStringAsFixed(0)}',
                isDiscount: true,
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F2EC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _darkGreen,
                    ),
                  ),
                  Text(
                    '₹${order.total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: _gold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF5C842).withValues(alpha: 0.4),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.payments_rounded,
                    size: 18,
                    color: Color(0xFF8B5A00),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Please pay cash to the staff',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A3000),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirming ? null : _confirmPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _darkGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF4A7060),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: _confirming
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Confirm Cash Payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
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
          style: const TextStyle(fontSize: 13, color: Color(0xFF6A6865)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDiscount
                ? const Color(0xFF1E5C3A)
                : const Color(0xFF1C1A17),
          ),
        ),
      ],
    );
  }
}

class _TrackStep {
  final IconData icon;
  final String label;
  const _TrackStep({required this.icon, required this.label});
}
