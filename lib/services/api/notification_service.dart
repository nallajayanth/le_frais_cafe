import 'api_client.dart';

/// Notification Service - in-app notifications + push token management
class NotificationService {
  final ApiClient apiClient;

  NotificationService({required this.apiClient});

  /// Get all notifications for current user
  Future<List<AppNotification>> getNotifications({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await apiClient.get(
        '/notifications?limit=$limit&offset=$offset',
      );
      return (response['data'] as List)
          .map((n) => AppNotification.fromJson(n as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      throw NotificationException(e.message);
    }
  }

  /// Mark a single notification as read
  Future<void> markRead(String notificationId) async {
    try {
      await apiClient.put('/notifications/$notificationId/mark-read', {});
    } on ApiException catch (e) {
      throw NotificationException(e.message);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllRead() async {
    try {
      await apiClient.put('/notifications/mark-all-read', {});
    } on ApiException catch (e) {
      throw NotificationException(e.message);
    }
  }

  /// Register push token
  Future<void> subscribePushToken({
    required String deviceToken,
    required String platform, // fcm or apns
  }) async {
    try {
      await apiClient.post('/notifications/subscribe', {
        'deviceToken': deviceToken,
        'platform': platform,
      });
    } on ApiException catch (e) {
      throw NotificationException(e.message);
    }
  }

  /// Unregister push token
  Future<void> unsubscribePushToken(String deviceToken) async {
    try {
      await apiClient.post('/notifications/unsubscribe', {
        'deviceToken': deviceToken,
      });
    } on ApiException catch (e) {
      throw NotificationException(e.message);
    }
  }
}

/// In-app Notification Model
class AppNotification {
  final String id;
  final String customerId;
  final String title;
  final String body;
  final String type; // ORDER_UPDATE, PROMOTION, SYSTEM
  final String? orderId;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.customerId,
    required this.title,
    required this.body,
    required this.type,
    this.orderId,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id'] ?? json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'SYSTEM',
      orderId: json['orderId'],
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      createdAt: DateTime.tryParse(
            json['createdAt'] ?? json['created_at'] ?? '',
          ) ??
          DateTime.now(),
    );
  }
}

class NotificationException implements Exception {
  final String message;
  NotificationException(this.message);
  @override
  String toString() => 'NotificationException: $message';
}
