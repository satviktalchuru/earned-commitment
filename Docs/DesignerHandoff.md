# Earned Commitment

## Designer Handoff

### Product Summary

Earned Commitment is an iOS app that helps people make realistic promises and follow through. Its founding mechanic is **Commitment Capacity**: users earn the ability to make larger, longer, and lower-friction commitments by completing smaller ones consistently.

The product should feel firm, calm, and useful. It should create accountability without feeling punitive, humiliating, or gamified for its own sake.

Core positioning:

> Earn the right to promise more.

### MVP Scope

The first design pass covers:

- Today dashboard.
- Commitment Capacity card.
- New commitment flow.
- Commitment detail screen.
- Completion state.
- Missed commitment and recovery debt state.
- Recovered state.
- Basic history.

Not in the first design pass:

- Payments or financial deposits.
- Public leaderboards.
- App blocking or Screen Time controls.
- AI proof review.
- HealthKit integrations.
- Full partner onboarding.

## 1. Design Principles

### Firm, Not Hostile

The app should make consequences clear before the user commits. After failure, the interface should be direct and constructive rather than shaming.

Use:

- “Your capacity is temporarily reduced.”
- “Complete recovery to earn room for a larger promise.”
- “This goal is larger than your recent follow-through supports.”

Avoid:

- “You failed.”
- “You let yourself down.”
- “Punishment.”
- Public failure badges or humiliation mechanics.

### Operational, Not Motivational

The main screen should help users act immediately. Prioritize deadlines, required actions, proof, and recovery work over inspirational quotes, streak theatrics, or decorative illustrations.

### Consequences Should Be Useful

Every consequence should point toward the next successful action:

1. Make a promise.
2. Complete or miss it.
3. If missed, complete recovery work.
4. Earn capacity back.

### Explainability

Whenever capacity changes, show why. The user should never have to guess what caused a downgrade or how to recover.

## 2. Visual Direction

### Overall Feel

- Quiet, precise, mature, and trustworthy.
- More like a focused personal operations tool than a habit game.
- Strong hierarchy and generous spacing.
- Minimal decoration.
- Use color to communicate state, not to create constant urgency.

### Color Roles

Use a restrained neutral base with distinct semantic accents:

- Canvas: warm white or very light neutral.
- Primary text: near-black charcoal.
- Secondary text: cool gray.
- Capacity: blue or teal.
- Active commitment: blue.
- Recovery: amber.
- Completed: green.
- Destructive action: red, used sparingly.

Do not make the interface a single blue gradient or a dark “punishment” theme.

### Shape and Elevation

- Use 8pt or smaller corner radii for cards and controls.
- Avoid cards inside cards.
- Use one prominent capacity panel at the top of Today.
- Use standard iOS list rows for repeated goals.
- Use thin separators and subtle materials instead of heavy shadows.

### Typography

- Use the system font and Dynamic Type.
- Use large type only for the capacity number and screen title.
- Use semibold text for goal titles and primary actions.
- Never rely on color alone to communicate status.

## 3. Information Architecture

Recommended first-release navigation:

```text
Today
  - Capacity
  - Active commitments
  - Recovery debt
  - Recent history

Commitment detail
  - Goal
  - Deadline
  - Proof requirement
  - Status
  - Complete / I missed
  - Recovery action

New commitment
  - Promise
  - Deadline
  - Effort
  - Proof
  - Contract preview
```

Use a `NavigationStack`. The primary creation action should be visible from Today using a plus icon with an accessible label.

## 4. Screen Requirements

### 4.1 Today Dashboard

Purpose: show what requires action now and make the user's current capacity understandable.

#### Header

- Title: `Today`
- Primary action: plus icon, accessible label `New commitment`

#### Capacity Card

Required content:

- Label: `Earned Commitment`
- Capacity number, for example `50`
- Progress indicator from 0 to 100
- One-sentence explanation
- Current limits, for example `Up to 3 active goals · Effort limit 5/10`

Example default copy:

> Start with a few small promises and earn more room through follow-through.

Capacity card behavior:

- Tapping opens an explanation sheet.
- The sheet explains current score, limits, recent events, and recovery path.
- Do not make the number look like a social ranking.

#### Active Commitments Section

Each row should show:

- Status icon.
- Goal title, up to two lines.
- Deadline date and time.
- Status label: `Active` or `Recovering`.

Row interaction:

- Tapping opens Commitment Detail.
- Swipe actions should not be required for core behavior.

#### Empty State

Title: `No active commitments`

Description:

> Start with one promise you can prove.

Action: `Create commitment`

#### History Section

Show completed and recovered commitments with muted but readable styling. A recovered commitment must not look identical to a clean completion.

Suggested labels:

- `Completed`
- `Recovered`

### 4.2 New Commitment Flow

Use a sheet or full-screen cover with a clear commitment action in the navigation bar.

#### Step 1: The Promise

Fields:

- Required: `What will you finish?`
- Optional: `Details`
- Required: `Deadline`

Design requirements:

- The title prompt should produce a measurable outcome.
- Show a short inline hint, not a tutorial paragraph.

Example hint:

> Make it specific enough that you can prove it.

#### Step 2: Contract

Controls:

- Effort stepper from 1 to 10.
- Proof picker.

Proof options:

- `Self-confirmation`
- `Short note`
- `Photo or file`
- `Partner review`

Show the minimum proof level allowed by the user's current capacity. Do not hide why a stronger proof level is required.

#### Capacity Warning

When effort exceeds capacity, show an inline warning:

> This is larger than your current capacity. Reduce the effort or split it into milestones.

Offer a secondary action:

- `Split into milestones`

The user should not be able to commit an oversized goal in the MVP unless the product decision explicitly allows an override. If overrides are later added, require a stronger proof contract and clear confirmation.

#### Contract Preview

Before committing, show a compact summary:

- What will be done.
- Deadline.
- Effort.
- Proof required.
- What happens after a miss.

Example:

> If you miss this deadline, you will need to complete a recovery task before creating another ambitious goal.

Primary action: `Commit`

Secondary action: `Cancel`

### 4.3 Commitment Detail

Required sections:

- Goal title and details.
- Status.
- Deadline.
- Effort.
- Proof requirement.
- Capacity at commitment time.
- Activity or state history.

#### Active State

Primary actions:

- `Complete`
- `I missed`

The destructive action should not be visually hidden, but it should require confirmation because it creates recovery debt.

Confirmation copy:

> Mark this commitment as missed? This will create recovery work and affect your future commitment capacity.

Actions:

- `Mark as missed`
- `Keep working`

#### Completed State

Show:

- Clear completed status.
- Completion timestamp.
- Proof status.
- Capacity impact, if applicable.

Do not over-celebrate. A restrained confirmation is more consistent with the product.

#### Recovering State

Use a distinct amber recovery treatment.

Section title: `Recovery debt`

Example task:

> Write a five-minute review and choose a smaller next step.

Primary action: `Complete recovery`

Secondary information:

> Completing recovery will begin restoring your commitment capacity. The missed commitment remains in your history.

#### Recovered State

Show both facts clearly:

- `Recovered`
- `Previously missed`

This prevents recovery from erasing history while still rewarding repair.

## 5. Interaction States

Design all of these states, not just the default screen:

- First launch with no goals.
- Goal creation with empty required fields.
- Invalid or past deadline.
- Goal larger than capacity.
- Goal committed successfully.
- Goal due soon.
- Goal overdue but not yet evaluated.
- User marks goal complete.
- User confirms a miss.
- Recovery task pending.
- Recovery task completed.
- No optional permissions granted.
- SwiftData persistence failure.
- Notification scheduling failure.
- Very long goal title.
- Dynamic Type accessibility sizes.
- VoiceOver reading order.
- Dark Mode.
- iPad width and split view.

## 6. Component Inventory

Create reusable components for:

- Capacity card.
- Capacity explanation sheet.
- Goal row.
- Status icon and status label.
- Deadline display.
- Effort stepper.
- Proof picker.
- Contract preview.
- Recovery debt panel.
- Confirmation dialog.
- Empty state.
- Inline validation message.

Components should use standard SwiftUI controls where possible so focus, VoiceOver, Dynamic Type, and keyboard behavior remain predictable.

## 7. Content Guidelines

### Voice

- Direct.
- Specific.
- Nonjudgmental.
- Slightly serious.
- Focused on next action.

### Preferred Phrases

- `Earn room for a larger promise.`
- `Your current capacity supports smaller commitments.`
- `Choose proof before you commit.`
- `Recovery restores capacity.`
- `The miss stays in your history; the next action is still yours.`

### Avoid

- “Crush your goals.”
- “No excuses.”
- “Be better.”
- “Punishment.”
- “Failure rate” as the dominant label.
- Red warning language for ordinary missed goals.

## 8. Accessibility Requirements

- Support Dynamic Type without truncating goal titles or action labels.
- Provide VoiceOver labels for capacity score, progress, status, and deadline.
- Ensure buttons have a minimum 44pt hit target.
- Do not communicate state with color alone.
- Support Reduce Motion by removing capacity number animations and transitions.
- Preserve a logical focus order in forms and sheets.
- Use accessible date and time formatting.
- Test at the largest accessibility text size and with VoiceOver enabled.

## 9. Prototype Scenarios

The designer should prototype these end-to-end scenarios:

### Scenario A: First Promise

1. User opens the app with no commitments.
2. User creates “Submit my essay draft by Friday at 6 PM.”
3. User selects effort 3 and short note proof.
4. User sees the contract preview.
5. User commits.

### Scenario B: Successful Completion

1. User opens the active commitment.
2. User submits or confirms proof.
3. User taps `Complete`.
4. Dashboard shows the completed state and updated capacity.

### Scenario C: Miss and Recovery

1. User taps `I missed`.
2. Confirmation explains the consequence.
3. User sees recovery debt.
4. User completes the recovery task.
5. Dashboard shows `Recovered` and explains capacity restoration.

### Scenario D: Overpromising

1. User tries to create a goal above their effort limit.
2. The app explains the mismatch.
3. User chooses `Split into milestones`.
4. The smaller commitment is committed instead.

## 10. Design Deliverables

Please provide:

- Figma file with iPhone portrait designs.
- Light and Dark Mode.
- Empty, active, completed, recovering, and recovered states.
- Component library with variants.
- Typography and color tokens.
- Interaction prototype for the four scenarios above.
- Accessibility notes for key components.
- Exported icons or assets only where system symbols cannot be used.

## 11. Engineering Notes

The first implementation uses SwiftUI and SwiftData. The design should fit native iOS patterns and avoid interactions that require custom rendering unless they add clear value.

The current MVP does not require calendar, contacts, health, location, or photo permissions. Designs should not imply that the app can force behavior outside its own workflow. Calendar recovery blocks and partner verification will be added after the core loop is validated.

The source implementation and technical specification are in:

- `Docs/ProductSpec.md`
- `App/`
- `Tests/`
