import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/model/walk_route.dart';

class RouteCard extends StatelessWidget {
  const RouteCard(
    this.route, {
    required this.onSelected,
    required this.onDelete,
    super.key,
  });

  final WalkRoute route;
  final void Function(WalkRoute) onSelected;
  final void Function(WalkRoute) onDelete;

  @override
  Widget build(BuildContext context) => Slidable(
        key: ValueKey(route.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          dismissible: DismissiblePane(
            onDismissed: () => onDelete(route),
          ),
          children: [
            SlidableAction(
              onPressed: (_) => onDelete(route),
              backgroundColor: const Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: ListTile(
          title: Text(
            'Route: ${route.startDate.toLocalizedString(context)}',
          ),
          subtitle: Text(
            'Duration: ${route.duration.toLocalizedString(context)}',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => onSelected(route),
          ),
          onTap: () => onSelected(route),
        ),
      );
}
