import 'package:flutter/material.dart';
import '../services/api/auth_service.dart';

/// Auth Provider - Manages authentication state
class AuthProvider extends ChangeNotifier {
  final AuthService authService;

  CustomerProfile? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  AuthProvider({required this.authService});

  // Getters
  CustomerProfile? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  /// Initialize auth state on app startup
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if token exists
      _isAuthenticated = authService.isAuthenticated();

      if (_isAuthenticated) {
        // Load user profile if authenticated
        _currentUser = await authService.getProfile();
      }
    } on AuthException catch (e) {
      _error = e.message;
      _isAuthenticated = false;
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Customer signup
  Future<bool> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await authService.signup(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );

      _currentUser = CustomerProfile(
        customerId: response.customerId,
        email: response.email,
        firstName: response.firstName,
        lastName: response.lastName,
        phone: response.phone,
        loyaltyPoints: 0,
        createdAt: DateTime.now(),
      );

      _isAuthenticated = true;
      _error = null;
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _isAuthenticated = false;
      _currentUser = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Customer login
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await authService.login(
        email: email,
        password: password,
      );

      _currentUser = CustomerProfile(
        customerId: response.customerId,
        email: response.email,
        firstName: response.firstName,
        lastName: response.lastName,
        phone: response.phone,
        loyaltyPoints: 0,
        createdAt: DateTime.now(),
      );

      _isAuthenticated = true;
      _error = null;
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _isAuthenticated = false;
      _currentUser = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );

      _error = null;
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await authService.logout();
      _currentUser = null;
      _isAuthenticated = false;
    } on AuthException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
