import 'api_client.dart';

/// Authentication Service - Handles login, signup, token refresh
class AuthService {
  final ApiClient apiClient;

  AuthService({required this.apiClient});

  /// Customer signup
  Future<AuthResponse> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      final response = await apiClient.post('/auth/customer/register', {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
      }, requiresAuth: false);

      final data = response['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final refreshToken = data['refreshToken'] as String;

      await apiClient.setTokens(token, refreshToken);

      return AuthResponse.fromJson(data);
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  /// Customer login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.post('/auth/customer/login', {
        'email': email,
        'password': password,
      }, requiresAuth: false);

      final data = response['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final refreshToken = data['refreshToken'] as String;

      await apiClient.setTokens(token, refreshToken);

      return AuthResponse.fromJson(data);
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  /// Get current customer profile
  Future<CustomerProfile> getProfile() async {
    try {
      final response = await apiClient.get('/customer/profile');
      return CustomerProfile.fromJson(response['data']);
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  /// Update customer profile
  Future<CustomerProfile> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (firstName != null) body['firstName'] = firstName;
      if (lastName != null) body['lastName'] = lastName;
      if (phone != null) body['phone'] = phone;

      final response = await apiClient.put('/customer/profile', body);
      return CustomerProfile.fromJson(response['data']);
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await apiClient.post('/auth/logout', {});
      await apiClient.clearTokens();
    } on ApiException catch (e) {
      // Clear tokens anyway
      await apiClient.clearTokens();
    }
  }

  /// Check if user is authenticated
  bool isAuthenticated() => apiClient.getToken() != null;
}

/// Authentication Response Model
class AuthResponse {
  final String customerId;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String token;
  final String refreshToken;

  AuthResponse({
    required this.customerId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.token,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      customerId: json['customerId'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'] ?? '',
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }
}

/// Customer Profile Model
class CustomerProfile {
  final String customerId;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final int loyaltyPoints;
  final DateTime createdAt;

  CustomerProfile({
    required this.customerId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.loyaltyPoints,
    required this.createdAt,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      customerId: json['_id'] ?? json['customerId'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'] ?? '',
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

/// Auth Exception
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
