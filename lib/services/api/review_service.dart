import 'api_client.dart';

/// Review Service - Submit and fetch order reviews
class ReviewService {
  final ApiClient apiClient;

  ReviewService({required this.apiClient});

  /// Submit a review for a completed order
  Future<ReviewResponse> submitReview({
    required String orderId,
    required int rating, // 1-5
    String? menuItemId,
    String? title,
    String? comment,
  }) async {
    try {
      final body = <String, dynamic>{
        'rating': rating,
        if (menuItemId != null) 'menuItemId': menuItemId,
        if (title != null && title.isNotEmpty) 'title': title,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      };
      final response = await apiClient.post('/orders/$orderId/review', body);
      return ReviewResponse.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      throw ReviewException(e.message);
    }
  }

  /// Get all reviews submitted by the current customer
  Future<List<CustomerReview>> getMyReviews() async {
    try {
      final response = await apiClient.get('/customer/my-reviews');
      return (response['data'] as List)
          .map((r) => CustomerReview.fromJson(r as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      throw ReviewException(e.message);
    }
  }

  /// Get public reviews for a specific menu item
  Future<List<ItemReview>> getItemReviews(String menuItemId) async {
    try {
      final response = await apiClient.get('/reviews/menu/$menuItemId');
      return (response['data'] as List)
          .map((r) => ItemReview.fromJson(r as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      throw ReviewException(e.message);
    }
  }
}

class ReviewResponse {
  final String reviewId;
  final String message;

  ReviewResponse({required this.reviewId, required this.message});

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      reviewId: json['reviewId'] ?? json['id'] ?? '',
      message: json['message'] ?? 'Review submitted',
    );
  }
}

class CustomerReview {
  final String id;
  final String orderId;
  final String? menuItemId;
  final int rating;
  final String? title;
  final String? comment;
  final DateTime createdAt;

  CustomerReview({
    required this.id,
    required this.orderId,
    this.menuItemId,
    required this.rating,
    this.title,
    this.comment,
    required this.createdAt,
  });

  factory CustomerReview.fromJson(Map<String, dynamic> json) {
    return CustomerReview(
      id: json['_id'] ?? json['id'] ?? '',
      orderId: json['orderId'] ?? json['order_id'] ?? '',
      menuItemId: json['menuItemId'] ?? json['menu_item_id'],
      rating: json['rating'] ?? 0,
      title: json['title'],
      comment: json['comment'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Public review for a menu item (shown on the item detail screen)
class ItemReview {
  final String id;
  final String customerName; // e.g. "Ananya M."
  final int rating;
  final String? title;
  final String? comment;
  final DateTime createdAt;

  ItemReview({
    required this.id,
    required this.customerName,
    required this.rating,
    this.title,
    this.comment,
    required this.createdAt,
  });

  factory ItemReview.fromJson(Map<String, dynamic> json) {
    String name = json['customerName'] ?? json['customer_name'] ?? '';
    if (name.isEmpty) {
      final first = (json['reviewerFirstName'] ?? json['firstName'] ?? json['first_name'] ?? '') as String;
      final last = (json['lastName'] ?? json['last_name'] ?? '') as String;
      if (first.isNotEmpty) {
        name = last.isNotEmpty
            ? '$first ${last[0].toUpperCase()}.'
            : first;
      } else {
        name = 'Customer';
      }
    }
    return ItemReview(
      id: json['_id'] ?? json['id'] ?? '',
      customerName: name,
      rating: (json['rating'] ?? 0) as int,
      title: json['title'] as String?,
      comment: json['comment'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class ReviewException implements Exception {
  final String message;
  ReviewException(this.message);
  @override
  String toString() => 'ReviewException: $message';
}
