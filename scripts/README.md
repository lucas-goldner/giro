# Local TestFlight builds

`scripts/ios_testflight.sh` does what the **iOS TestFlight** workflow in
`codemagic.yaml` does, on your own Mac, so it costs no Codemagic build minutes:

1. Checks the tools: macOS, Xcode, Flutter (`stable`, as in Codemagic), and the keys.
2. Picks the build number: the latest iOS build in App Store Connect + 1, never below the one in `pubspec.yaml`.
3. `tool/fetch_maplibre_native.sh`, `flutter pub get`.
4. `flutter analyze --no-fatal-infos`, `flutter test`.
5. `flutter build ipa` for the prod flavor, signed for the App Store.
6. Uploads the `.ipa` to App Store Connect, waits for processing, expires a build that's still in beta review, and submits the new one for TestFlight beta review.
7. Posts the result to Discord.

## One-time setup
1. **Flutter.** Codemagic uses the latest `stable`; run `flutter channel stable && flutter upgrade` to match (the script only warns).
2. **Secrets:** `cp scripts/.env.example scripts/.env` and fill it in (gitignored). The values are the same as in Codemagic's the `discord` group.
3. **App Store Connect API key:**
   - Create one in App Store Connect → Users and Access → Integrations → App Store Connect API, with the **App Manager** role (one key works for all your apps).
   - Download the `.p8` once and keep it outside the repo, e.g. in `~/.appstoreconnect/private_keys/`.
   - Set `ASC_KEY_ID`, `ASC_ISSUER_ID` and `ASC_KEY_PATH`.
4. **Signing:** the project uses automatic signing (team `MGA58Y526H`). If this Mac has no App Store distribution profile yet, the script lets Xcode create one through the API key (`-allowProvisioningUpdates`).

## Usage
```bash
scripts/ios_testflight.sh                    # the full Codemagic flow
scripts/ios_testflight.sh --skip-tests       # faster, when CI already ran the checks
scripts/ios_testflight.sh --no-beta-review   # upload only; internal testers still get it
scripts/ios_testflight.sh --skip-upload --build-number 99   # just build an .ipa
scripts/ios_testflight.sh --help
```

The `.ipa` lands in `build/ios/ipa/`.

## Notes
- Both the script and Codemagic take the latest TestFlight build number + 1, so local and Codemagic builds never clash.

## Requirements
- Xcode with its command line tools: `xcodebuild`, `xcrun altool`, and the system `python3` and `openssl`.
- No Ruby, fastlane or pip packages.
