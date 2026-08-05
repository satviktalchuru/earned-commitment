#!/bin/zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HANDOFF="$ROOT/Handoff/Earned Commitment"

mkdir -p "$HANDOFF"
rm -rf "$HANDOFF/App" "$HANDOFF/Tests" "$HANDOFF/GoalPenalty" "$HANDOFF/GoalPenaltyTests" "$HANDOFF/GoalPenalty.xcodeproj" "$HANDOFF/GoalPenaltyAppSpec.md" "$HANDOFF/GoalPenaltyDesignerHandoff.md" "$HANDOFF/.DS_Store"
cp -R "$ROOT/App" "$HANDOFF/App"
cp -R "$ROOT/Tests" "$HANDOFF/Tests"
cp "$ROOT/project.yml" "$HANDOFF/project.yml"
cp "$ROOT/README.md" "$HANDOFF/README.md"
cp "$ROOT/Docs/Architecture.md" "$HANDOFF/ARCHITECTURE.md"
cp "$ROOT/Docs/ReleaseChecklist.md" "$HANDOFF/RELEASE_CHECKLIST.md"
rm -rf "$HANDOFF/AppStoreConnectMetadata"
cp -R "$ROOT/AppStoreConnectMetadata" "$HANDOFF/AppStoreConnectMetadata"
cp "$ROOT/Docs/PrivacyPolicy.md" "$HANDOFF/PrivacyPolicy.md"
cp "$ROOT/AppStoreConnectMetadata/ListingDraft.md" "$HANDOFF/AppStoreConnectListingDraft.md"
rm -rf "$HANDOFF/scripts"
mkdir -p "$HANDOFF/scripts"
cp "$ROOT/scripts/capture_app_screenshots.sh" "$HANDOFF/scripts/capture_app_screenshots.sh"

(cd "$HANDOFF" && xcodegen generate)
echo "Synced $HANDOFF"
