import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/map/place_namer.dart';
import 'package:giro/core/model/geo.dart';
import 'package:giro/design/sonic/sonic_theme.dart';

/// "Ueno, Taito" under a walk, from the offline tiles. Shows nothing until
/// the name is known and stays empty where no tile is stored.
class PlaceLine extends StatelessWidget {
  const PlaceLine({required this.points, super.key});

  final List<LatLng> points;

  @override
  Widget build(BuildContext context) => FutureBuilder<String?>(
    future: context.read<PlaceNamer>().nameFor(points),
    builder: (context, snapshot) {
      final name = snapshot.data;
      if (name == null) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Row(
          children: [
            const Icon(Icons.place_rounded, size: 12, color: SonicTheme.sky),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: SonicTheme.font,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  letterSpacing: 0.3,
                  color: SonicTheme.sky,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
