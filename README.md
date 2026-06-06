# NextBuild

A simple macOS app for tracking feature ideas across personal apps.

## What it does

- Add apps you manage
- Track planned features per app
- Move planned features to completed with one click
- Keep completed features collapsed by default
- Show a floating widget with a few apps
- Store data locally as JSON

## Build

### Xcode app target

Open `NextBuild.xcodeproj`, select the `NextBuild` scheme, then build for `My Mac`.

```sh
xcodebuild -project NextBuild.xcodeproj -scheme NextBuild -destination 'generic/platform=macOS' build
```

### Swift Package

```sh
swift build
```

## Run

```sh
swift run NextBuild
```

## Archive For App Store

```sh
xcodebuild -project NextBuild.xcodeproj \
  -scheme NextBuild \
  -destination 'generic/platform=macOS' \
  -configuration Release \
  archive \
  -archivePath .release/NextBuild.xcarchive
```

The app stores local data under Application Support.
