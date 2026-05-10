import 'api_client.dart';

/// Payment Service - Handle payment processing
class PaymentService {
  final ApiClient apiClient;

  PaymentService({required this.apiClient});

  /// Initiate payment for an order
  Future<PaymentResponse> initiatePayment({
    required String orderId,
    required double amount,
    required String paymentMethod, // upi, card, netbanking, cash
  }) async {
    try {
      final response = await apiClient.post('/payments/initiate', {
        'orderId': orderId,
        'amount': amount,
        'paymentMethod': paymentMethod,
      });

      return PaymentResponse.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      throw PaymentException(e.message);
    }
  }

  /// Verify payment after completion
  Future<PaymentVerification> verifyPayment({
    required String paymentId,
    required String transactionId,
  }) async {
    try {
      final response = await apiClient.post('/payments/verify', {
        'paymentId': paymentId,
        'transactionId': transactionId,
      });

      return PaymentVerification.fromJson(
        response['data'] as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      throw PaymentException(e.message);
    }
  }

  /// Get payment status
  Future<PaymentStatus> getPaymentStatus(String paymentId) async {
    try {
      final response = await apiClient.get('/payments/$paymentId/status');
      return PaymentStatus.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      throw PaymentException(e.message);
    }
  }

  /// Apply discount code
  Future<DiscountResponse> applyDiscount({
    required String orderId,
    required String discountCode,
  }) async {
    try {
      final response = await apiClient.post('/orders/$orderId/apply-discount', {
        'discountCode': discountCode,
      });

      return DiscountResponse.fromJson(
        response['data'] as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      throw PaymentException(e.message);
    }
  }

  /// Confirm cash payment after order is ready
  Future<void> confirmCashPayment({
    required String orderId,
    required double amount,
  }) async {
    try {
      await apiClient.post('/orders/$orderId/payment/cash-confirm', {
        'amount': amount,
      });
    } on ApiException catch (e) {
      throw PaymentException(e.message);
    }
  }

  /// Get available discount codes
  Future<List<DiscountCode>> getDiscounts() async {
    try {
      final response = await apiClient.get('/discounts', requiresAuth: false);
      final discounts = (response['data'] as List)
          .map((item) => DiscountCode.fromJson(item as Map<String, dynamic>))
          .toList();
      return discounts;
    } on ApiException catch (e) {
      throw PaymentException(e.message);
    }
  }
}

/// Payment Response Model
class PaymentResponse {
  final String paymentId;
  final String orderId;
  final double amount;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final String? redirectUrl;

  PaymentResponse({
    required this.paymentId,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.redirectUrl,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      paymentId: json['_id'] ?? json['paymentId'] ?? '',
      orderId: json['orderId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      status: json['status'] ?? 'PENDING',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      redirectUrl: json['redirectUrl'],
    );
  }
}

/// Payment Verification Model
class PaymentVerification {
  final String paymentId;
  final String orderId;
  final String status; // SUCCESS, FAILED, PENDING
  final String message;

  PaymentVerification({
    required this.paymentId,
    required this.orderId,
    required this.status,
    required this.message,
  });

  factory PaymentVerification.fromJson(Map<String, dynamic> json) {
    return PaymentVerification(
      paymentId: json['paymentId'] ?? '',
      orderId: json['orderId'] ?? '',
      status: json['status'] ?? 'PENDING',
      message: json['message'] ?? '',
    );
  }

  bool get isSuccess => status == 'SUCCESS';
  bool get isFailed => status == 'FAILED';
  bool get isPending => status == 'PENDING';
}

/// Payment Status Model
class PaymentStatus {
  final String paymentId;
  final String status; // PENDING, COMPLETED, FAILED, CANCELLED
  final DateTime lastUpdated;

  PaymentStatus({
    required this.paymentId,
    required this.status,
    required this.lastUpdated,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      paymentId: json['paymentId'] ?? '',
      status: json['status'] ?? 'PENDING',
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

/// Discount Code Model
class DiscountCode {
  final String id;
  final String code;
  final String description;
  final String discountType; // 'percentage' or 'flat'
  final double discountValue; // percentage number OR flat rupee amount
  final double discountPercentage; // kept for backward compat
  final double maxDiscount;
  final double minOrderValue;
  final bool isActive;
  final DateTime? validTill; // null means no expiry

  DiscountCode({
    required this.id,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.discountPercentage,
    required this.maxDiscount,
    required this.minOrderValue,
    required this.isActive,
    this.validTill,
  });

  factory DiscountCode.fromJson(Map<String, dynamic> json) {
    return DiscountCode(
      id: json['_id'] ?? json['id'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      discountType: json['discountType'] ?? 'percentage',
      discountValue:
          (json['discountValue'] ?? json['discountPercentage'] ?? 0).toDouble(),
      discountPercentage:
          (json['discountPercentage'] ?? json['discountValue'] ?? 0).toDouble(),
      maxDiscount: (json['maxDiscount'] ?? 0).toDouble(),
      minOrderValue: (json['minOrderValue'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      validTill: json['validTill'] != null
          ? DateTime.tryParse(json['validTill'] as String)
          : null,
    );
  }

  bool get isValid =>
      isActive && (validTill == null || DateTime.now().isBefore(validTill!));

  /// Calculate how much discount to apply for a given subtotal (in rupees).
  double calculateDiscount(double subtotal) {
    double amount;
    if (discountType == 'flat') {
      amount = discountValue;
    } else {
      amount = (subtotal * discountValue) / 100;
    }
    if (maxDiscount > 0 && amount > maxDiscount) {
      amount = maxDiscount;
    }
    return amount.floorToDouble();
  }

  String get displayValue => discountType == 'flat'
      ? '₹${discountValue.toStringAsFixed(0)} OFF'
      : '${discountValue.toStringAsFixed(0)}% OFF';
}

/// Discount Response Model
class DiscountResponse {
  final double discountAmount;
  final double newTotal;
  final String message;

  DiscountResponse({
    required this.discountAmount,
    required this.newTotal,
    required this.message,
  });

  factory DiscountResponse.fromJson(Map<String, dynamic> json) {
    return DiscountResponse(
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      newTotal: (json['newTotal'] ?? 0).toDouble(),
      message: json['message'] ?? '',
    );
  }
}

/// Payment Exception
class PaymentException implements Exception {
  final String message;

  PaymentException(this.message);

  @override
  String toString() => 'PaymentException: $message';
}
