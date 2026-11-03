#!/usr/bin/env bash
# Downloads the prebuilt MapLibre Native bridge binaries that the vendored
# packages/maplibre_flutter_gpu fork needs (iOS/macOS xcframework and Android
# jniLibs). They are too large for git, so they come from the official pub.dev
# archive of the upstream version the fork is based on.
#
# Run once after cloning (and in CI before `flutter build`):
#   tool/fetch_maplibre_native.sh
set -euo pipefail

VERSION="${MAPLIBRE_FLUTTER_GPU_VERSION:-0.2.0}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE="${ROOT}/packages/maplibre_flutter_gpu"
ARCHIVE_URL="https://pub.dev/api/archives/maplibre_flutter_gpu-${VERSION}.tar.gz"
STAMP="${PACKAGE}/darwin/maplibre_flutter_gpu/Frameworks/.version"

if [[ -f "${STAMP}" && "$(cat "${STAMP}")" == "${VERSION}" && -d "${PACKAGE}/android/src/main/jniLibs" ]]; then
  echo "MapLibre Native ${VERSION} binaries already present."
  exit 0
fi

TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

echo "Downloading maplibre_flutter_gpu ${VERSION} from pub.dev ..."
curl -fsSL "${ARCHIVE_URL}" -o "${TMP}/package.tar.gz"

echo "Extracting native binaries into packages/maplibre_flutter_gpu ..."
tar -xzf "${TMP}/package.tar.gz" -C "${TMP}" \
  darwin/maplibre_flutter_gpu/Frameworks \
  android/src/main/jniLibs

rm -rf "${PACKAGE}/darwin/maplibre_flutter_gpu/Frameworks" "${PACKAGE}/android/src/main/jniLibs"
mkdir -p "${PACKAGE}/darwin/maplibre_flutter_gpu" "${PACKAGE}/android/src/main"
mv "${TMP}/darwin/maplibre_flutter_gpu/Frameworks" "${PACKAGE}/darwin/maplibre_flutter_gpu/Frameworks"
mv "${TMP}/android/src/main/jniLibs" "${PACKAGE}/android/src/main/jniLibs"
echo "${VERSION}" > "${STAMP}"

echo "Done: $(du -sh "${PACKAGE}/darwin/maplibre_flutter_gpu/Frameworks" | cut -f1) xcframework, $(du -sh "${PACKAGE}/android/src/main/jniLibs" | cut -f1) Android libraries."
