// Delivery address data model

enum AddressType { home, work, other }

class DeliveryAddress {
  final String id;
  final String label; // "HOME", "WORK", "OTHER"
  final AddressType type;
  final String fullAddress; // composite display address
  final String detectedAddress; // raw from reverse geocode
  final String landmark;
  final double lat;
  final double lng;

  const DeliveryAddress({
    required this.id,
    required this.label,
    required this.type,
    required this.fullAddress,
    required this.detectedAddress,
    required this.landmark,
    required this.lat,
    required this.lng,
  });

  /// Short 1-line version for address banners
  String get shortAddress {
    final parts = fullAddress.split(',');
    return parts.take(2).join(',').trim();
  }
}
