# Earned Commitment

The canonical Xcode project is `EarnedCommitment.xcodeproj`.

The `Handoff/Earned Commitment` directory is a self-contained handoff copy for testing on another Mac. Keep source changes in the root project first, then sync the handoff copy with:

```bash
./scripts/sync_handoff_copy.sh
```

The old `GoalPenalty.xcodeproj` files are legacy generated artifacts. Do not use them for new builds.
