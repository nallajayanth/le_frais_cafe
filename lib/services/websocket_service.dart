import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';

/// WebSocket Service for real-time order tracking
class WebSocketService extends ChangeNotifier {
  static const String wsBaseUrl = 'ws://localhost:4000/api';

  WebSocketChannel? _channel;
  String? _currentOrderId;
  Map<String, dynamic>? _lastStatusUpdate;

  bool get isConnected => _channel != null;
  String? get currentOrderId => _currentOrderId;
  Map<String, dynamic>? get lastStatusUpdate => _lastStatusUpdate;

  /// Connect to order WebSocket
  Future<void> connectToOrder(String orderId, String authToken) async {
    try {
      if (isConnected && _currentOrderId == orderId) {
        return; // Already connected to same order
      }

      // Disconnect if connected to different order
      if (isConnected) {
        await disconnect();
      }

      final wsUrl = Uri.parse(
        '$wsBaseUrl/orders/$orderId/stream?token=$authToken',
      );
      _channel = WebSocketChannel.connect(wsUrl);
      _currentOrderId = orderId;

      // Listen for messages
      _channel?.stream.listen(_onMessage, onError: _onError, onDone: _onDone);

      if (kDebugMode) {
        print('WebSocket connected to order: $orderId');
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('WebSocket connection error: $e');
      }
      rethrow;
    }
  }

  /// Handle incoming messages
  void _onMessage(dynamic message) {
    try {
      final data = message as String;
      if (kDebugMode) {
        print('WebSocket message: $data');
      }

      _lastStatusUpdate = {'timestamp': DateTime.now(), 'message': data};

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing WebSocket message: $e');
      }
    }
  }

  /// Handle errors
  void _onError(error) {
    if (kDebugMode) {
      print('WebSocket error: $error');
    }
    notifyListeners();
  }

  /// Handle connection close
  void _onDone() {
    if (kDebugMode) {
      print('WebSocket connection closed');
    }
    _channel = null;
    _currentOrderId = null;
    notifyListeners();
  }

  /// Send message to WebSocket
  void sendMessage(Map<String, dynamic> data) {
    if (!isConnected) {
      throw Exception('WebSocket not connected');
    }
    _channel?.sink.add(data);
  }

  /// Disconnect WebSocket
  Future<void> disconnect() async {
    try {
      await _channel?.sink.close();
      _channel = null;
      _currentOrderId = null;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error disconnecting WebSocket: $e');
      }
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
