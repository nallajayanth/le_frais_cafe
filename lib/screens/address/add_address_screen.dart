import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../models/delivery_address.dart';
import '../../services/address_service.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  // ── Controllers ──────────────────────────────────────────────────────────
  final MapController _mapController = MapController();
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _flatCtrl = TextEditingController();
  final TextEditingController _landmarkCtrl = TextEditingController();

  // ── State ─────────────────────────────────────────────────────────────────
  LatLng _center = const LatLng(12.9716, 77.5946); // Default: Bengaluru
  String _detectedAddress = 'Fetching address…';
  String _shortAddress = '';
  bool _mapMoving = false;
  bool _loadingAddress = false;
  bool _loadingLocation = false;
  bool _isSaving = false;
  AddressType _saveAs = AddressType.home;

  List<Map<String, dynamic>> _searchResults = [];
  bool _showResults = false;

  Timer? _searchDebounce;
  Timer? _reverseDebounce;

  // ── Colours ───────────────────────────────────────────────────────────────
  static const _green = Color(0xFF1E5C3A);
  static const _cream = Color(0xFFF3F2EE);

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    // After first frame so MapController is ready
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryAutoLocation());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _flatCtrl.dispose();
    _landmarkCtrl.dispose();
    _searchDebounce?.cancel();
    _reverseDebounce?.cancel();
    super.dispose();
  }

  // ── Search logic ─────────────────────────────────────────────────────────
  void _onSearchChanged() {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) {
      setState(() {
        _searchResults = [];
        _showResults = false;
      });
      return;
    }
    _searchDebounce?.cancel();
    _searchDebounce =
        Timer(const Duration(milliseconds: 900), () => _searchPlaces(q));
  }

  Future<void> _searchPlaces(String query) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}&format=json&limit=6&addressdetails=1',
      );
      final res = await http.get(url, headers: {
        'User-Agent': 'LeFraisApp/1.0 (lefrais@mail.com)',
        'Accept-Language': 'en',
      });
      if (res.statusCode == 200 && mounted) {
        final list = json.decode(res.body) as List;
        setState(() {
          _searchResults = list.cast<Map<String, dynamic>>();
          _showResults = _searchResults.isNotEmpty;
        });
      }
    } catch (_) {}
  }

  void _selectResult(Map<String, dynamic> r) {
    final lat = double.tryParse(r['lat'] as String? ?? '') ?? 0;
    final lon = double.tryParse(r['lon'] as String? ?? '') ?? 0;
    final ll = LatLng(lat, lon);
    _searchCtrl.text = '';
    setState(() {
      _center = ll;
      _showResults = false;
      _searchResults = [];
    });
    _mapController.move(ll, 16.0);
    _reverseGeocode(ll);
    FocusScope.of(context).unfocus();
  }

  // ── Reverse geocode ───────────────────────────────────────────────────────
  Future<void> _reverseGeocode(LatLng ll) async {
    if (!mounted) return;
    setState(() => _loadingAddress = true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=${ll.latitude}&lon=${ll.longitude}&format=json',
      );
      final res = await http.get(url, headers: {
        'User-Agent': 'LeFraisApp/1.0 (lefrais@mail.com)',
        'Accept-Language': 'en',
      });
      if (res.statusCode == 200 && mounted) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final addr = (data['address'] as Map<String, dynamic>?) ?? {};
        final full = data['display_name'] as String? ?? '';
        final road = (addr['road'] ?? addr['street'] ?? '') as String;
        final suburb = (addr['suburb'] ?? addr['neighbourhood'] ?? '') as String;
        final city =
            (addr['city'] ?? addr['town'] ?? addr['village'] ?? '') as String;
        final parts = [road, suburb, city]
            .where((s) => s.isNotEmpty)
            .take(2)
            .toList();
        setState(() {
          _detectedAddress = full;
          _shortAddress =
              parts.isNotEmpty ? parts.join(', ') : full.split(',').take(2).join(',');
          _loadingAddress = false;
        });
      } else {
        if (mounted) setState(() => _loadingAddress = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingAddress = false;
          _detectedAddress = 'Unable to detect address';
          _shortAddress = 'Location selected';
        });
      }
    }
  }

  // ── Map position changed ─────────────────────────────────────────────────
  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    if (!hasGesture) return;
    if (!_mapMoving && mounted) setState(() => _mapMoving = true);
    _reverseDebounce?.cancel();
    _reverseDebounce = Timer(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _mapMoving = false);
      _center = camera.center;
      _reverseGeocode(camera.center);
    });
  }

  // ── GPS location ─────────────────────────────────────────────────────────
  Future<void> _tryAutoLocation() async {
    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.whileInUse ||
        perm == LocationPermission.always) {
      await _getCurrentLocation();
    } else {
      _reverseGeocode(_center);
    }
  }

  Future<void> _getCurrentLocation() async {
    if (mounted) setState(() => _loadingLocation = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          if (mounted) setState(() => _loadingLocation = false);
          return;
        }
      }
      if (perm == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => _loadingLocation = false);
          _showPermissionDeniedDialog();
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final ll = LatLng(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() {
          _center = ll;
          _loadingLocation = false;
        });
        _mapController.move(ll, 17.0);
        _reverseGeocode(ll);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Location Permission',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Please enable location access in app settings to detect your location automatically.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                Geolocator.openAppSettings();
              },
              child: Text('Open Settings',
                  style: TextStyle(color: _green, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  // ── Save address ──────────────────────────────────────────────────────────
  Future<void> _saveAddress() async {
    if (_loadingAddress || _detectedAddress == 'Fetching address…') {
      _showSnack('Please wait for address to be detected');
      return;
    }
    setState(() => _isSaving = true);

    final labelMap = {
      AddressType.home: 'HOME',
      AddressType.work: 'WORK',
      AddressType.other: 'OTHER',
    };
    final flat = _flatCtrl.text.trim();
    final landmark = _landmarkCtrl.text.trim();
    final composed = [
      if (flat.isNotEmpty) flat,
      _shortAddress.isNotEmpty ? _shortAddress : _detectedAddress.split(',').take(2).join(','),
      if (landmark.isNotEmpty) 'Near $landmark',
    ].join(', ');

    final addr = DeliveryAddress(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: labelMap[_saveAs]!,
      type: _saveAs,
      fullAddress: composed,
      detectedAddress: _detectedAddress,
      landmark: landmark,
      lat: _center.latitude,
      lng: _center.longitude,
    );

    AddressService().addAddress(addr);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) Navigator.of(context).pop(addr);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            // Main layout
            Column(
              children: [
                _buildSearchBar(),
                // Map area
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.44,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _center,
                          initialZoom: 15.0,
                          onPositionChanged: _onPositionChanged,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'lefrais.app',
                          ),
                        ],
                      ),
                      // Centre pin
                      Center(child: _buildPin()),
                      // Current location btn
                      Positioned(
                        bottom: 60,
                        left: 0,
                        right: 0,
                        child: Center(child: _buildCurrentLocationBtn()),
                      ),
                      // OSM attribution
                      Positioned(
                        bottom: 4,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          color: Colors.white.withValues(alpha: 0.7),
                          child: const Text('© OpenStreetMap',
                              style: TextStyle(
                                  fontSize: 8, color: Colors.black45)),
                        ),
                      ),
                    ],
                  ),
                ),
                // Pin hint + form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPinHint(),
                        const Divider(height: 1, color: Color(0xFFEEECE8)),
                        const SizedBox(height: 20),
                        _buildSectionLabel('ADDITIONAL DETAILS'),
                        const SizedBox(height: 14),
                        _buildField(
                          ctrl: _flatCtrl,
                          label: 'Flat / Floor / Block',
                          hint: 'e.g. Flat 3B, 2nd Floor',
                          icon: Icons.apartment_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          ctrl: _landmarkCtrl,
                          label: 'Landmark (optional)',
                          hint: 'e.g. Near Central Mall',
                          icon: Icons.place_outlined,
                        ),
                        const SizedBox(height: 22),
                        _buildSectionLabel('SAVE AS'),
                        const SizedBox(height: 12),
                        _buildTypeChips(),
                        const SizedBox(height: 28),
                        _buildSaveBtn(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Search results overlay ───────────────────────────────────
            if (_showResults && _searchResults.isNotEmpty)
              Positioned(
                top: 68,
                left: 0,
                right: 0,
                child: Material(
                  elevation: 10,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 260),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, i2) => const Divider(
                          height: 1, indent: 56, color: Color(0xFFEEECE8)),
                      itemBuilder: (_, i) {
                        final r = _searchResults[i];
                        final display = r['display_name'] as String? ?? '';
                        final parts = display.split(',');
                        final title = parts.take(2).join(',').trim();
                        final sub = parts.skip(2).take(2).join(',').trim();
                        return ListTile(
                          dense: true,
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _green.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.place_outlined,
                                color: _green, size: 18),
                          ),
                          title: Text(title,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          subtitle: sub.isNotEmpty
                              ? Text(sub,
                                  style: const TextStyle(
                                      fontSize: 12, color: Color(0xFF9A9690)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis)
                              : null,
                          onTap: () => _selectResult(r),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      height: 68,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _cream,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  size: 18, color: Color(0xFF1C1A17)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: _cream,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchCtrl,
                style:
                    const TextStyle(fontSize: 14, color: Color(0xFF1C1A17)),
                decoration: InputDecoration(
                  hintText: 'Search an area or address',
                  hintStyle: const TextStyle(
                      fontSize: 14, color: Color(0xFFB0AEAA)),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Color(0xFF9A9690), size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() {
                              _showResults = false;
                              _searchResults = [];
                            });
                            FocusScope.of(context).unfocus();
                          },
                          child: const Icon(Icons.close_rounded,
                              color: Color(0xFFB0AEAA), size: 18),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Centre map pin ────────────────────────────────────────────────────────
  Widget _buildPin() {
    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _green.withValues(alpha: _mapMoving ? 0.2 : 0.45),
                  blurRadius: _mapMoving ? 4 : 18,
                  spreadRadius: _mapMoving ? 0 : 2,
                ),
              ],
            ),
            child: _loadingAddress
                ? const Padding(
                    padding: EdgeInsets.all(13),
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : const Icon(Icons.location_pin,
                    color: Colors.white, size: 22),
          ),
          Container(width: 3, height: 12, color: _green),
          Container(
            width: 10,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  // ── Current location button ───────────────────────────────────────────────
  Widget _buildCurrentLocationBtn() {
    return GestureDetector(
      onTap: _getCurrentLocation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _loadingLocation
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Color(0xFF1E5C3A), strokeWidth: 2.5),
                  )
                : const Icon(Icons.my_location_rounded,
                    color: Color(0xFF1E5C3A), size: 18),
            const SizedBox(width: 8),
            const Text('Current location',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1A17),
                )),
          ],
        ),
      ),
    );
  }

  // ── Pin hint / detected address ───────────────────────────────────────────
  Widget _buildPinHint() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.09),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_pin, color: Color(0xFF1E5C3A), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PLACE THE PIN AT EXACT DELIVERY LOCATION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9A9690),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 5),
                _loadingAddress
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _shimmer(double.infinity, 13),
                          const SizedBox(height: 5),
                          _shimmer(180, 11),
                        ],
                      )
                    : Text(
                        _shortAddress.isNotEmpty
                            ? _shortAddress
                            : _detectedAddress.split(',').take(2).join(','),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1A17),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmer(double w, double h) => Container(
    height: h,
    width: w,
    decoration: BoxDecoration(
      color: const Color(0xFFEEECE8),
      borderRadius: BorderRadius.circular(6),
    ),
  );

  // ── Form field ────────────────────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7A7670),
            )),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _cream,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: ctrl,
            style: const TextStyle(fontSize: 15, color: Color(0xFF1C1A17)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Color(0xFFB0AEAA), fontSize: 14),
              prefixIcon: Icon(icon, color: const Color(0xFF9A9690), size: 20),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            ),
          ),
        ),
      ],
    );
  }

  // ── Type chips ────────────────────────────────────────────────────────────
  Widget _buildTypeChips() {
    return Row(
      children: [
        _typeChip(AddressType.home, Icons.home_rounded, 'HOME'),
        const SizedBox(width: 10),
        _typeChip(AddressType.work, Icons.work_rounded, 'WORK'),
        const SizedBox(width: 10),
        _typeChip(AddressType.other, Icons.location_pin, 'OTHER'),
      ],
    );
  }

  Widget _typeChip(AddressType type, IconData icon, String label) {
    final sel = _saveAs == type;
    return GestureDetector(
      onTap: () => setState(() => _saveAs = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? _green : _cream,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: sel ? _green : const Color(0xFFDDD9D3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 15,
                color: sel ? Colors.white : const Color(0xFF6A6865)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: sel ? Colors.white : const Color(0xFF6A6865),
                  letterSpacing: 0.5,
                )),
          ],
        ),
      ),
    );
  }

  // ── Section label ────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: Color(0xFF9A9690),
      letterSpacing: 1.2,
    ),
  );

  // ── Save button ───────────────────────────────────────────────────────────
  Widget _buildSaveBtn() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveAddress,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          elevation: 0,
          disabledBackgroundColor: const Color(0xFFB0AEAA),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : const Text('SAVE ADDRESS',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5)),
      ),
    );
  }
}
