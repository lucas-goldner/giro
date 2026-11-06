/// Which 3D model stands at a saved spot, picked from its name.
///
/// Giro has no building-type data for spots, only what the user typed, so
/// this is keyword matching tuned for Tokyo: famous towers by name, shrines
/// and temples by the usual suffixes, and a gold beacon for everything else.
enum LandmarkModel {
  tokyoTower,
  skytree,
  torii,
  pagoda,
  dome,
  beacon;

  /// Key of the mesh in `SceneryMesh.of`.
  String get meshKey => 'landmark.$name';

  static LandmarkModel forName(String name) {
    final n = name.toLowerCase();
    if (n.contains('tokyo tower') || n.contains('東京タワー')) {
      return tokyoTower;
    }
    if (n.contains('skytree') ||
        n.contains('sky tree') ||
        n.contains('スカイツリー')) {
      return skytree;
    }
    if (n.contains('dome') || n.contains('ドーム')) {
      return dome;
    }
    // Strong temple words first: "Taishakuten" contains "taisha".
    const temple = ['temple', 'taishakuten', 'kannon', '寺', '-dera', ' dera'];
    if (temple.any(n.contains)) {
      return pagoda;
    }
    const shrine = [
      'shrine',
      'jingu',
      'jingū',
      'jinja',
      'myojin',
      'myōjin',
      'tenjin',
      'taisha',
      'hachiman',
      'inari',
      'gongen',
      '神社',
      '神宮',
    ];
    if (shrine.any(n.contains)) {
      return torii;
    }
    // "-ji" / "-in" endings are temples (Sensō-ji, Zōjō-ji, Kōenji).
    if (RegExp(r'[a-zō]{3,}-?ji$').hasMatch(n) || n.endsWith('-in')) {
      return pagoda;
    }
    return beacon;
  }
}
