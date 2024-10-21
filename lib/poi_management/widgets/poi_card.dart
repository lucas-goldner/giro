import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/model/poi.dart';

class PoiCard extends StatelessWidget {
  const PoiCard(
    this.poi, {
    required this.onSelected,
    required this.onDelete,
    super.key,
  });

  final POI poi;
  final void Function(POI) onSelected;
  final void Function(POI) onDelete;

  @override
  Widget build(BuildContext context) => Slidable(
        key: ValueKey(poi.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          dismissible: DismissiblePane(
            onDismissed: () => onDelete(poi),
          ),
          children: [
            SlidableAction(
              onPressed: (_) => onDelete(poi),
              backgroundColor: const Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: ListTile(
          title: Text(
            poi.name,
          ),
          subtitle: Text(
            'Created at: ${poi.createdAt.toLocalizedString(context)}',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => onSelected(poi),
          ),
          onTap: () => onSelected(poi),
        ),
      );
}
