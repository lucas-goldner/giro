# giro

Run dev

```bash
$ flutter run --flavor dev -t lib/main_dev.dart
```

Run prod

```bash
$ flutter run --flavor prod -t lib/main_prod.dart
```

## Fog of war

The map starts out white. Every walk (and every saved place) uncovers the
colourful map underneath along its path, with a soft edge, so the city fills
in as you explore it. This is `FogOfWar` in `lib/core/widgets/fog_of_war.dart`,
layered over the map by `PlatformMapView` (pass `fogOfWar: false` to opt out
on a screen). The reveal radius is in metres, so it stays consistent across
zoom levels, and the overlay follows pans and zooms through the map's camera
callbacks.

## Web preview

The app is iOS-first, but `lib/main_web.dart` runs it in a browser with the
native-only packages swapped for mocks from `lib/web_mocks/`:

| Native dependency | Web replacement |
|---|---|
| `mmkv` storage | `InMemoryWalkRoutesRepo` / `InMemoryPoiRepo` seeded with sample Tokyo walks |
| HealthKit method channel | `MockHealthkitRepo` returning canned workouts |
| `geolocator` | `MockGeolocatorPlatform` walking along a fixed loop |
| `platform_maps_flutter` map view | the real Google Maps JavaScript map via `google_maps_flutter_web` (`WebGoogleMap`); `?map=mock` switches to `MockPlatformMap`, a canvas-drawn map with markers, polylines, pan/zoom and long press |
| `map_launcher` installed apps | `MockLaunchableMapsRepo` (Apple + Google Maps "installed") |

```bash
# Interactive
$ flutter run -d chrome -t lib/main_web.dart
# Headless server (e.g. inside a container)
$ flutter run -d web-server -t lib/main_web.dart --web-port 8080
```

Append `?style=material` to the URL to see the Material variant instead of the
Cupertino one, and `?map=mock` to swap the Google map for the canvas mock.

The Maps JavaScript API is loaded in `web/index.html` without an API key, so
Google renders it dimmed with a "for development purposes only" watermark and
a dismissable warning. That is enough for checking the UI; add
`?key=YOUR_API_KEY` to the script URL for a production-quality map.

### Screenshots

`tool/web_screenshots.mjs` walks through the main screens with Playwright's
Chromium and writes PNGs to `build/web_screenshots/`:

```bash
$ flutter build web -t lib/main_web.dart
$ node tool/web_screenshots.mjs            # or --url http://localhost:8080/
```

The same mocks back the widget tests in `test/web_mocks/`, so `flutter test`
exercises the real screens on any desktop platform.
