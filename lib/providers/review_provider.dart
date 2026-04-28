import 'package:flutter/material.dart';
import '../services/api/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService reviewService;

  List<CustomerReview> _myReviews = [];
  bool _isLoading = false;
  String? _error;
  bool _submitted = false;

  final Map<String, List<ItemReview>> _itemReviewsCache = {};
  final Map<String, bool> _itemReviewsLoading = {};

  ReviewProvider({required this.reviewService});

  List<CustomerReview> get myReviews => _myReviews;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get submitted => _submitted;

  List<ItemReview> itemReviewsFor(String menuItemId) =>
      _itemReviewsCache[menuItemId] ?? [];

  bool isLoadingItemReviews(String menuItemId) =>
      _itemReviewsLoading[menuItemId] ?? false;

  Future<void> loadItemReviews(String menuItemId) async {
    if (_itemReviewsLoading[menuItemId] == true) return;
    _itemReviewsLoading[menuItemId] = true;
    notifyListeners();
    try {
      _itemReviewsCache[menuItemId] =
          await reviewService.getItemReviews(menuItemId);
    } on ReviewException {
      _itemReviewsCache[menuItemId] ??= [];
    } finally {
      _itemReviewsLoading[menuItemId] = false;
      notifyListeners();
    }
  }

  Future<bool> submitReview({
    required String orderId,
    required int rating,
    String? menuItemId,
    String? title,
    String? comment,
  }) async {
    _isLoading = true;
    _error = null;
    _submitted = false;
    notifyListeners();
    try {
      await reviewService.submitReview(
        orderId: orderId,
        rating: rating,
        menuItemId: menuItemId,
        title: title,
        comment: comment,
      );
      _submitted = true;
      return true;
    } on ReviewException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyReviews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _myReviews = await reviewService.getMyReviews();
    } on ReviewException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetSubmitted() {
    _submitted = false;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
