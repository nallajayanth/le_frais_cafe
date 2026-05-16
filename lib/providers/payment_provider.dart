import 'package:flutter/material.dart';
import '../services/api/payment_service.dart';

/// Payment Provider - Manages payment state
class PaymentProvider extends ChangeNotifier {
  final PaymentService paymentService;

  PaymentResponse? _currentPayment;
  PaymentStatus? _paymentStatus;
  List<DiscountCode> _availableDiscounts = [];
  DiscountResponse? _appliedDiscount;
  bool _cashPaymentConfirmed = false;
  bool _isLoading = false;
  String? _error;

  PaymentProvider({required this.paymentService});

  // Getters
  PaymentResponse? get currentPayment => _currentPayment;
  PaymentStatus? get paymentStatus => _paymentStatus;
  List<DiscountCode> get availableDiscounts => _availableDiscounts;
  DiscountResponse? get appliedDiscount => _appliedDiscount;
  bool get cashPaymentConfirmed => _cashPaymentConfirmed;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initiate payment
  Future<bool> initiatePayment({
    required String orderId,
    required double amount,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPayment = await paymentService.initiatePayment(
        orderId: orderId,
        amount: amount,
        paymentMethod: paymentMethod,
      );

      _error = null;
      return true;
    } on PaymentException catch (e) {
      _error = e.message;
      _currentPayment = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verify payment
  Future<bool> verifyPayment({
    required String paymentId,
    required String transactionId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final verification = await paymentService.verifyPayment(
        paymentId: paymentId,
        transactionId: transactionId,
      );

      if (verification.isSuccess) {
        _error = null;
        return true;
      } else {
        _error = 'Payment verification failed: ${verification.message}';
        return false;
      }
    } on PaymentException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check payment status
  Future<void> checkPaymentStatus(String paymentId) async {
    try {
      _paymentStatus = await paymentService.getPaymentStatus(paymentId);
      notifyListeners();
    } on PaymentException catch (e) {
      _error = e.message;
    }
  }

  /// Load available discounts
  Future<void> loadAvailableDiscounts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _availableDiscounts = await paymentService.getDiscounts();
    } on PaymentException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Apply discount code
  Future<bool> applyDiscount({
    required String orderId,
    required String discountCode,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _appliedDiscount = await paymentService.applyDiscount(
        orderId: orderId,
        discountCode: discountCode,
      );

      _error = null;
      return true;
    } on PaymentException catch (e) {
      _error = e.message;
      _appliedDiscount = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Confirm cash payment after order is ready/delivered
  Future<bool> confirmCashPayment({
    required String orderId,
    required double amount,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await paymentService.confirmCashPayment(orderId: orderId, amount: amount);
      _cashPaymentConfirmed = true;
      _error = null;
      return true;
    } on PaymentException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear applied discount
  void clearDiscount() {
    _appliedDiscount = null;
    notifyListeners();
  }

  /// Validate a discount code client-side against loaded discounts
  /// Returns the matching DiscountCode or null if not found/invalid.
  DiscountCode? findDiscount(String code) {
    final upper = code.trim().toUpperCase();
    return _availableDiscounts.where((d) => d.code == upper && d.isValid).firstOrNull;
  }

  /// Server-side validate: checks code + subtotal, returns DiscountValidation.
  Future<DiscountValidation?> validateDiscount({
    required String code,
    required double subtotal,
  }) async {
    try {
      return await paymentService.validateDiscount(
        code: code,
        subtotal: subtotal,
      );
    } on PaymentException {
      return null;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
