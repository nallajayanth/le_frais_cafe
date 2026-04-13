import '../models/delivery_address.dart';

/// Singleton address store — persists across widget rebuilds.
class AddressService {
  static final AddressService _instance = AddressService._internal();
  factory AddressService() => _instance;

  AddressService._internal() {
    _addresses = [
      const DeliveryAddress(
        id: '1',
        label: 'HOME',
        type: AddressType.home,
        fullAddress: '12, MG Road, Bengaluru, Karnataka 560001',
        detectedAddress: '12, MG Road, Bengaluru, Karnataka 560001',
        landmark: 'Near Metro Station',
        lat: 12.9719,
        lng: 77.5937,
      ),
      const DeliveryAddress(
        id: '2',
        label: 'WORK',
        type: AddressType.work,
        fullAddress: '5th Floor, Prestige Tech Hub, Whitefield, Bengaluru 560066',
        detectedAddress: 'Prestige Tech Hub, Whitefield, Bengaluru 560066',
        landmark: 'ITPL Signal',
        lat: 12.9699,
        lng: 77.7499,
      ),
    ];
    _selected = _addresses.first;
  }

  late List<DeliveryAddress> _addresses;
  DeliveryAddress? _selected;

  List<DeliveryAddress> get addresses => List.unmodifiable(_addresses);
  DeliveryAddress? get selectedAddress => _selected;

  void addAddress(DeliveryAddress address) {
    _addresses.add(address);
    _selected = address;
  }

  void selectAddress(DeliveryAddress address) {
    _selected = address;
  }

  void removeAddress(String id) {
    _addresses.removeWhere((a) => a.id == id);
    if (_selected?.id == id) {
      _selected = _addresses.isNotEmpty ? _addresses.first : null;
    }
  }
}
