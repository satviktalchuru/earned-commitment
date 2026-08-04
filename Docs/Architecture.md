# Earned Commitment Architecture

## Product boundary

Earned Commitment is a device-local SwiftUI app. It has no account, backend, analytics SDK, or social verification. The user owns the commitment and confirms completion; notifications are reminders only.

## State and persistence

`GoalRecord` stores the current state of each commitment. `GoalStateMachine` is the only domain boundary for transitions such as completion, missed deadlines, recovery, pauses, and approved exceptions. UI code calls those transitions and then saves the model context.

`LedgerEntry` is the authoritative record of score changes. `LedgerStore.append` uses a unique event ID so retries and repeated app launches cannot apply the same penalty or recovery reward twice. The current score is derived from the starting score plus ledger deltas.

## Deadline processing

`DeadlineProcessor` runs when the app becomes active and from the background refresh task. It evaluates absolute `Date` values, changes expired goals through the state machine, appends idempotent ledger events, and refreshes notifications. Notifications never decide whether a deadline was missed.

## Recovery

Recovery items restore the original penalty in parts. Integer rounding is handled by the cumulative calculation in `completeRecoveryItem`, so all recovery items together restore exactly the missed amount.

## Failure handling

Storage initialization shows a retry state. Score refresh and deadline evaluation surface a local-data error in the app. Notification scheduling failures are non-fatal because notifications are prompts rather than the source of truth.

## Testing

The domain test suite covers transitions, exact deadline expiry, idempotent deadline processing, duplicate ledger events, time zones, pause and exception rules, and proportional recovery restoration.
