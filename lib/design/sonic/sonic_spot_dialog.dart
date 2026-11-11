import 'package:flutter/material.dart';
import 'package:giro/core/l10n.dart';
import 'package:giro/core/model/poi.dart';
import 'package:giro/design/sonic/sonic_theme.dart';
import 'package:giro/core/model/geo.dart';

/// "Mark a spot": name a place at [location]. Resolves with the new [POI]
/// or null when cancelled.
Future<POI?> showSonicSpotDialog(BuildContext context, LatLng location) =>
    showDialog<POI>(
      context: context,
      barrierColor: SonicTheme.navy.withValues(alpha: 0.7),
      builder: (context) => _SpotDialog(location: location),
    );

class _SpotDialog extends StatefulWidget {
  const _SpotDialog({required this.location});

  final LatLng location;

  @override
  State<_SpotDialog> createState() => _SpotDialogState();
}

class _SpotDialogState extends State<_SpotDialog> {
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
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: SonicPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SonicSpotIcon(size: 18),
                const SizedBox(width: 10),
                SonicHudText(l10n.markASpot, size: 30),
              ],
            ),
            const SizedBox(height: 6),
            Text(l10n.markASpotBody, style: SonicTheme.body),
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
                hintText: l10n.spotNameHint,
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
                  borderSide: const BorderSide(
                    color: SonicTheme.gold,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SonicButton(
                    label: l10n.cancel,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SonicButton(
                    label: l10n.markIt,
                    semanticsLabel: l10n.addSemantics,
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
}
