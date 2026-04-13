import 'package:flutter/material.dart';

import '../../models/delivery_address.dart';
import '../../services/address_service.dart';
import 'add_address_screen.dart';

class AddressPickerSheet extends StatefulWidget {
  final DeliveryAddress? selected;
  final Function(DeliveryAddress) onSelected;

  const AddressPickerSheet({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<AddressPickerSheet> createState() => _AddressPickerSheetState();
}

class _AddressPickerSheetState extends State<AddressPickerSheet> {
  static const _green = Color(0xFF1E5C3A);

  List<DeliveryAddress> get _addresses => AddressService().addresses;

  // Navigate to AddAddressScreen and handle result
  Future<void> _goToAddAddress() async {
    final result = await Navigator.of(context).push<DeliveryAddress>(
      MaterialPageRoute(builder: (_) => const AddAddressScreen()),
    );
    if (result != null && mounted) {
      setState(() {});          // refresh list
      widget.onSelected(result);
      if (mounted) Navigator.of(context).pop();
    }
  }

  IconData _iconForType(AddressType type) {
    switch (type) {
      case AddressType.home:
        return Icons.home_rounded;
      case AddressType.work:
        return Icons.work_rounded;
      case AddressType.other:
        return Icons.location_pin;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ─────────────────────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDD9D3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // ── Header ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Choose a delivery address',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1C1A17),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0EFEB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: Color(0xFF6A6865)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0EFEB)),

          // ── Add New Address ────────────────────────────────────────────
          InkWell(
            onTap: _goToAddAddress,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _green.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: _green, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Add New Address',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0EFEB)),

          // ── Saved addresses list ───────────────────────────────────────
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: _addresses.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const ClampingScrollPhysics(),
                    itemCount: _addresses.length,
                    separatorBuilder: (_, i2) => const Divider(
                        height: 1, indent: 72, color: Color(0xFFF0EFEB)),
                    itemBuilder: (_, i) => _buildAddressTile(_addresses[i]),
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAddressTile(DeliveryAddress addr) {
    final isSelected = widget.selected?.id == addr.id;
    return InkWell(
      onTap: () {
        AddressService().selectAddress(addr);
        widget.onSelected(addr);
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? _green.withValues(alpha: 0.12)
                    : const Color(0xFFF3F2EE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconForType(addr.type),
                color: isSelected ? _green : const Color(0xFF6A6865),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    addr.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? _green : const Color(0xFF1C1A17),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    addr.shortAddress,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7A7670),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Chevron / check
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: _green, size: 20)
            else
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFFB0AEAA), size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.location_off_outlined,
                size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            const Text('No saved addresses',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9A9690))),
          ],
        ),
      ),
    );
  }
}
