#!/usr/bin/env bash
# Builds Giro for the App Store and uploads it to TestFlight from this
# Mac: the same steps as the "iOS TestFlight" workflow in codemagic.yaml,
# without spending Codemagic build minutes.
#
#   scripts/ios_testflight.sh [options]
#
# Options:
#   --skip-tests         Don't run the analyzer and tests.
#   --skip-upload        Build the .ipa only; don't upload it.
#   --build-number N     Use N instead of the next free build number.
#   --no-beta-review     Upload, but don't submit for external beta review.
#   --no-discord         Don't post to Discord.
#   --any-flutter        Don't insist on the Flutter version Codemagic uses.
#   -h, --help           Show this help.
#
# Secrets come from scripts/.env (copy scripts/.env.example; it's gitignored)
# or from the environment. See scripts/README.md.

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# --- App config: keep in step with codemagic.yaml ------------------------------
APP_NAME="Giro"
BUNDLE_ID="com.lucas-goldner.giro"
CODEMAGIC_FLUTTER="stable"   # environment.flutter in codemagic.yaml

check_keys() {
  :
}

codemagic_steps() {
  step "Install dependencies"
  # MapLibre Native binaries for the vendored maplibre_flutter_gpu fork.
  tool/fetch_maplibre_native.sh
  $FLUTTER pub get

  if [[ $RUN_TESTS == 1 ]]; then
    step "Analyze and test"
    $FLUTTER analyze --no-fatal-infos
    $FLUTTER test
  fi
}

build_ipa() {
  # The "prod" flavor maps to Release-prod and the shared prod scheme.
  $FLUTTER build ipa --release \
    --flavor prod \
    -t lib/main_prod.dart \
    --build-number="$BUILD_NUMBER" \
    --export-options-plist="$EXPORT_OPTIONS"
}

# --- Everything below is the same in every app --------------------------------
TEAM_ID="MGA58Y526H"
FLUTTER="${FLUTTER:-flutter}"
DART="${DART:-dart}"

RUN_TESTS=1
UPLOAD=1
BETA_REVIEW=1
DISCORD=1
STRICT_FLUTTER=1
BUILD_NUMBER=""

usage() { awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; next } NR > 1 { exit }' "$0"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-tests) RUN_TESTS=0 ;;
    --skip-upload) UPLOAD=0 ;;
    --build-number) BUILD_NUMBER="${2:?--build-number needs a number}"; shift ;;
    --no-beta-review) BETA_REVIEW=0 ;;
    --no-discord) DISCORD=0 ;;
    --any-flutter) STRICT_FLUTTER=0 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 2 ;;
  esac
  shift
done

STEP="setup"
step() { STEP="$1"; printf '\n\033[1;34m▶ %s\033[0m\n' "$1"; }
warn() { printf '\033[1;33mWARNING: %s\033[0m\n' "$1"; }
fail() {
  printf '\033[1;31m%s\033[0m\n' "$1"
  trap - ERR
  notify "failed ($STEP)"
  exit 1
}

# --- Secrets ------------------------------------------------------------------
if [[ -f scripts/.env ]]; then
  set -a
  # shellcheck disable=SC1091
  source scripts/.env
  set +a
fi
export BUNDLE_ID
ASC_KEY_PATH="${ASC_KEY_PATH:-}"
ASC_KEY_PATH="${ASC_KEY_PATH/#\~/$HOME}"
export ASC_KEY_PATH

# --- Discord ------------------------------------------------------------------
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
COMMIT="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"

notify() {
  local status="$1"
  [[ $DISCORD == 1 && -n "${DISCORD_WEBHOOK_URL:-}" ]] || return 0
  local text="**${APP_NAME} iOS Build #${BUILD_NUMBER:-?}** (local) finished with status: **${status}**\nBranch: ${BRANCH}\nCommit: ${COMMIT}"
  curl -fsS -H "Content-Type: application/json" -X POST \
    -d "{\"content\": \"${text}\"}" "$DISCORD_WEBHOOK_URL" >/dev/null ||
    warn "Couldn't post to Discord."
}

on_error() {
  printf '\n\033[1;31m✖ Failed at: %s\033[0m\n' "$STEP"
  notify "failed ($STEP)"
}
trap on_error ERR

# --- Checks -------------------------------------------------------------------
step "Check the tools"
[[ "$(uname)" == "Darwin" ]] || fail "This needs a Mac with Xcode."
command -v xcodebuild >/dev/null || fail "Xcode isn't installed."
command -v "${FLUTTER%% *}" >/dev/null || fail "flutter isn't on PATH (or set FLUTTER=/path/to/flutter)."
xcodebuild -version | sed -n 1p   # not head: SIGPIPE + pipefail fails at random

flutter_info="$($FLUTTER --version --machine 2>/dev/null |
  python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["frameworkVersion"], d.get("channel", "?"))')"
have_flutter="${flutter_info% *}"
have_channel="${flutter_info#* }"
echo "Flutter $have_flutter ($have_channel)"
if [[ "$CODEMAGIC_FLUTTER" =~ ^[0-9] ]]; then
  if [[ "$have_flutter" != "$CODEMAGIC_FLUTTER" ]]; then
    msg="Codemagic builds with Flutter $CODEMAGIC_FLUTTER, this Mac has $have_flutter."
    if [[ $STRICT_FLUTTER == 1 ]]; then
      fail "$msg Install it (e.g. 'fvm install $CODEMAGIC_FLUTTER' and FLUTTER='fvm flutter'), or pass --any-flutter."
    fi
    warn "$msg"
  fi
elif [[ "$have_channel" != "$CODEMAGIC_FLUTTER" ]]; then
  warn "Codemagic builds with the latest Flutter $CODEMAGIC_FLUTTER, this Mac is on $have_channel."
fi

if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
  warn "The working tree has uncommitted changes; they go into this build."
fi

check_keys

NEEDS_ASC=0
[[ $UPLOAD == 1 || -z "$BUILD_NUMBER" ]] && NEEDS_ASC=1
if [[ $NEEDS_ASC == 1 ]]; then
  [[ -n "${ASC_KEY_ID:-}" && -n "${ASC_ISSUER_ID:-}" ]] ||
    fail "ASC_KEY_ID and ASC_ISSUER_ID are needed for the build number and the upload (or pass --build-number N --skip-upload)."
  [[ -f "$ASC_KEY_PATH" ]] || fail "No App Store Connect key at ASC_KEY_PATH='$ASC_KEY_PATH'."
fi

asc() { python3 -I "$ROOT/scripts/lib/asc.py" "$@"; }

# --- Build number -------------------------------------------------------------
step "Pick the build number"
if [[ -z "$BUILD_NUMBER" ]]; then
  # Like Codemagic: one past the latest TestFlight build, never below the
  # number in pubspec.yaml.
  BUILD_NUMBER="$(asc next-build-number)"
  PUBSPEC_BUILD=$(grep -E '^version:' pubspec.yaml | grep -oE '\+[0-9]+' | tr -d '+' || true)
  PUBSPEC_BUILD=${PUBSPEC_BUILD:-0}
  if [[ "$PUBSPEC_BUILD" -gt "$BUILD_NUMBER" ]]; then BUILD_NUMBER=$PUBSPEC_BUILD; fi
fi
[[ "$BUILD_NUMBER" =~ ^[0-9]+$ ]] || fail "Build number '$BUILD_NUMBER' isn't a number."
echo "Build number: $BUILD_NUMBER"

# --- The Codemagic steps ------------------------------------------------------
codemagic_steps

step "Build the iOS app"
mkdir -p build
EXPORT_OPTIONS="$ROOT/build/export_options.plist"
cat > "$EXPORT_OPTIONS" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key><string>app-store-connect</string>
  <key>destination</key><string>export</string>
  <key>teamID</key><string>${TEAM_ID}</string>
  <key>signingStyle</key><string>automatic</string>
  <key>uploadSymbols</key><true/>
  <key>manageAppVersionAndBuildNumber</key><false/>
</dict>
</plist>
PLIST

rm -rf build/ios/ipa
build_ok=1
build_ipa || build_ok=0

ARCHIVE="build/ios/archive/Runner.xcarchive"
if ! compgen -G "build/ios/ipa/*.ipa" >/dev/null; then
  # The archive usually works with this Mac's development signing; the export
  # can fail when the App Store profiles aren't on this Mac yet. Xcode can
  # make them itself with the App Store Connect key.
  [[ -d "$ARCHIVE" ]] || fail "flutter build ipa failed before the archive was made."
  [[ -f "$ASC_KEY_PATH" ]] || fail "The export failed. Set ASC_KEY_ID, ASC_ISSUER_ID and ASC_KEY_PATH so Xcode can fetch the App Store profiles, or open Xcode once and sign in."
  warn "The export failed (build_ok=$build_ok); retrying with Xcode's cloud signing."
  xcodebuild -exportArchive \
    -archivePath "$ARCHIVE" \
    -exportPath build/ios/ipa \
    -exportOptionsPlist "$EXPORT_OPTIONS" \
    -allowProvisioningUpdates \
    -authenticationKeyPath "$ASC_KEY_PATH" \
    -authenticationKeyID "$ASC_KEY_ID" \
    -authenticationKeyIssuerID "$ASC_ISSUER_ID"
fi
IPA="$(compgen -G "build/ios/ipa/*.ipa" | head -1)"
[[ -n "$IPA" ]] || fail "No .ipa was made."
echo "Built $IPA"

# --- Publishing ---------------------------------------------------------------
if [[ $UPLOAD == 1 ]]; then
  step "Upload to App Store Connect"
  # altool finds the key by name in ~/.appstoreconnect/private_keys.
  KEY_DIR="$HOME/.appstoreconnect/private_keys"
  KEY_FILE="$KEY_DIR/AuthKey_${ASC_KEY_ID}.p8"
  if [[ ! -f "$KEY_FILE" ]]; then
    mkdir -p "$KEY_DIR"
    cp "$ASC_KEY_PATH" "$KEY_FILE"
    chmod 600 "$KEY_FILE"
  fi
  xcrun altool --upload-app --type ios --file "$IPA" \
    --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID"

  if [[ $BETA_REVIEW == 1 ]]; then
    # submit_to_testflight + expire_build_submitted_for_review in codemagic.yaml.
    step "Submit to TestFlight beta review"
    asc wait-processing "$BUILD_NUMBER"
    asc expire-in-review || warn "Couldn't expire the build in beta review."
    asc submit-beta-review "$BUILD_NUMBER" ||
      warn "Beta review submission failed; internal testers still get the build. Submit it in App Store Connect if external testers need it."
  fi
fi

STEP="done"
notify "success"
printf '\n\033[1;32m✔ Done: build %s%s\033[0m\n' "$BUILD_NUMBER" \
  "$([[ $UPLOAD == 1 ]] && echo ' is on TestFlight' || echo " at $IPA")"
