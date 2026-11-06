import 'package:flutter_test/flutter_test.dart';
import 'package:giro/core/map/scenery/landmarks.dart';

void main() {
  test('picks models from Tokyo spot names', () {
    const cases = {
      'Tokyo Tower': LandmarkModel.tokyoTower,
      'Tokyo Skytree': LandmarkModel.skytree,
      'Tokyo Dome': LandmarkModel.dome,
      'Sensō-ji': LandmarkModel.pagoda,
      'Zōjō-ji': LandmarkModel.pagoda,
      'Gotokuji Temple': LandmarkModel.pagoda,
      'Shibamata Taishakuten': LandmarkModel.pagoda,
      'Meiji Jingū': LandmarkModel.torii,
      'Nezu Shrine': LandmarkModel.torii,
      'Kanda Myōjin': LandmarkModel.torii,
      'Kameido Tenjin': LandmarkModel.torii,
      '明治神宮': LandmarkModel.torii,
      'Shibuya Crossing': LandmarkModel.beacon,
      'Jiyūgaoka': LandmarkModel.beacon,
      'Kōenji': LandmarkModel.pagoda,
      'Ueno Park': LandmarkModel.beacon,
      'Fuji': LandmarkModel.beacon,
    };
    for (final MapEntry(key: name, value: model) in cases.entries) {
      expect(LandmarkModel.forName(name), model, reason: name);
    }
  });
}
