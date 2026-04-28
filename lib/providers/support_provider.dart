import 'package:flutter/material.dart';
import '../services/api/support_service.dart';

class SupportProvider extends ChangeNotifier {
  final SupportService supportService;

  List<SupportTicket> _tickets = [];
  SupportTicketDetail? _currentTicket;
  bool _isLoading = false;
  String? _error;

  SupportProvider({required this.supportService});

  List<SupportTicket> get tickets => _tickets;
  SupportTicketDetail? get currentTicket => _currentTicket;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> createTicket({
    required String subject,
    required String message,
    required String category,
    String? orderId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final ticket = await supportService.createTicket(
        subject: subject,
        message: message,
        category: category,
        orderId: orderId,
      );
      _tickets.insert(0, ticket);
      return true;
    } on SupportException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTickets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _tickets = await supportService.getTickets();
    } on SupportException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loadTicket(String ticketId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentTicket = await supportService.getTicket(ticketId);
      return true;
    } on SupportException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> replyToTicket(String ticketId, String message) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await supportService.replyToTicket(ticketId, message);
      await loadTicket(ticketId);
      return true;
    } on SupportException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> closeTicket(String ticketId) async {
    try {
      await supportService.closeTicket(ticketId);
      await loadTickets();
      return true;
    } on SupportException catch (e) {
      _error = e.message;
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
