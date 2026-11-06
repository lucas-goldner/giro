import 'dart:math' as math;
import 'dart:typed_data';

/// A minimal Mapbox Vector Tile decoder: just enough protobuf to read the
/// layers, features, properties and geometry of an OpenFreeMap tile, so
/// the scenery (trees, later more) can be generated from the same cached
/// tiles the map draws. Pure Dart, no dependencies, runs in an isolate.
class MvtTile {
  const MvtTile(this.layers);

  final Map<String, MvtLayer> layers;

  static MvtTile decode(Uint8List bytes) {
    final reader = _Reader(bytes);
    final layers = <String, MvtLayer>{};
    while (!reader.atEnd) {
      final tag = reader.varint();
      final field = tag >> 3;
      final wire = tag & 7;
      if (field == 3 && wire == 2) {
        final layer = _decodeLayer(reader.bytesField());
        layers[layer.name] = layer;
      } else {
        reader.skip(wire);
      }
    }
    return MvtTile(layers);
  }

  static MvtLayer _decodeLayer(Uint8List bytes) {
    final reader = _Reader(bytes);
    var name = '';
    var extent = 4096;
    final keys = <String>[];
    final values = <Object?>[];
    final rawFeatures = <Uint8List>[];
    while (!reader.atEnd) {
      final tag = reader.varint();
      final field = tag >> 3;
      final wire = tag & 7;
      switch (field) {
        case 1:
          name = reader.string();
        case 2:
          rawFeatures.add(reader.bytesField());
        case 3:
          keys.add(reader.string());
        case 4:
          values.add(_decodeValue(reader.bytesField()));
        case 5:
          extent = reader.varint();
        default:
          reader.skip(wire);
      }
    }
    final features = [
      for (final raw in rawFeatures) _decodeFeature(raw, keys, values),
    ];
    return MvtLayer(name: name, extent: extent, features: features);
  }

  static Object? _decodeValue(Uint8List bytes) {
    final reader = _Reader(bytes);
    Object? value;
    while (!reader.atEnd) {
      final tag = reader.varint();
      final field = tag >> 3;
      final wire = tag & 7;
      switch (field) {
        case 1:
          value = reader.string();
        case 2:
          value = reader.float32();
        case 3:
          value = reader.float64();
        case 4:
          value = reader.varint();
        case 5:
          value = reader.varint();
        case 6:
          value = _Reader.zigzag(reader.varint());
        case 7:
          value = reader.varint() != 0;
        default:
          reader.skip(wire);
      }
    }
    return value;
  }

  static MvtFeature _decodeFeature(
    Uint8List bytes,
    List<String> keys,
    List<Object?> values,
  ) {
    final reader = _Reader(bytes);
    var id = 0;
    var type = MvtGeometryType.unknown;
    final properties = <String, Object?>{};
    List<int> geometry = const [];
    while (!reader.atEnd) {
      final tag = reader.varint();
      final field = tag >> 3;
      final wire = tag & 7;
      switch (field) {
        case 1:
          id = reader.varint();
        case 2:
          final tags = reader.packedVarints();
          for (var i = 0; i + 1 < tags.length; i += 2) {
            if (tags[i] < keys.length && tags[i + 1] < values.length) {
              properties[keys[tags[i]]] = values[tags[i + 1]];
            }
          }
        case 3:
          type = MvtGeometryType.values[reader.varint().clamp(0, 3)];
        case 4:
          geometry = reader.packedVarints();
        default:
          reader.skip(wire);
      }
    }
    return MvtFeature(
      id: id,
      type: type,
      properties: properties,
      parts: _decodeGeometry(geometry, type),
    );
  }

  /// MoveTo / LineTo / ClosePath commands with zigzag deltas, into parts:
  /// one list of tile-unit points per line or ring.
  static List<List<MvtPoint>> _decodeGeometry(
    List<int> commands,
    MvtGeometryType type,
  ) {
    final parts = <List<MvtPoint>>[];
    var x = 0;
    var y = 0;
    var i = 0;
    List<MvtPoint>? current;
    while (i < commands.length) {
      final command = commands[i] & 7;
      final count = commands[i] >> 3;
      i++;
      switch (command) {
        case 1: // MoveTo
          for (var n = 0; n < count && i + 1 < commands.length; n++) {
            x += _Reader.zigzag(commands[i]);
            y += _Reader.zigzag(commands[i + 1]);
            i += 2;
            if (current != null && current.isNotEmpty) {
              parts.add(current);
            }
            current = [MvtPoint(x, y)];
          }
        case 2: // LineTo
          for (var n = 0; n < count && i + 1 < commands.length; n++) {
            x += _Reader.zigzag(commands[i]);
            y += _Reader.zigzag(commands[i + 1]);
            i += 2;
            current?.add(MvtPoint(x, y));
          }
        case 7: // ClosePath
          if (current != null && current.isNotEmpty) {
            parts.add(current);
            current = null;
          }
        default:
          i = commands.length;
      }
    }
    if (current != null && current.isNotEmpty) {
      parts.add(current);
    }
    return parts;
  }
}

enum MvtGeometryType { unknown, point, line, polygon }

class MvtLayer {
  const MvtLayer({
    required this.name,
    required this.extent,
    required this.features,
  });

  final String name;
  final int extent;
  final List<MvtFeature> features;
}

class MvtFeature {
  const MvtFeature({
    required this.id,
    required this.type,
    required this.properties,
    required this.parts,
  });

  final int id;
  final MvtGeometryType type;
  final Map<String, Object?> properties;

  /// Lines, or polygon rings. In the MVT spec exterior rings wind
  /// clockwise (y down) and interior rings counter-clockwise.
  final List<List<MvtPoint>> parts;

  /// Polygons as (exterior, holes) groups, in order.
  List<MvtPolygon> get polygons {
    if (type != MvtGeometryType.polygon) {
      return const [];
    }
    final result = <MvtPolygon>[];
    for (final ring in parts) {
      if (ring.length < 3) {
        continue;
      }
      if (_signedArea(ring) > 0 || result.isEmpty) {
        result.add(MvtPolygon(ring, []));
      } else {
        result.last.holes.add(ring);
      }
    }
    return result;
  }

  static double _signedArea(List<MvtPoint> ring) {
    var area = 0.0;
    for (var i = 0; i < ring.length; i++) {
      final a = ring[i];
      final b = ring[(i + 1) % ring.length];
      area += (b.x - a.x) * (b.y + a.y);
    }
    return area;
  }
}

class MvtPoint {
  const MvtPoint(this.x, this.y);

  final int x;
  final int y;
}

class MvtPolygon {
  MvtPolygon(this.exterior, this.holes);

  final List<MvtPoint> exterior;
  final List<List<MvtPoint>> holes;

  /// Bounding box in tile units.
  (int, int, int, int) get bounds {
    var minX = exterior.first.x;
    var minY = exterior.first.y;
    var maxX = minX;
    var maxY = minY;
    for (final p in exterior) {
      minX = math.min(minX, p.x);
      minY = math.min(minY, p.y);
      maxX = math.max(maxX, p.x);
      maxY = math.max(maxY, p.y);
    }
    return (minX, minY, maxX, maxY);
  }

  /// Area in tile units squared (positive).
  double get area => MvtFeature._signedArea(exterior).abs() / 2;

  bool contains(double x, double y) {
    if (!_inRing(exterior, x, y)) {
      return false;
    }
    for (final hole in holes) {
      if (_inRing(hole, x, y)) {
        return false;
      }
    }
    return true;
  }

  static bool _inRing(List<MvtPoint> ring, double x, double y) {
    var inside = false;
    for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      final a = ring[i];
      final b = ring[j];
      if ((a.y > y) != (b.y > y) &&
          x < (b.x - a.x) * (y - a.y) / (b.y - a.y) + a.x) {
        inside = !inside;
      }
    }
    return inside;
  }
}

class _Reader {
  _Reader(this.bytes) : _data = ByteData.sublistView(bytes);

  final Uint8List bytes;
  final ByteData _data;
  int _pos = 0;

  bool get atEnd => _pos >= bytes.length;

  int varint() {
    var result = 0;
    var shift = 0;
    while (_pos < bytes.length) {
      final byte = bytes[_pos++];
      result |= (byte & 0x7F) << shift;
      if (byte & 0x80 == 0) {
        break;
      }
      shift += 7;
    }
    return result;
  }

  static int zigzag(int value) => (value >> 1) ^ -(value & 1);

  Uint8List bytesField() {
    final length = varint();
    final view = Uint8List.sublistView(bytes, _pos, _pos + length);
    _pos += length;
    return view;
  }

  String string() => String.fromCharCodes(bytesField());

  double float32() {
    final value = _data.getFloat32(_pos, Endian.little);
    _pos += 4;
    return value;
  }

  double float64() {
    final value = _data.getFloat64(_pos, Endian.little);
    _pos += 8;
    return value;
  }

  List<int> packedVarints() {
    final length = varint();
    final end = _pos + length;
    final values = <int>[];
    while (_pos < end) {
      values.add(varint());
    }
    return values;
  }

  void skip(int wire) {
    switch (wire) {
      case 0:
        varint();
      case 1:
        _pos += 8;
      case 2:
        _pos += varint();
      case 5:
        _pos += 4;
      default:
        _pos = bytes.length;
    }
  }
}
