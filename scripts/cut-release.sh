#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <version> [release notes...]" >&2
  echo "Example: $0 v1.0.1 \"Fix Desktop reveal bug\"" >&2
  exit 1
fi

VERSION="$1"
shift
NOTES="${*:-Release $VERSION}"

if [[ ! "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Version must look like vX.Y.Z (got: $VERSION)" >&2
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "Working tree has uncommitted changes — commit or stash before cutting a release." >&2
  exit 1
fi

if git rev-parse "$VERSION" >/dev/null 2>&1; then
  echo "Tag $VERSION already exists." >&2
  exit 1
fi

echo "Building release artifact..."
"$PROJECT_DIR/scripts/build-release.sh"

ZIP_PATH="$PROJECT_DIR/dist/New File.app.zip"
if [ ! -f "$ZIP_PATH" ]; then
  echo "Expected zip not found at $ZIP_PATH" >&2
  exit 1
fi

echo "Tagging $VERSION..."
git tag -a "$VERSION" -m "$NOTES"
git push origin "$VERSION"

echo "Creating GitHub release..."
gh release create "$VERSION" "$ZIP_PATH" --title "$VERSION" --notes "$NOTES"

echo "Done: release $VERSION published."
