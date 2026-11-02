import 'package:flutter/material.dart';
import 'package:giro/core/model/poi.dart';
import 'package:giro/design/sonic/sonic_theme.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// "Drop a ring": name a place at [location]. Resolves with the new [POI]
/// or null when cancelled.
Future<POI?> showSonicRingDialog(BuildContext context, LatLng location) =>
    showDialog<POI>(
      context: context,
      barrierColor: SonicTheme.navy.withValues(alpha: 0.7),
      builder: (context) => _RingDialog(location: location),
    );

class _RingDialog extends StatefulWidget {
  const _RingDialog({required this.location});

  final LatLng location;

  @override
  State<_RingDialog> createState() => _RingDialogState();
}

class _RingDialogState extends State<_RingDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      return;
    }
    Navigator.of(context).pop(
      POI(name: name, coordinates: widget.location, createdAt: DateTime.now()),
    );
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 24),
    child: SonicPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              SonicRingIcon(size: 18),
              SizedBox(width: 10),
              SonicHudText('DROP A RING', size: 30),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Name this place. Rings are collected by the walks that pass them.',
            style: SonicTheme.body,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            style: const TextStyle(
              fontFamily: SonicTheme.font,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: SonicTheme.white,
            ),
            decoration: InputDecoration(
              hintText: 'Ring name',
              hintStyle: TextStyle(
                fontFamily: SonicTheme.font,
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: SonicTheme.pale.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: SonicTheme.navyDeep,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF1F3FA0),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: SonicTheme.gold, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SonicButton(
                  label: 'Cancel',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SonicButton(
                  label: 'Drop it!',
                  semanticsLabel: 'Add',
                  color: SonicTheme.gold,
                  shadow: SonicTheme.goldDeep,
                  onTap: _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
