#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

SCHEME="newfile"
APP_NAME="New File"
DIST_DIR="$PROJECT_DIR/dist"
BUILD_DIR="$(mktemp -d)"

SKIP_ZIP=false
for arg in "$@"; do
  case "$arg" in
    --skip-zip)
      SKIP_ZIP=true
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      echo "Usage: $0 [--skip-zip]" >&2
      exit 1
      ;;
  esac
done

echo "Building Release configuration (unsigned)..."
xcodebuild \
  -project "newfile.xcodeproj" \
  -scheme "$SCHEME" \
  -configuration Release \
  -derivedDataPath "$BUILD_DIR" \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  clean build

APP_PATH="$BUILD_DIR/Build/Products/Release/$APP_NAME.app"

if [ ! -d "$APP_PATH" ]; then
  echo "Build failed: expected app at $APP_PATH" >&2
  exit 1
fi

mkdir -p "$DIST_DIR"

if [ "$SKIP_ZIP" = true ]; then
  rm -rf "$DIST_DIR/$APP_NAME.app"
  cp -R "$APP_PATH" "$DIST_DIR/"
  rm -rf "$BUILD_DIR"
  echo "Done: $DIST_DIR/$APP_NAME.app"
else
  ZIP_PATH="$DIST_DIR/$APP_NAME.app.zip"
  rm -f "$ZIP_PATH"

  echo "Zipping app..."
  ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_PATH"

  rm -rf "$BUILD_DIR"
  echo "Done: $ZIP_PATH"
fi
