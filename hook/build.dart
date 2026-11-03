// Compiles shaders/*.{vert,frag} into assets/shaderbundles/GiroShaders.shaderbundle
// with the Flutter SDK's impellerc, so the fog of war and building materials
// can be loaded with `gpu.ShaderLibrary.fromAsset`. Mirrors the build hook of
// maplibre_flutter_gpu's gpu_map_scene example.
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:hooks/hooks.dart';

const _bundleName = 'GiroShaders';

void main(List<String> args) async => await build(args, (input, output) async {
  final packageRoot = input.packageRoot;
  final impellerc = await _findImpellerc();
  final shaderDirectory = packageRoot.resolve('shaders/');
  final manifestFile = shaderDirectory.resolve(
    '$_bundleName.shaderbundle.json',
  );
  final outputDirectory = Directory.fromUri(
    packageRoot.resolve('assets/shaderbundles/'),
  );
  await outputDirectory.create(recursive: true);

  final manifest = jsonDecode(
    await File.fromUri(manifestFile).readAsString(),
  ) as Map<String, dynamic>;
  output.dependencies.add(manifestFile);
  for (final entry in manifest.values) {
    final shader = entry as Map<String, dynamic>;
    final source = shaderDirectory.resolve(shader['file'] as String);
    output.dependencies.add(source);
    shader['file'] = source.toFilePath();
  }

  final shaderLibrary = impellerc.resolve('./shader_lib');
  final outputFile = outputDirectory.uri.resolve('$_bundleName.shaderbundle');
  final result = await Process.run(impellerc.toFilePath(), [
    '--sl=${outputFile.toFilePath()}',
    '--shader-bundle=${jsonEncode(manifest)}',
    '--include=${shaderLibrary.toFilePath()}',
    '--gles-language-version=300',
  ], workingDirectory: packageRoot.toFilePath());
  if (result.exitCode != 0) {
    throw StateError(
      'Failed to build $_bundleName: ${result.stderr}\n${result.stdout}',
    );
  }
});

Future<Uri> _findImpellerc() async {
  final dartExec = Uri.file(Platform.resolvedExecutable);
  Uri? cacheDir;
  for (var i = dartExec.pathSegments.length - 1; i >= 0; i--) {
    if (dartExec.pathSegments[i] == 'dart-sdk' ||
        dartExec.pathSegments[i] == 'artifacts') {
      cacheDir = dartExec.replace(
        pathSegments: dartExec.pathSegments.sublist(0, i) + [''],
      );
      break;
    }
  }
  if (cacheDir == null) {
    throw StateError('Unable to find the Flutter SDK cache directory');
  }
  final engineArtifactsDir = cacheDir.resolve('./artifacts/engine/');
  final abi = Abi.current();
  final location = switch (Platform.operatingSystem) {
    'linux' => switch (abi) {
      Abi.linuxX64 => 'linux-x64/impellerc',
      Abi.linuxArm64 => 'linux-arm64/impellerc',
      _ => throw UnsupportedError('No impellerc for Linux $abi'),
    },
    'macos' => 'darwin-x64/impellerc',
    'windows' => switch (abi) {
      Abi.windowsX64 => 'windows-x64/impellerc.exe',
      Abi.windowsArm64 => 'windows-arm64/impellerc.exe',
      _ => throw UnsupportedError('No impellerc for Windows $abi'),
    },
    final platform => throw UnsupportedError('No impellerc for $platform'),
  };
  final impellerc = engineArtifactsDir.resolve(location);
  if (!File(impellerc.toFilePath()).existsSync()) {
    throw StateError('Unable to find impellerc at ${impellerc.toFilePath()}');
  }
  return impellerc;
}
