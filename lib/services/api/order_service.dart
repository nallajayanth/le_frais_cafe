import 'api_client.dart';

/// Order Service - Create orders, fetch orders, track status
class OrderService {
  final ApiClient apiClient;

  OrderService({required this.apiClient});

  /// Create new order
  Future<String> createOrder({
    required String orderType, // dineIn, pickup, delivery
    required List<OrderItem> items,
    String? tableNumber,
    String? deliveryAddressId,
    String? specialInstructions,
    double? discount,
  }) async {
    try {
      final body = {
        'orderType': orderType,
        'items': items.map((item) => item.toJson()).toList(),
        if (tableNumber != null) 'tableNumber': tableNumber,
        if (deliveryAddressId != null) 'deliveryAddressId': deliveryAddressId,
        if (specialInstructions != null)
          'specialInstructions': specialInstructions,
        if (discount != null) 'discount': discount,
      };

      final response = await apiClient.post('/orders', body);
      // Backend returns {"orderId": "uuid"}, not a full Order object
      final orderId = response['orderId'] as String? ?? '';
      if (orderId.isEmpty) throw OrderException('No orderId in response');
      return orderId;
    } on ApiException catch (e) {
      throw OrderException(e.message);
    }
  }

  /// Get all orders for current customer
  Future<List<Order>> getOrders({int limit = 10, int offset = 0}) async {
    try {
      final response = await apiClient.get(
        '/orders?limit=$limit&offset=$offset',
      );
      final orders = (response['data'] as List)
          .map((item) => Order.fromJson(item as Map<String, dynamic>))
          .toList();
      return orders;
    } on ApiException catch (e) {
      throw OrderException(e.message);
    }
  }

  /// Get single order by ID with retry logic (handles race condition)
  Future<Order> getOrder(String orderId) async {
    int maxRetries = 5;
    int retryCount = 0;
    Duration delay = Duration(milliseconds: 500);

    while (retryCount < maxRetries) {
      try {
        final response = await apiClient.get('/orders/$orderId');
        return Order.fromJson(response['data'] as Map<String, dynamic>);
      } on ApiException catch (e) {
        if (e.message.contains('404') || e.message.contains('not found')) {
          // Order not found yet, retry after delay
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(delay);
            delay = Duration(
              milliseconds: (delay.inMilliseconds * 1.5).toInt().clamp(0, 5000),
            );
          } else {
            throw OrderException(e.message);
          }
        } else {
          throw OrderException(e.message);
        }
      }
    }

    throw OrderException('Failed to fetch order after $maxRetries retries');
  }

  /// Get order status updates
  Future<OrderStatus> getOrderStatus(String orderId) async {
    try {
      final response = await apiClient.get('/orders/$orderId/status');
      return OrderStatus.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      throw OrderException(e.message);
    }
  }

  /// Cancel order
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    try {
      await apiClient.post('/orders/$orderId/cancel', {'reason': reason});
    } on ApiException catch (e) {
      throw OrderException(e.message);
    }
  }

  /// Get order receipt
  Future<String> getOrderReceipt(String orderId) async {
    try {
      final response = await apiClient.get('/orders/$orderId/receipt');
      return response['data']['receiptUrl'] ?? '';
    } on ApiException catch (e) {
      throw OrderException(e.message);
    }
  }
}

/// Order Item Model
class OrderItem {
  final String itemId;
  final String name;
  final int quantity;
  final double price;
  final String? specialInstructions;

  OrderItem({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.price,
    this.specialInstructions,
  });

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'name': name,
    'quantity': quantity,
    'price': price,
    if (specialInstructions != null) 'specialInstructions': specialInstructions,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemId: json['itemId'] ?? json['_id'] ?? '',
      name: json['name'] ?? 'Item',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      specialInstructions: json['specialInstructions'],
    );
  }
}

/// Order Status Model
class OrderStatus {
  final String orderId;
  final String status; // PENDING, PREPARING, READY, COMPLETED, CANCELLED
  final DateTime statusUpdatedAt;
  final int estimatedTimeRemaining; // in minutes
  final String? message;

  OrderStatus({
    required this.orderId,
    required this.status,
    required this.statusUpdatedAt,
    required this.estimatedTimeRemaining,
    this.message,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      orderId: json['orderId'] ?? json['_id'] ?? '',
      status: json['status'] ?? 'PENDING',
      statusUpdatedAt: DateTime.parse(
        json['statusUpdatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      estimatedTimeRemaining: json['estimatedTimeRemaining'] ?? 15,
      message: json['message'],
    );
  }

  bool get isPending => status == 'PENDING';
  bool get isPreparing => status == 'PREPARING';
  bool get isReady => status == 'READY';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';
}

/// Order Model
class Order {
  final String id;
  final String customerId;
  final String orderType; // dineIn, pickup, delivery
  final List<OrderItem> items;
  final double subtotal;
  final double gst;
  final double serviceCharge;
  final double deliveryCharge;
  final double discount;
  final double total;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final String? tableNumber;
  final String? deliveryAddressId;
  final String? specialInstructions;
  final int estimatedTime; // in minutes
  final DateTime createdAt;
  final DateTime? completedAt;

  Order({
    required this.id,
    required this.customerId,
    required this.orderType,
    required this.items,
    required this.subtotal,
    required this.gst,
    required this.serviceCharge,
    required this.deliveryCharge,
    required this.discount,
    required this.total,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    this.tableNumber,
    this.deliveryAddressId,
    this.specialInstructions,
    required this.estimatedTime,
    required this.createdAt,
    this.completedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      orderType: json['orderType'] ?? 'dineIn',
      items:
          (json['items'] as List?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      gst: (json['gst'] ?? 0).toDouble(),
      serviceCharge: (json['serviceCharge'] ?? 0).toDouble(),
      deliveryCharge: (json['deliveryCharge'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? 'PENDING',
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      paymentMethod: json['paymentMethod'] ?? 'CARD',
      tableNumber: json['tableNumber']?.toString(),
      deliveryAddressId: json['deliveryAddressId'],
      specialInstructions: json['specialInstructions'],
      estimatedTime: json['estimatedTime'] ?? 15,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  bool get isPending => status == 'PENDING';
  bool get isPreparing => status == 'PREPARING';
  bool get isReady => status == 'READY';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';
}

/// Order Exception
class OrderException implements Exception {
  final String message;

  OrderException(this.message);

  @override
  String toString() => 'OrderException: $message';
}
