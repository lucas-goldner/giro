import 'package:flutter/cupertino.dart';
import 'package:giro/core/model/poi.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

class PoiAddDialog extends StatefulWidget {
  const PoiAddDialog({
    required this.location,
    required this.onAdd,
    required this.onCancel,
    super.key,
  });

  final LatLng location;
  final void Function(POI) onAdd;
  final VoidCallback onCancel;

  @override
  State<PoiAddDialog> createState() => _PoiAddDialogState();
}

class _PoiAddDialogState extends State<PoiAddDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => CupertinoAlertDialog(
        title: const Text('Add Point of interest'),
        content: CupertinoTextField(
          controller: _controller,
          placeholder: 'Enter name',
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: widget.onCancel,
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => widget.onAdd(
              POI(
                name: _controller.text,
                coordinates: widget.location,
                createdAt: DateTime.now(),
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      );
}
