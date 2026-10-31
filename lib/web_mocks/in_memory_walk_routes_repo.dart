import 'package:giro/core/model/walk_route.dart';
import 'package:giro/core/repository/walk_routes_repo.dart';

/// Replaces the MMKV-backed repository where `dart:ffi` is unavailable (web)
/// or undesirable (widget tests). Data lives for the session only.
class InMemoryWalkRoutesRepo implements WalkRoutesRepo {
  InMemoryWalkRoutesRepo({Iterable<WalkRoute> seed = const []})
      : _seed = List.unmodifiable(seed);

  final List<WalkRoute> _seed;
  final Map<String, WalkRoute> _routes = {};

  @override
  Future<void> init() async {
    _routes.clear();
    _seed.forEach(addRoute);
  }

  @override
  void addRoute(WalkRoute route) {
    // Mirrors the MMKV implementation, which stores a thinned-out route.
    _routes[route.id] = WalkRoute(
      coordinates: route.shortenedCoordinates,
      startDate: route.startDate,
      endDate: route.endDate,
    );
  }

  @override
  List<WalkRoute> getRoutes() => _routes.values.toList();

  @override
  void removeRouteById(String id) => _routes.remove(id);

  @override
  void clearAll() => _routes.clear();
}
