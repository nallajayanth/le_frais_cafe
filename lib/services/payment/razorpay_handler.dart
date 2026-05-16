import 'dart:async';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayResult {
  final bool success;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final String? errorMessage;
  final int? errorCode;

  const RazorpayResult._({
    required this.success,
    this.paymentId,
    this.orderId,
    this.signature,
    this.errorMessage,
    this.errorCode,
  });

  factory RazorpayResult.success({
    required String paymentId,
    required String orderId,
    required String signature,
  }) => RazorpayResult._(
        success: true,
        paymentId: paymentId,
        orderId: orderId,
        signature: signature,
      );

  factory RazorpayResult.failure({
    required String message,
    int? code,
  }) => RazorpayResult._(success: false, errorMessage: message, errorCode: code);
}

/// Wraps the Razorpay Flutter SDK in a Future-based API.
/// Create once per screen and call [dispose] in the State's dispose method.
class RazorpayHandler {
  late final Razorpay _razorpay;
  Completer<RazorpayResult>? _completer;

  RazorpayHandler() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,   _onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  void _onSuccess(PaymentSuccessResponse response) {
    _completer?.complete(
      RazorpayResult.success(
        paymentId: response.paymentId ?? '',
        orderId:   response.orderId   ?? '',
        signature: response.signature ?? '',
      ),
    );
    _completer = null;
  }

  void _onError(PaymentFailureResponse response) {
    _completer?.complete(
      RazorpayResult.failure(
        message: response.message ?? 'Payment cancelled or failed',
        code:    response.code,
      ),
    );
    _completer = null;
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    // External wallet (e.g. Paytm) was selected — Razorpay handles the rest.
    // We don't complete here; wait for success/error callback.
  }

  /// Opens the Razorpay checkout UI and returns a Future that resolves
  /// when the user either completes or cancels payment.
  Future<RazorpayResult> open({
    required String keyId,
    required String razorpayOrderId,
    required int    amountPaise,
    String currency    = 'INR',
    String? prefillName,
    String? prefillEmail,
    String? prefillContact,
  }) {
    _completer = Completer<RazorpayResult>();

    _razorpay.open(<String, dynamic>{
      'key':       keyId,
      'amount':    amountPaise,
      'currency':  currency,
      'order_id':  razorpayOrderId,
      'name':      'Le Frais',
      'description': 'Secure Food Order Payment',
      'prefill': {
        'name':    prefillName    ?? '',
        'email':   prefillEmail   ?? '',
        'contact': prefillContact ?? '',
      },
      'theme':  {'color': '#1E5C3A'},
      'retry':  {'enabled': true, 'max_count': 3},
      'external': {
        'wallets': ['paytm', 'phonepe', 'googlepay'],
      },
    });

    return _completer!.future;
  }

  void dispose() {
    _razorpay.clear();
  }
}
