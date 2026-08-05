#!/bin/zsh
set -euo pipefail

DEVICE_ID="${SIMULATOR_ID:-}"
OUTPUT_DIR="${1:-AppStoreConnectScreenshots}"

if [[ -z "$DEVICE_ID" ]]; then
  echo "Set SIMULATOR_ID to an available iOS Simulator device ID." >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
open -a Simulator

echo "Install the app, navigate to each store state, then capture with:"
echo "xcrun simctl io $DEVICE_ID screenshot $OUTPUT_DIR/01-state.png"
