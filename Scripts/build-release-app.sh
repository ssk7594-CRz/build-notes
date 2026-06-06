#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="NextBuild"
BUILD_DIR="$ROOT_DIR/.release"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
IDENTITY="${CODESIGN_IDENTITY:-}"

cd "$ROOT_DIR"

swift build -c release

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

cp "$ROOT_DIR/.build/release/$APP_NAME" "$MACOS_DIR/$APP_NAME"
cp "$ROOT_DIR/Config/Info.plist" "$CONTENTS_DIR/Info.plist"
printf "APPL????" > "$CONTENTS_DIR/PkgInfo"

if [[ -f "$ROOT_DIR/Assets/NextBuild.icns" ]]; then
  cp "$ROOT_DIR/Assets/NextBuild.icns" "$RESOURCES_DIR/NextBuild.icns"
fi

if [[ -n "$IDENTITY" ]]; then
  codesign --force --options runtime --entitlements "$ROOT_DIR/Config/NextBuild.entitlements" --sign "$IDENTITY" "$APP_DIR"
else
  codesign --force --entitlements "$ROOT_DIR/Config/NextBuild.entitlements" --sign - "$APP_DIR"
fi

echo "$APP_DIR"
