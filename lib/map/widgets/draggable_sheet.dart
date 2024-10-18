import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:giro/core/extensions.dart';

class DraggableSheet extends StatefulWidget {
  const DraggableSheet({
    required this.children,
    super.key,
  });
  final List<Widget> children;

  @override
  State<DraggableSheet> createState() => _DraggableSheetState();
}

class _DraggableSheetState extends State<DraggableSheet> {
  double _sheetPosition = 0.4;
  final double _dragSensitivity = 600;

  bool get _isOnDesktopAndWeb {
    if (kIsWeb) {
      return true;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return true;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  void _onVerticalDrag(DragUpdateDetails details) {
    setState(() {
      _sheetPosition -= details.delta.dy / _dragSensitivity;
      if (_sheetPosition < 0.25) {
        _sheetPosition = 0.25;
      }
      if (_sheetPosition > 1.0) {
        _sheetPosition = 1.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
        initialChildSize: _sheetPosition,
        builder: (context, scrollController) => ColoredBox(
          color: context.colorScheme.surface,
          child: Column(
            children: <Widget>[
              Grabber(
                onVerticalDragUpdate: _onVerticalDrag,
              ),
              Flexible(
                child: ListView(
                  controller: _isOnDesktopAndWeb ? null : scrollController,
                  children: widget.children,
                ),
              ),
            ],
          ),
        ),
      );
}

class Grabber extends StatelessWidget {
  const Grabber({
    required this.onVerticalDragUpdate,
    super.key,
  });

  final ValueChanged<DragUpdateDetails> onVerticalDragUpdate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onVerticalDragUpdate: onVerticalDragUpdate,
      child: ColoredBox(
        color: colorScheme.onSurface,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
