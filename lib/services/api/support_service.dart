import 'api_client.dart';

/// Support Service - Create and manage support tickets
class SupportService {
  final ApiClient apiClient;

  SupportService({required this.apiClient});

  /// Create a new support ticket
  Future<SupportTicket> createTicket({
    required String subject,
    required String message,
    required String category, // ORDER, PAYMENT, DELIVERY, GENERAL
    String? orderId,
  }) async {
    try {
      final body = <String, dynamic>{
        'subject': subject,
        'message': message,
        'category': category,
        if (orderId != null && orderId.isNotEmpty) 'orderId': orderId,
      };
      final response = await apiClient.post('/support/tickets', body);
      return SupportTicket.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      throw SupportException(e.message);
    }
  }

  /// Get all tickets for current customer
  Future<List<SupportTicket>> getTickets() async {
    try {
      final response = await apiClient.get('/support/tickets');
      return (response['data'] as List)
          .map((t) => SupportTicket.fromJson(t as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      throw SupportException(e.message);
    }
  }

  /// Get single ticket with responses
  Future<SupportTicketDetail> getTicket(String ticketId) async {
    try {
      final response = await apiClient.get('/support/tickets/$ticketId');
      return SupportTicketDetail.fromJson(
        response['data'] as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      throw SupportException(e.message);
    }
  }

  /// Reply to a ticket
  Future<void> replyToTicket(String ticketId, String message) async {
    try {
      await apiClient.post('/support/tickets/$ticketId/reply', {
        'message': message,
      });
    } on ApiException catch (e) {
      throw SupportException(e.message);
    }
  }

  /// Close a ticket
  Future<void> closeTicket(String ticketId) async {
    try {
      await apiClient.put('/support/tickets/$ticketId/close', {});
    } on ApiException catch (e) {
      throw SupportException(e.message);
    }
  }
}

class SupportTicket {
  final String id;
  final String subject;
  final String category;
  final String status; // OPEN, IN_PROGRESS, RESOLVED, CLOSED
  final String? orderId;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupportTicket({
    required this.id,
    required this.subject,
    required this.category,
    required this.status,
    this.orderId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['_id'] ?? json['id'] ?? '',
      subject: json['subject'] ?? '',
      category: json['category'] ?? 'GENERAL',
      status: json['status'] ?? 'OPEN',
      orderId: json['orderId'] ?? json['order_id'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isOpen => status == 'OPEN' || status == 'IN_PROGRESS';
}

class SupportResponse {
  final String id;
  final String message;
  final bool isStaff;
  final DateTime createdAt;

  SupportResponse({
    required this.id,
    required this.message,
    required this.isStaff,
    required this.createdAt,
  });

  factory SupportResponse.fromJson(Map<String, dynamic> json) {
    return SupportResponse(
      id: json['_id'] ?? json['id'] ?? '',
      message: json['message'] ?? '',
      isStaff: json['isStaff'] ?? json['is_staff'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class SupportTicketDetail {
  final SupportTicket ticket;
  final List<SupportResponse> responses;

  SupportTicketDetail({required this.ticket, required this.responses});

  factory SupportTicketDetail.fromJson(Map<String, dynamic> json) {
    final t = json['ticket'] ?? json;
    final r = json['responses'] as List? ?? [];
    return SupportTicketDetail(
      ticket: SupportTicket.fromJson(t as Map<String, dynamic>),
      responses: r
          .map((x) => SupportResponse.fromJson(x as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SupportException implements Exception {
  final String message;
  SupportException(this.message);
  @override
  String toString() => 'SupportException: $message';
}
