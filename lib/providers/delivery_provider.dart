import 'package:flutter/material.dart';
import '../services/api/delivery_service.dart';

/// Delivery Address Provider - Manage delivery addresses
class DeliveryProvider extends ChangeNotifier {
  final DeliveryAddressService deliveryService;

  List<DeliveryAddress> _addresses = [];
  DeliveryAddress? _selectedAddress;
  DeliveryEstimate? _deliveryEstimate;
  bool _isLoading = false;
  String? _error;

  DeliveryProvider({required this.deliveryService});

  // Getters
  List<DeliveryAddress> get addresses => _addresses;
  DeliveryAddress? get selectedAddress => _selectedAddress;
  DeliveryEstimate? get deliveryEstimate => _deliveryEstimate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all addresses
  Future<void> loadAddresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _addresses = await deliveryService.getAddresses();

      // Select first address by default
      if (_addresses.isNotEmpty && _selectedAddress == null) {
        _selectedAddress = _addresses.first;
      }
    } on DeliveryException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new address
  Future<bool> createAddress({
    required String street,
    required String city,
    required String state,
    required String zipCode,
    required double latitude,
    required double longitude,
    required String addressType,
    String? label,
    String? instructions,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newAddress = await deliveryService.createAddress(
        street: street,
        city: city,
        state: state,
        zipCode: zipCode,
        latitude: latitude,
        longitude: longitude,
        addressType: addressType,
        label: label,
        instructions: instructions,
      );

      _addresses.add(newAddress);
      _selectedAddress = newAddress;

      _error = null;
      return true;
    } on DeliveryException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update address
  Future<bool> updateAddress(
    String addressId, {
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? label,
    String? instructions,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedAddress = await deliveryService.updateAddress(
        addressId,
        street: street,
        city: city,
        state: state,
        zipCode: zipCode,
        label: label,
        instructions: instructions,
      );

      // Update in list
      final index = _addresses.indexWhere((a) => a.id == addressId);
      if (index >= 0) {
        _addresses[index] = updatedAddress;
      }

      // Update selected address if it was the one updated
      if (_selectedAddress?.id == addressId) {
        _selectedAddress = updatedAddress;
      }

      return true;
    } on DeliveryException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete address
  Future<bool> deleteAddress(String addressId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await deliveryService.deleteAddress(addressId);

      // Remove from list
      _addresses.removeWhere((a) => a.id == addressId);

      // Clear selected if it was deleted
      if (_selectedAddress?.id == addressId) {
        _selectedAddress = _addresses.isNotEmpty ? _addresses.first : null;
      }

      return true;
    } on DeliveryException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select address
  void selectAddress(DeliveryAddress address) {
    _selectedAddress = address;
    notifyListeners();
  }

  /// Get delivery estimate
  Future<bool> getDeliveryEstimate({
    required double latitude,
    required double longitude,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _deliveryEstimate = await deliveryService.getDeliveryEstimate(
        latitude: latitude,
        longitude: longitude,
      );

      return _deliveryEstimate?.isServiceable ?? false;
    } on DeliveryException catch (e) {
      _error = e.message;
      _deliveryEstimate = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
