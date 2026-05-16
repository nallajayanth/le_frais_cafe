import 'api_client.dart';

/// Payment Service - Handle payment processing
class PaymentService {
  final ApiClient apiClient;

  PaymentService({required this.apiClient});

  /// Initiate payment for an order
  Future<PaymentResponse> initiatePayment({
    required String orderId,
    required double amount,
    required String paymentMethod,
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

  /// Apply discount code to an existing order
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

  /// Validate a discount code for a given subtotal (public, no order needed)
  Future<DiscountValidation> validateDiscount({
    required String code,
    required double subtotal,
  }) async {
    try {
      final response = await apiClient.post(
        '/discounts/validate',
        {'code': code, 'subtotal': subtotal},
        requiresAuth: false,
      );
      return DiscountValidation.fromJson(response);
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
  final String status;
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
  final String status;
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
  final double discountValue;
  final double discountPercentage;
  final double maxDiscount;
  final double minOrderValue;
  final bool isActive;
  final DateTime? validFrom;
  final DateTime? validTill;
  final int maxUsage;
  final int usageCount;

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
    this.validFrom,
    this.validTill,
    this.maxUsage = 0,
    this.usageCount = 0,
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
      validFrom: json['validFrom'] != null
          ? DateTime.tryParse(json['validFrom'] as String)
          : null,
      validTill: json['validTill'] != null
          ? DateTime.tryParse(json['validTill'] as String)
          : null,
      maxUsage: (json['maxUsage'] ?? 0) is int
          ? (json['maxUsage'] ?? 0)
          : int.tryParse(json['maxUsage'].toString()) ?? 0,
      usageCount: (json['usageCount'] ?? 0) is int
          ? (json['usageCount'] ?? 0)
          : int.tryParse(json['usageCount'].toString()) ?? 0,
    );
  }

  bool get isValid =>
      isActive && (validTill == null || DateTime.now().isBefore(validTill!));

  bool get hasUsageLimit => maxUsage > 0;
  bool get isExhausted => hasUsageLimit && usageCount >= maxUsage;
  int get remainingUses => hasUsageLimit ? (maxUsage - usageCount) : 9999;

  /// Calculate how much discount to apply for a given subtotal.
  double calculateDiscount(double subtotal) {
    if (subtotal < minOrderValue) return 0;
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

  /// Amount needed to unlock this coupon from [currentSubtotal].
  double amountNeeded(double currentSubtotal) {
    if (currentSubtotal >= minOrderValue) return 0;
    return (minOrderValue - currentSubtotal).ceilToDouble();
  }

  String get displayValue => discountType == 'flat'
      ? '₹${discountValue.toStringAsFixed(0)} OFF'
      : '${discountValue.toStringAsFixed(0)}% OFF';

  String get shortDescription {
    if (discountType == 'flat') {
      return '₹${discountValue.toStringAsFixed(0)} off on your order';
    } else {
      final suffix = maxDiscount > 0 ? ' up to ₹${maxDiscount.toStringAsFixed(0)}' : '';
      return '${discountValue.toStringAsFixed(0)}% off$suffix';
    }
  }

  String? get validTillFormatted {
    if (validTill == null) return null;
    final d = validTill!;
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

/// Discount Validation Response (from POST /discounts/validate)
class DiscountValidation {
  final bool valid;
  final bool canApply;
  final double discountAmount;
  final double amountNeeded;
  final String? message;
  final DiscountCode? discount;

  DiscountValidation({
    required this.valid,
    required this.canApply,
    required this.discountAmount,
    required this.amountNeeded,
    this.message,
    this.discount,
  });

  factory DiscountValidation.fromJson(Map<String, dynamic> json) {
    return DiscountValidation(
      valid: json['valid'] ?? false,
      canApply: json['canApply'] ?? false,
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      amountNeeded: (json['amountNeeded'] ?? 0).toDouble(),
      message: json['message']?.toString(),
      discount: json['discount'] != null
          ? DiscountCode.fromJson(json['discount'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Discount Response Model (from apply-discount)
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
