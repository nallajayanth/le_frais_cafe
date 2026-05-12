import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';

/// WebSocket Service for real-time order tracking
class WebSocketService extends ChangeNotifier {
  static const String wsBaseUrl = 'wss://le-frais-backend.onrender.com/api';

  WebSocketChannel? _channel;
  String? _currentOrderId;
  Map<String, dynamic>? _lastStatusUpdate;

  bool get isConnected => _channel != null;
  String? get currentOrderId => _currentOrderId;
  Map<String, dynamic>? get lastStatusUpdate => _lastStatusUpdate;

  /// Parsed status from the last message
  String? get currentStatus => _lastStatusUpdate?['status'] as String?;

  /// Connect to order WebSocket for real-time tracking
  Future<void> connectToOrder(String orderId, String authToken) async {
    try {
      if (isConnected && _currentOrderId == orderId) return;
      if (isConnected) await disconnect();

      final wsUrl = Uri.parse(
        '$wsBaseUrl/orders/$orderId/stream?token=$authToken',
      );
      _channel = WebSocketChannel.connect(wsUrl);
      _currentOrderId = orderId;

      _channel?.stream.listen(_onMessage, onError: _onError, onDone: _onDone);

      if (kDebugMode) print('WS connected: $orderId');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('WS connect error: $e');
      rethrow;
    }
  }

  /// Handle incoming messages — server sends { type, orderId, status, statusUpdatedAt }
  void _onMessage(dynamic message) {
    try {
      final parsed = jsonDecode(message as String) as Map<String, dynamic>;
      _lastStatusUpdate = parsed;
      if (kDebugMode) print('WS message: $parsed');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('WS parse error: $e');
    }
  }

  void _onError(Object error) {
    if (kDebugMode) print('WS error: $error');
    notifyListeners();
  }

  void _onDone() {
    if (kDebugMode) print('WS closed');
    _channel = null;
    _currentOrderId = null;
    notifyListeners();
  }

  void sendMessage(Map<String, dynamic> data) {
    if (!isConnected) throw Exception('WebSocket not connected');
    _channel?.sink.add(jsonEncode(data));
  }

  Future<void> disconnect() async {
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _currentOrderId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
