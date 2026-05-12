import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Core API client for all backend communication
class ApiClient {
  static const String baseUrl = 'https://le-frais-backend.onrender.com/api';
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';

  // Render free tier can take ~30 s to wake from sleep.
  static const Duration _timeout = Duration(seconds: 30);

  final http.Client httpClient;
  final FlutterSecureStorage secureStorage;

  String? _authToken;
  String? _refreshToken;

  ApiClient({http.Client? httpClient, FlutterSecureStorage? secureStorage})
    : httpClient = httpClient ?? http.Client(),
      secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Initialize client by loading stored tokens
  Future<void> initialize() async {
    _authToken = await secureStorage.read(key: tokenKey);
    _refreshToken = await secureStorage.read(key: refreshTokenKey);
  }

  /// Set auth token
  Future<void> setTokens(String token, String refreshToken) async {
    _authToken = token;
    _refreshToken = refreshToken;
    await secureStorage.write(key: tokenKey, value: token);
    await secureStorage.write(key: refreshTokenKey, value: refreshToken);
  }

  /// Clear tokens on logout
  Future<void> clearTokens() async {
    _authToken = null;
    _refreshToken = null;
    await secureStorage.delete(key: tokenKey);
    await secureStorage.delete(key: refreshTokenKey);
  }

  /// Get current auth token
  String? getToken() => _authToken;

  /// Build headers with auth
  Map<String, String> _buildHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  /// Generic GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await httpClient
          .get(url, headers: _buildHeaders(includeAuth: requiresAuth))
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// Generic POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await httpClient
          .post(url,
              headers: _buildHeaders(includeAuth: requiresAuth),
              body: jsonEncode(body))
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// Generic PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await httpClient
          .put(url,
              headers: _buildHeaders(includeAuth: requiresAuth),
              body: jsonEncode(body))
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// Generic DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await httpClient
          .delete(url, headers: _buildHeaders(includeAuth: requiresAuth))
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// Handle response and check for errors
  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (kDebugMode) {
      print('API Response: ${response.statusCode} - ${response.body}');
    }

    if (response.statusCode == 401) {
      // Token expired - try to refresh
      final refreshed = await _refreshAuthToken();
      if (!refreshed) {
        throw UnauthorizedException('Authentication failed');
      }
      throw TokenExpiredException('Token expired');
    }

    if (response.statusCode == 403) {
      throw ForbiddenException('Access denied');
    }

    if (response.statusCode >= 500) {
      throw ServerException('Server error: ${response.statusCode}');
    }

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw ApiException(
          data['message'] ?? 'Unknown error',
          errorCode: data['errorCode'],
        );
      }
    } catch (e) {
      throw ApiException('Failed to parse response: $e');
    }
  }

  /// Refresh authentication token
  Future<bool> _refreshAuthToken() async {
    if (_refreshToken == null) return false;

    try {
      final url = Uri.parse('$baseUrl/auth/refresh');
      final response = await httpClient.post(
        url,
        headers: _buildHeaders(includeAuth: false),
        body: jsonEncode({'refreshToken': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newToken = data['data']['token'] as String?;
        final newRefreshToken = data['data']['refreshToken'] as String?;

        if (newToken != null && newRefreshToken != null) {
          await setTokens(newToken, newRefreshToken);
          return true;
        }
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Token refresh failed: $e');
      }
      return false;
    }
  }
}

/// Custom Exceptions
class ApiException implements Exception {
  final String message;
  final String? errorCode;

  ApiException(this.message, {this.errorCode});

  @override
  String toString() => 'ApiException: $message (Code: $errorCode)';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message) : super(errorCode: 'UNAUTHORIZED');
}

class ForbiddenException extends ApiException {
  ForbiddenException(super.message) : super(errorCode: 'FORBIDDEN');
}

class ServerException extends ApiException {
  ServerException(super.message) : super(errorCode: 'SERVER_ERROR');
}

class TokenExpiredException extends ApiException {
  TokenExpiredException(super.message) : super(errorCode: 'TOKEN_EXPIRED');
}
