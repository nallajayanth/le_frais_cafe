import 'api_client.dart';

/// Delivery Address Service - Manage delivery addresses
class DeliveryAddressService {
  final ApiClient apiClient;

  DeliveryAddressService({required this.apiClient});

  /// Get all saved addresses for customer
  Future<List<DeliveryAddress>> getAddresses() async {
    try {
      final response = await apiClient.get('/customer/addresses');
      final addresses = (response['data'] as List)
          .map((item) => DeliveryAddress.fromJson(item as Map<String, dynamic>))
          .toList();
      return addresses;
    } on ApiException catch (e) {
      throw DeliveryException(e.message);
    }
  }

  /// Get single address by ID
  Future<DeliveryAddress> getAddress(String addressId) async {
    try {
      final response = await apiClient.get('/customer/addresses/$addressId');
      return DeliveryAddress.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      throw DeliveryException(e.message);
    }
  }

  /// Create new address
  Future<DeliveryAddress> createAddress({
    required String street,
    required String city,
    required String state,
    required String zipCode,
    required double latitude,
    required double longitude,
    required String addressType, // home, work, other
    String? label,
    String? instructions,
  }) async {
    try {
      final response = await apiClient.post('/customer/addresses', {
        'street': street,
        'city': city,
        'state': state,
        'zipCode': zipCode,
        'latitude': latitude,
        'longitude': longitude,
        'addressType': addressType,
        if (label != null) 'label': label,
        if (instructions != null) 'instructions': instructions,
      });

      return DeliveryAddress.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      throw DeliveryException(e.message);
    }
  }

  /// Update existing address
  Future<DeliveryAddress> updateAddress(
    String addressId, {
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? label,
    String? instructions,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (street != null) body['street'] = street;
      if (city != null) body['city'] = city;
      if (state != null) body['state'] = state;
      if (zipCode != null) body['zipCode'] = zipCode;
      if (label != null) body['label'] = label;
      if (instructions != null) body['instructions'] = instructions;

      final response = await apiClient.put(
        '/customer/addresses/$addressId',
        body,
      );

      return DeliveryAddress.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      throw DeliveryException(e.message);
    }
  }

  /// Delete address
  Future<void> deleteAddress(String addressId) async {
    try {
      await apiClient.delete('/customer/addresses/$addressId');
    } on ApiException catch (e) {
      throw DeliveryException(e.message);
    }
  }

  /// Get delivery estimate
  Future<DeliveryEstimate> getDeliveryEstimate({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await apiClient.get(
        '/delivery/estimate?lat=$latitude&lng=$longitude',
      );

      return DeliveryEstimate.fromJson(
        response['data'] as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      throw DeliveryException(e.message);
    }
  }
}

/// Delivery Address Model
class DeliveryAddress {
  final String id;
  final String customerId;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final double latitude;
  final double longitude;
  final String addressType; // home, work, other
  final String? label;
  final String? instructions;
  final bool isDefault;
  final DateTime createdAt;

  DeliveryAddress({
    required this.id,
    required this.customerId,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
    required this.addressType,
    this.label,
    this.instructions,
    required this.isDefault,
    required this.createdAt,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      id: json['_id'] ?? json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      addressType: json['addressType'] ?? 'home',
      label: json['label'],
      instructions: json['instructions'],
      isDefault: json['isDefault'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  String get fullAddress => '$street, $city, $state $zipCode';
}

/// Delivery Estimate Model
class DeliveryEstimate {
  final double deliveryCharge;
  final int estimatedTime; // in minutes
  final double distance; // in km
  final bool isServiceable;
  final String? message;

  DeliveryEstimate({
    required this.deliveryCharge,
    required this.estimatedTime,
    required this.distance,
    required this.isServiceable,
    this.message,
  });

  factory DeliveryEstimate.fromJson(Map<String, dynamic> json) {
    return DeliveryEstimate(
      deliveryCharge: (json['deliveryCharge'] ?? 0).toDouble(),
      estimatedTime: json['estimatedTime'] ?? 30,
      distance: (json['distance'] ?? 0).toDouble(),
      isServiceable: json['isServiceable'] ?? false,
      message: json['message'],
    );
  }
}

/// Delivery Exception
class DeliveryException implements Exception {
  final String message;

  DeliveryException(this.message);

  @override
  String toString() => 'DeliveryException: $message';
}
