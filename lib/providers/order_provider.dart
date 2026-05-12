import 'package:flutter/material.dart';
import '../services/api/order_service.dart';

/// Order Provider - Manages order creation and tracking
class OrderProvider extends ChangeNotifier {
  final OrderService orderService;

  Order? _currentOrder;
  List<Order> _orderHistory = [];
  OrderStatus? _currentOrderStatus;
  bool _isLoading = false;
  String? _error;

  OrderProvider({required this.orderService});

  // Getters
  Order? get currentOrder => _currentOrder;
  List<Order> get orderHistory => _orderHistory;
  OrderStatus? get currentOrderStatus => _currentOrderStatus;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Create new order (returns orderId on success)
  Future<String?> createOrder({
    required String orderType,
    required List<OrderItem> items,
    String? tableNumber,
    String? deliveryAddressId,
    String? specialInstructions,
    double? discount,
    String? paymentMethod,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final orderId = await orderService.createOrder(
        orderType: orderType,
        items: items,
        tableNumber: tableNumber,
        deliveryAddressId: deliveryAddressId,
        specialInstructions: specialInstructions,
        discount: discount,
        paymentMethod: paymentMethod,
      );

      _error = null;
      return orderId;
    } on OrderException catch (e) {
      _error = e.message;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load order history
  Future<void> loadOrderHistory({int limit = 10, int offset = 0}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orderHistory = await orderService.getOrders(
        limit: limit,
        offset: offset,
      );
    } on OrderException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get single order
  Future<bool> loadOrder(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentOrder = await orderService.getOrder(orderId);
      _error = null;
      return true;
    } on OrderException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get order status (lightweight poll — syncs into currentOrder and history)
  Future<bool> loadOrderStatus(String orderId) async {
    try {
      final status = await orderService.getOrderStatus(orderId);
      updateOrderStatus(status); // notifies internally
      return true;
    } on OrderException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Cancel order
  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await orderService.cancelOrder(orderId, reason: reason);
      
      // Reload the order to get updated status
      if (_currentOrder?.id == orderId) {
        await loadOrder(orderId);
      }

      return true;
    } on OrderException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update order status from real-time source (WebSocket or poll)
  void updateOrderStatus(OrderStatus status) {
    _currentOrderStatus = status;
    // Keep _currentOrder in sync so the tracker UI always reflects the latest status
    if (_currentOrder != null && _currentOrder!.id == status.orderId) {
      _currentOrder = _currentOrder!.copyWith(
        status: status.status,
        estimatedTime: status.estimatedTimeRemaining > 0
            ? status.estimatedTimeRemaining
            : null,
      );
    }
    // Keep history list in sync so the history screen reflects live statuses
    final idx = _orderHistory.indexWhere((o) => o.id == status.orderId);
    if (idx != -1) {
      _orderHistory[idx] = _orderHistory[idx].copyWith(status: status.status);
    }
    notifyListeners();
  }

  /// Clear current order
  void clearCurrentOrder() {
    _currentOrder = null;
    _currentOrderStatus = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
