enum Flavor { dev, prod }

class FlavorConfig {
  factory FlavorConfig({
    required Flavor flavor,
    String name = '',
  }) =>
      _instance ??= FlavorConfig._internal(flavor, name);

  FlavorConfig._internal(
    this.flavor,
    this.name,
  );

  final Flavor flavor;
  final String name;

  static FlavorConfig? _instance;

  static FlavorConfig get instance {
    if (_instance == null) {
      throw Exception(
        'FlavorConfig is not initialized. Please initialize it',
      );
    }
    return _instance!;
  }

  static bool isProd() => instance.flavor == Flavor.prod;
  static bool isDev() => instance.flavor == Flavor.dev;
}
