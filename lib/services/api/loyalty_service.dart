import 'api_client.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class LoyaltyTransaction {
  final String id;
  final String? orderId;
  final int points;
  final String type; // 'earned' | 'redeemed' | 'adjusted'
  final String? description;
  final DateTime createdAt;

  const LoyaltyTransaction({
    required this.id,
    this.orderId,
    required this.points,
    required this.type,
    this.description,
    required this.createdAt,
  });

  factory LoyaltyTransaction.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransaction(
      id: json['id']?.toString() ?? '',
      orderId: json['orderId']?.toString(),
      points: _asInt(json['points']),
      type: json['type']?.toString() ?? 'earned',
      description: json['description']?.toString(),
      createdAt: _asDateTime(json['createdAt'] ?? json['created_at']),
    );
  }
}

class LoyaltyBalance {
  /// Total points the customer currently holds.
  final int points;

  /// Redemption value in rupees (1 point = ₹1).
  final double value;

  /// Up to 20 most-recent transactions.
  final List<LoyaltyTransaction> recentTransactions;

  const LoyaltyBalance({
    required this.points,
    required this.value,
    required this.recentTransactions,
  });

  factory LoyaltyBalance.empty() =>
      const LoyaltyBalance(points: 0, value: 0, recentTransactions: []);

  factory LoyaltyBalance.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final txList = (data['recentTransactions'] as List?) ?? [];
    return LoyaltyBalance(
      points: _asInt(data['points']),
      value: _asDouble(data['value']),
      recentTransactions: txList
          .map((t) => LoyaltyTransaction.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RedeemResult {
  final bool success;
  final int pointsRedeemed;
  final double discountApplied;
  final int newBalance;
  final double newTotal;

  const RedeemResult({
    required this.success,
    required this.pointsRedeemed,
    required this.discountApplied,
    required this.newBalance,
    required this.newTotal,
  });

  factory RedeemResult.fromJson(Map<String, dynamic> json) {
    return RedeemResult(
      success: json['success'] == true,
      pointsRedeemed: _asInt(json['pointsRedeemed']),
      discountApplied: _asDouble(json['discountApplied']),
      newBalance: _asInt(json['newBalance']),
      newTotal: _asDouble(json['newTotal']),
    );
  }
}

// ── Service ───────────────────────────────────────────────────────────────────

class LoyaltyService {
  final ApiClient apiClient;

  const LoyaltyService({required this.apiClient});

  /// GET /api/customer/loyalty
  /// Returns the customer's current balance and recent transactions.
  Future<LoyaltyBalance> getLoyaltyBalance() async {
    try {
      final response = await apiClient.get('/customer/loyalty');
      return LoyaltyBalance.fromJson(response);
    } on ApiException catch (e) {
      throw LoyaltyException(e.message);
    }
  }

  /// POST /api/orders/:orderId/redeem-loyalty
  /// Deducts [cheapestItemPrice] points from the customer's balance and
  /// applies that amount as a discount on the order.
  Future<RedeemResult> redeemLoyalty(
    String orderId,
    double cheapestItemPrice,
  ) async {
    try {
      final response = await apiClient.post(
        '/orders/$orderId/redeem-loyalty',
        {'cheapestItemPrice': cheapestItemPrice},
      );
      return RedeemResult.fromJson(response);
    } on ApiException catch (e) {
      throw LoyaltyException(e.message);
    }
  }
}

// ── Exception ─────────────────────────────────────────────────────────────────

class LoyaltyException implements Exception {
  final String message;
  const LoyaltyException(this.message);

  @override
  String toString() => 'LoyaltyException: $message';
}

// ── Private helpers ───────────────────────────────────────────────────────────

int _asInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

double _asDouble(dynamic value, {double fallback = 0}) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? fallback;
}

DateTime _asDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString()) ?? DateTime.now();
}
