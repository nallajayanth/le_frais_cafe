import 'package:flutter/material.dart';
import '../services/api/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService notificationService;

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  NotificationProvider({required this.notificationService});

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _notifications = await notificationService.getNotifications();
    } on NotificationException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markRead(String notificationId) async {
    try {
      await notificationService.markRead(notificationId);
      final idx = _notifications.indexWhere((n) => n.id == notificationId);
      if (idx >= 0) {
        final old = _notifications[idx];
        _notifications[idx] = AppNotification(
          id: old.id,
          customerId: old.customerId,
          title: old.title,
          body: old.body,
          type: old.type,
          orderId: old.orderId,
          isRead: true,
          createdAt: old.createdAt,
        );
        notifyListeners();
      }
      return true;
    } on NotificationException catch (e) {
      _error = e.message;
      return false;
    }
  }

  Future<bool> markAllRead() async {
    try {
      await notificationService.markAllRead();
      _notifications = _notifications.map((n) {
        return AppNotification(
          id: n.id,
          customerId: n.customerId,
          title: n.title,
          body: n.body,
          type: n.type,
          orderId: n.orderId,
          isRead: true,
          createdAt: n.createdAt,
        );
      }).toList();
      notifyListeners();
      return true;
    } on NotificationException catch (e) {
      _error = e.message;
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
