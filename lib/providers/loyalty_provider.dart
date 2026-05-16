import 'package:flutter/material.dart';
import '../models/cart_entry.dart';
import '../services/api/loyalty_service.dart';

class LoyaltyProvider extends ChangeNotifier {
  final LoyaltyService loyaltyService;

  LoyaltyBalance _balance = LoyaltyBalance.empty();
  bool _isLoading = false;
  String? _error;

  LoyaltyProvider({required this.loyaltyService});

  // ── Getters ──────────────────────────────────────────────────────────────────

  LoyaltyBalance get balance => _balance;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Current points as an integer.
  int get points => _balance.points;

  /// Redemption value in rupees (1 point = ₹1).
  double get value => _balance.value;

  // ── Actions ──────────────────────────────────────────────────────────────────

  /// Load the customer's loyalty balance from the backend.
  Future<void> loadBalance() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _balance = await loyaltyService.getLoyaltyBalance();
      _error = null;
    } on LoyaltyException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Finds the cheapest item in [items] and redeems the matching points on the
  /// given [orderId], provided the customer has enough balance.
  ///
  /// Returns `true` on success. On failure sets [error] and returns `false`.
  Future<bool> redeemForCheapestItem(
    List<CartEntry> items,
    String orderId,
  ) async {
    if (items.isEmpty) {
      _error = 'No items in cart';
      notifyListeners();
      return false;
    }

    // Find cheapest unit price across all cart entries
    final cheapestPrice = items
        .map((e) => e.price)
        .reduce((a, b) => a < b ? a : b);

    final pointsNeeded = cheapestPrice.ceil();

    if (_balance.points < pointsNeeded) {
      _error =
          'Insufficient points. You have ${_balance.points} pt${_balance.points == 1 ? '' : 's'}, need $pointsNeeded.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await loyaltyService.redeemLoyalty(orderId, cheapestPrice);

      // Update local balance optimistically using returned value
      _balance = LoyaltyBalance(
        points: result.newBalance,
        value: result.newBalance.toDouble(),
        recentTransactions: _balance.recentTransactions,
      );
      _error = null;
      return true;
    } on LoyaltyException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
