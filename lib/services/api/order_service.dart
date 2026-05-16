import 'api_client.dart';

/// Order Service - Create orders, fetch orders, track status
class OrderService {
  final ApiClient apiClient;

  OrderService({required this.apiClient});

  /// Create new order — returns (orderId, orderNumber)
  Future<({String orderId, int? orderNumber})> createOrder({
    required String orderType, // dineIn, pickup, delivery
    required List<OrderItem> items,
    int? tableId,
    String? tableNumber,
    String? deliveryAddressId,
    String? specialInstructions,
    double? discount,
    String? paymentMethod,
  }) async {
    try {
      final body = {
        'orderType': orderType,
        'items': items.map((item) => item.toJson()).toList(),
        if (tableId != null) 'tableId': tableId,
        if (tableNumber != null) 'tableNumber': tableNumber,
        if (deliveryAddressId != null) 'deliveryAddressId': deliveryAddressId,
        if (specialInstructions != null)
          'specialInstructions': specialInstructions,
        if (discount != null) 'discount': discount,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
      };

      final response = await apiClient.post('/orders', body);
      // Backend returns {"orderId": "uuid", "orderNumber": 1042}
      final orderId = response['orderId'] as String? ?? '';
      if (orderId.isEmpty) throw OrderException('No orderId in response');
      final orderNumber = _asNullableInt(response['orderNumber']);
      return (orderId: orderId, orderNumber: orderNumber);
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
      final rawOrders = response['data'] ?? response['orders'] ?? [];
      final orders = (rawOrders as List)
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

  /// Cancel order — returns { refundInitiated, refundId, message }
  Future<Map<String, dynamic>> cancelOrder(
      String orderId, {String? reason}) async {
    try {
      final response =
          await apiClient.post('/orders/$orderId/cancel', {'reason': reason});
      return response;
    } on ApiException catch (e) {
      throw OrderException(e.message, errorCode: e.errorCode);
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
      itemId:
          (json['itemId'] ?? json['item_id'] ?? json['_id'] ?? json['id'] ?? '')
              .toString(),
      name: json['name'] ?? 'Item',
      quantity: _asInt(json['quantity'], fallback: 1),
      price: _asDouble(json['price']),
      specialInstructions:
          (json['specialInstructions'] ?? json['special_instructions'])
              ?.toString(),
    );
  }
}

/// Order Status Model
class OrderStatus {
  final String orderId;
  final String status;
  final String? paymentStatus;
  final DateTime statusUpdatedAt;
  final int estimatedTimeRemaining; // in minutes
  final String? message;

  OrderStatus({
    required this.orderId,
    required this.status,
    this.paymentStatus,
    required this.statusUpdatedAt,
    required this.estimatedTimeRemaining,
    this.message,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      orderId: (json['orderId'] ?? json['order_id'] ?? json['_id'] ?? '')
          .toString(),
      status: json['status'] ?? 'PENDING',
      paymentStatus:
          (json['paymentStatus'] ?? json['payment_status'])?.toString(),
      statusUpdatedAt: _asDateTime(
        json['statusUpdatedAt'] ?? json['status_updated_at'],
      ),
      estimatedTimeRemaining: _asInt(
        json['estimatedTimeRemaining'] ?? json['estimated_time_remaining'],
        fallback: 15,
      ),
      message: json['message']?.toString(),
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
  final int? orderNumber;
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
  final int? tableId;
  final String? tableName;
  final String? deliveryAddressId;
  final String? specialInstructions;
  final String? cancellationReason;
  final int estimatedTime; // in minutes
  final DateTime createdAt;
  final DateTime? completedAt;

  Order({
    required this.id,
    this.orderNumber,
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
    this.tableId,
    this.tableName,
    this.deliveryAddressId,
    this.specialInstructions,
    this.cancellationReason,
    required this.estimatedTime,
    required this.createdAt,
    this.completedAt,
  });

  /// Human-readable display label — e.g. "#1042" when backend number is
  /// available, falling back to the first 8 chars of the UUID.
  String get displayNumber {
    if (orderNumber != null) return '#$orderNumber';
    final short = id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
    return '#$short';
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? json['id'] ?? '',
      orderNumber: _asNullableInt(json['orderNumber'] ?? json['order_number']),
      customerId: (json['customerId'] ?? json['customer_id'] ?? '').toString(),
      orderType: (json['orderType'] ?? json['order_type'] ?? 'dine_in')
          .toString(),
      items:
          (json['items'] as List?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: _asDouble(json['subtotal']),
      gst: _asDouble(json['gst']),
      serviceCharge: _asDouble(json['serviceCharge'] ?? json['service_charge']),
      deliveryCharge: _asDouble(
        json['deliveryCharge'] ?? json['delivery_charge'],
      ),
      discount: _asDouble(json['discount']),
      total: _asDouble(
        json['total'] ?? json['totalAmount'] ?? json['total_amount'],
      ),
      status: (json['status'] ?? 'PENDING').toString(),
      paymentStatus:
          (json['paymentStatus'] ?? json['payment_status'] ?? 'PENDING')
              .toString(),
      paymentMethod: (json['paymentMethod'] ?? json['payment_method'] ?? 'CARD')
          .toString(),
      tableNumber: (json['tableNumber'] ?? json['table_number'])?.toString(),
      tableId: _asNullableInt(json['tableId'] ?? json['table_id']),
      tableName: (json['tableName'] ?? json['table_name'])?.toString(),
      deliveryAddressId:
          (json['deliveryAddressId'] ?? json['delivery_address_id'])
              ?.toString(),
      specialInstructions:
          (json['specialInstructions'] ?? json['special_instructions'])
              ?.toString(),
      cancellationReason:
          (json['cancellationReason'] ?? json['cancellation_reason'])
              ?.toString(),
      estimatedTime: _asInt(
        json['estimatedTime'] ?? json['estimated_time'],
        fallback: 15,
      ),
      createdAt: _asDateTime(json['createdAt'] ?? json['created_at']),
      completedAt: _asNullableDateTime(
        json['completedAt'] ?? json['completed_at'],
      ),
    );
  }

  bool get isPending => status == 'PENDING';
  bool get isPreparing => status == 'PREPARING';
  bool get isReady => status == 'READY';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';

  Order copyWith({String? status, String? paymentStatus, int? estimatedTime}) {
    return Order(
      id: id,
      orderNumber: orderNumber,
      customerId: customerId,
      orderType: orderType,
      items: items,
      subtotal: subtotal,
      gst: gst,
      serviceCharge: serviceCharge,
      deliveryCharge: deliveryCharge,
      discount: discount,
      total: total,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod,
      tableNumber: tableNumber,
      tableId: tableId,
      tableName: tableName,
      deliveryAddressId: deliveryAddressId,
      specialInstructions: specialInstructions,
      cancellationReason: cancellationReason,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      createdAt: createdAt,
      completedAt: completedAt,
    );
  }
}

/// Order Exception
class OrderException implements Exception {
  final String message;
  final String? errorCode;

  OrderException(this.message, {this.errorCode});

  @override
  String toString() => 'OrderException: $message';
}

double _asDouble(dynamic value, {double fallback = 0}) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? fallback;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

DateTime _asDateTime(dynamic value) {
  return _asNullableDateTime(value) ?? DateTime.now();
}

DateTime? _asNullableDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
