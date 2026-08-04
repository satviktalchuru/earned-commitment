#!/bin/zsh
set -euo pipefail

DEVICE_ID="${SIMULATOR_ID:-}"
OUTPUT_DIR="${1:-AppStoreConnectScreenshots}"

if [[ -z "$DEVICE_ID" ]]; then
  echo "Set SIMULATOR_ID to an available iOS Simulator device ID." >&2
  echo "Example: SIMULATOR_ID=<id> ./scripts/capture_app_screenshots.sh" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
open -a Simulator

echo "Install the signed app, navigate to each state, then run:" 
echo "  xcrun simctl io $DEVICE_ID screenshot $OUTPUT_DIR/01-state.png"
echo "Repeat for the six states in AppStoreConnectMetadata/en-US/screenshot_capture.md."
