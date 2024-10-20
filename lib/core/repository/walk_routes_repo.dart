import 'package:giro/core/model/walk_route.dart';

abstract class WalkRoutesRepo {
  Future<void> init();
  void addRoute(WalkRoute route);
  void removeRouteById(String id);
  List<WalkRoute> getRoutes();
  void clearAll();
}
