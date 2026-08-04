# Earned Commitment iOS App Spec

## 1. Product Summary

Earned Commitment is an iOS app that helps users finish personal goals by attaching real consequences to missed commitments. Users define goals, set check-in rules, choose a penalty, and must prove completion before the deadline. If they miss or fail verification, the app automatically applies the penalty.

The core product promise: make goals harder to ignore by turning vague intention into a tracked commitment with a meaningful cost.

## 2. Target Users

- People who repeatedly set goals but fail to finish them.
- Students, founders, freelancers, athletes, and self-improvement users who respond well to accountability.
- Users who want stronger consequences than streak loss or motivational reminders.

## 3. Core Use Cases

- Commit to finishing a goal by a specific date.
- Break a goal into milestones with deadlines.
- Select a penalty that triggers when a goal or milestone is missed.
- Submit proof that a goal was completed.
- Ask a human accountability partner or AI-assisted review to verify completion.
- Track success rate, penalties avoided, and goal history.

## 4. MVP Feature Set

### 4.1 Goal Creation

Each goal includes:

- Title
- Description
- Category
- Deadline
- Optional milestones
- Required proof type
- Penalty type
- Accountability mode

Example goals:

- "Submit my college essay draft by Friday at 6 PM."
- "Run 50 miles this month."
- "Finish SwiftUI course by August 15."
- "Publish one blog post every week for 8 weeks."

### 4.2 Goal Types

- One-time goal: single deadline.
- Recurring goal: repeated daily, weekly, or monthly.
- Milestone goal: multiple checkpoints with separate deadlines.
- Habit goal: completion count over a period.

### 4.3 Penalty Types

MVP should support penalties that are enforceable, understandable, and reversible only under clear rules.

Existing commitment products already cluster around a few common punishments:

- Automatic card charges when a user misses a tracked goal.
- Charity or anti-charity forfeits.
- Referee approval or rejection.
- Photo, video, GPS, HealthKit, or Screen Time proof.
- Text, call, or email alerts to a contact.
- App and website blocking.
- Streak loss or progress badge loss.

Earned Commitment should avoid leading with those as its main differentiator. They can remain future options, but the distinctive product direction should be penalties that create useful friction, restitution, or effort rather than simple money loss or shame.

Recommended differentiated penalty system:

- Friction Debt: missing a goal creates a required effort task before the user can create another ambitious goal. Examples: write a 5-minute failure review, break the goal into smaller commitments, or schedule three concrete work blocks.
- Time Escrow: the user pre-commits a future time block. If they miss the goal, the app automatically converts the block into a recovery session and protects it on their calendar.
- Privilege Cooldown: the app temporarily removes positive features such as new goal creation, cosmetic customization, leaderboard visibility, or advanced analytics until a recovery action is completed.
- Commitment Ratchet: repeated misses reduce the maximum size of future goals until the user completes smaller commitments reliably. This penalizes overpromising instead of punishing ambition.
- Partner Task Transfer: the user owes a useful task to an accountability partner, such as reviewing their notes, helping with an errand, or contributing time to a shared project. The partner defines acceptable proof.
- Public Prediction Score: the app lowers a private or small-group reliability score based on missed commitments. This should be limited to chosen partners or teams, never public by default.
- Goal Deposit to Self: instead of losing money, the user locks money into a personal savings bucket that can only be unlocked after completing a recovery streak. This preserves loss aversion without monetizing failure.
- Default Downgrade: the failed goal is automatically rewritten into a smaller version with stricter proof and shorter deadlines. The user loses the ability to keep pretending the original plan is still active.
- Reflection Unlock: the user must complete a structured post-mortem before the failed goal can be archived. The penalty is cognitive friction, not embarrassment.
- Service Credit: the user commits to a small act of service if they miss, such as helping a friend, contributing to an open-source issue, or volunteering for a predefined local/community task.
- Focus Bond: missing a goal converts optional free time into a protected focus block. The app does not block the device globally, but it asks the user to choose from a short list of productive recovery actions.
- Evidence Upgrade: after a miss, future goals in the same category require stronger proof. Example: self-confirmation becomes photo proof; photo proof becomes partner verification.

Recommended MVP penalty mix:

- Friction Debt
- Reflection Unlock
- Evidence Upgrade
- Commitment Ratchet
- Optional Goal Deposit to Self

Avoid as MVP:

- Deep device blocking.
- Financial penalties without careful legal, payment, and refund handling.
- Public shaming mechanics.
- Automatic calls, embarrassing texts, or anti-charity flows.

Penalty design principle:

The penalty should make the next success more likely. It should not merely make the last failure hurt.

### 4.4 Proof Submission

Users must submit proof before the deadline.

Supported proof types:

- Photo
- Screenshot
- Text note
- File upload
- Location check-in
- HealthKit metric
- Calendar/event confirmation
- Manual accountability partner approval

MVP proof types:

- Text note
- Photo
- Screenshot
- Manual partner approval

### 4.5 Verification

Verification modes:

- Self-confirmed: user marks goal complete.
- Partner-verified: accountability partner approves or rejects.
- Evidence-required: user must attach proof, but the app does not judge it automatically.
- AI-assisted review: app flags weak or missing proof for human confirmation.

MVP should use partner verification for higher-stakes goals. Self-confirmed goals can exist, but they should have lighter penalties because users can bypass them.

### 4.6 Deadlines and Grace Periods

Each goal has:

- Deadline
- Optional reminder schedule
- Optional grace period
- Final verification cutoff

Default timing:

- Reminder 24 hours before deadline.
- Reminder 3 hours before deadline.
- Reminder 30 minutes before deadline.
- 15-minute grace period for submission issues.

Penalty triggers when:

- Deadline plus grace period passes.
- Required proof is missing.
- Partner rejects proof.
- User abandons the goal.

### 4.7 Recovery Tasks

Instead of only punishing failure, the app gives users a recovery path.

Examples:

- Complete a smaller version of the goal within 24 hours.
- Write a short failure review.
- Reschedule the goal with a stronger plan.
- Add an accountability partner.

Recovery tasks do not erase the missed goal, but they can reduce future penalties or restore app rewards.

## 5. User Experience

### 5.1 Main Tabs

- Today: active commitments due soon.
- Goals: all active and completed goals.
- Penalties: pending, triggered, and avoided penalties.
- Progress: stats, completion rate, streaks, trends.
- Settings: payment, partners, privacy, notifications.

### 5.2 Goal Setup Flow

1. User enters goal title and deadline.
2. User selects goal type.
3. User defines proof requirement.
4. User chooses penalty.
5. User selects verification mode.
6. App shows a final commitment screen.
7. User confirms the goal.

The final commitment screen must clearly show:

- What must be done.
- When it must be done.
- What proof is required.
- What happens if the user misses.
- Whether the penalty is automatic.

### 5.3 Today Screen

The Today screen should be operational, not motivational.

Show:

- Goals due today.
- Upcoming deadlines.
- Missing proof warnings.
- Pending partner approvals.
- Triggered penalties.
- Quick submit proof action.

### 5.4 Goal Detail Screen

Show:

- Goal status
- Deadline countdown
- Milestones
- Proof submissions
- Verification status
- Penalty terms
- Activity history
- Recovery task, if failed

Primary actions:

- Submit proof
- Mark milestone complete
- Request partner review
- Edit goal, where allowed
- Abandon goal, with penalty confirmation

## 6. Rules and Edge Cases

### 6.1 Editing Goals

Before deadline:

- User can edit title, description, reminders, and proof notes.
- User can extend deadline only if penalty rules allow it.
- Penalty strength cannot be lowered after commitment without partner approval.

After deadline:

- User cannot edit deadline.
- User can submit late proof only if late submissions are allowed.
- Failed status remains visible even after recovery.

### 6.2 Abandoning a Goal

Abandoning a goal should be treated as failure unless the goal was created recently.

Suggested rule:

- Free cancellation within 10 minutes of creation.
- After 10 minutes, abandoning triggers the selected penalty.

### 6.3 Disputes

Users need a way to dispute accidental penalties.

Supported reasons:

- Technical upload failure.
- Partner did not respond.
- Incorrect deadline/time zone issue.
- Payment issue.

Disputes should pause financial penalties until reviewed.

### 6.4 Time Zones

Store all deadlines in UTC and display in the user's current time zone. If the user travels, the app should show both original and current local deadline when relevant.

## 7. Notifications

Notification types:

- Deadline reminders
- Proof missing warnings
- Partner approval requests
- Penalty pending notice
- Penalty triggered notice
- Recovery task reminders

Notification tone should be direct and specific.

Examples:

- "Essay draft is due in 3 hours. Proof required: screenshot or file."
- "You missed your 6 PM deadline. Your penalty will trigger in 15 minutes unless proof is submitted."
- "Jordan rejected your proof. Review required."

## 8. Data Model

### 8.1 User

- id
- name
- email
- notification settings
- time zone
- payment status
- created at

### 8.2 Goal

- id
- user id
- title
- description
- category
- type
- status
- created at
- deadline at
- grace period minutes
- verification mode
- proof requirement
- penalty id

### 8.3 Milestone

- id
- goal id
- title
- status
- deadline at
- proof requirement

### 8.4 Proof

- id
- goal id
- milestone id
- submitted by
- type
- asset URL
- note
- submitted at
- verification status

### 8.5 Penalty

- id
- goal id
- type
- amount
- recipient
- status
- trigger reason
- triggered at
- dispute status

### 8.6 Accountability Partner

- id
- user id
- name
- email or phone
- relationship status
- permissions

## 9. Privacy and Safety

The app should avoid exploitative punishment mechanics.

Required safeguards:

- Clear consent before any penalty is enabled.
- No hidden fees.
- No public shaming by default.
- No penalties related to food, sleep, medication, or physical harm.
- Easy export and deletion of personal data.
- Financial penalties must have spending limits.
- Users can disable high-stakes penalties after active commitments are resolved.

Sensitive goal categories should trigger safer defaults:

- Mental health
- Medical treatment
- Addiction recovery
- Eating or weight goals
- Financial hardship

For these categories, the app should recommend supportive accountability instead of monetary or shame-based penalties.

## 10. Monetization

Possible models:

- Freemium app with limited active goals.
- Subscription for unlimited goals, partner verification, analytics, and integrations.
- Small platform fee on optional donation penalties.

Avoid monetizing failure directly in a way that encourages the app to profit from missed goals.

## 11. Technical Requirements

### 11.1 iOS

- SwiftUI
- iOS 17+
- Local notifications
- Widget support for active goals
- Live Activities for goals due soon
- Photos picker for proof uploads
- HealthKit integration in later versions

### 11.2 Backend

Required backend capabilities:

- User authentication
- Goal storage
- Proof asset storage
- Partner invitation flow
- Deadline job scheduler
- Penalty trigger worker
- Payment provider integration
- Notification delivery

Suggested stack:

- SwiftUI iOS client
- Supabase or Firebase for auth and database
- Cloud storage for proof assets
- Stripe for financial penalties
- Scheduled backend jobs for deadline enforcement

### 11.3 Offline Behavior

- Users can draft goals offline.
- Users can prepare proof offline.
- Penalties should not trigger solely because the app failed to sync while offline.
- Deadline enforcement should happen server-side.

## 12. Analytics

Track:

- Goal creation rate
- Goal completion rate
- Missed deadline rate
- Proof submission timing
- Penalty trigger rate
- Recovery task completion
- Partner approval rate
- Notification effectiveness

Do not expose overly punitive analytics that push users into shame loops. Show trends and decisions users can act on.

## 13. MVP Acceptance Criteria

The MVP is complete when a user can:

- Create a goal with a deadline.
- Select a proof requirement.
- Select a non-financial penalty.
- Invite an accountability partner.
- Submit proof.
- Have the partner approve or reject proof.
- Automatically mark the goal failed after deadline plus grace period.
- Trigger the selected penalty.
- View completed, failed, and active goals.
- Receive local and push notifications.

## 14. Future Features

- HealthKit proof verification.
- Calendar integration.
- App widgets.
- Live Activities.
- AI goal planning.
- AI proof quality checks.
- Team challenges.
- Shared goal groups.
- Donation and anti-charity penalties.
- Stripe-backed commitment contracts.
- Shortcuts integration.

## 15. Open Product Questions

- Should the app allow anti-charity penalties, or are they too risky for App Store review and brand trust?
- Should financial penalties be available at launch or delayed until trust and dispute flows are mature?
- Who resolves disputes: support staff, accountability partners, or automated rules?
- Should partners need accounts, or can they approve through secure magic links?
- What penalty limits should apply to protect vulnerable users?

## 16. Research Notes

### 16.1 Market Patterns to Avoid Copying

Research into existing commitment apps suggests that the common category playbook is already well-covered:

- Beeminder uses quantified goals, automated/manual datapoints, a visible progress line, and monetary charges when users go off track.
- stickK uses commitment contracts, optional referees, stakes, and anti-charity recipients.
- Forfeit uses proof submission, AI or human review, money stakes, contact alerts, calls, email, app blocking, GPS, Apple Health, Screen Time, and appeals.
- Behavioral economics literature frames these as commitment devices: users voluntarily restrict future choices or accept a cost for failure to counter present bias.

The strongest differentiation opportunity is to move away from "miss goal, lose money or get embarrassed" and toward adaptive penalties that convert failure into structured friction, repair, or smaller next commitments.

### 16.2 Penalty Ideas Worth Prototyping

- Friction Debt: a missed goal creates mandatory setup work before the next goal can be launched.
- Commitment Ratchet: repeated misses lower maximum goal size until reliability improves.
- Evidence Upgrade: failed categories require stronger proof next time.
- Time Escrow: missed goals automatically become protected recovery time.
- Reflection Unlock: failed goals cannot be archived until the user completes a structured review.
- Goal Deposit to Self: money is locked for the user's future self, not captured by the app.
- Partner Task Transfer: failure creates a helpful obligation to a trusted partner.
- Service Credit: failure becomes a small prosocial action instead of shame or payment.
- Focus Bond: missed goals convert chosen leisure time into a recovery work block.
- Default Downgrade: unrealistic goals are automatically rewritten into smaller, verifiable commitments.

### 16.3 Sources

- Beeminder overview: https://www.beeminder.com/overview
- Beeminder contract rules: https://www.beeminder.com/contract
- stickK commitment contract terms: https://stickk.zendesk.com/hc/en-us/articles/206119378-Terms-and-Conditions-of-Commitment-Contract
- Forfeit product page: https://www.forfeit.app/
- Commitment-device behavioral economics overview: https://www.ncbi.nlm.nih.gov/books/NBK593511/

## 17. Game Theory and Consumer Economics Implications

### 17.1 Key Research Takeaways

Academic research does not support a simple "bigger penalty equals better commitment" model. The better reading is that commitment products work only when they preserve enough flexibility, match user sophistication, avoid exploitative contract design, and make future behavior easier to coordinate.

Important findings:

- Commitment demand is often weak. Laibson argues that present-biased users frequently avoid commitments because the perceived benefit is outweighed by hassle cost and the loss of flexibility.
- Commitment contracts can help exercise behavior. Gym-contract experiments find that hard contracts can increase gym visits, and longer nudged contracts can improve follow-through.
- Commitment can fail badly for partially naive users. Field work on savings and preventive health shows that some users pay for commitments, default, and lose money without receiving the intended benefit.
- Monetary incentives can backfire when goals are self-chosen. Research on bonuses and loss aversion finds that adding a monetary bonus can make people set more conservative goals and perform worse than with unpaid self-chosen goals.
- Consumers often overestimate future self-control. Health club research shows that people choose expensive flat-rate contracts and delay cancellation, consistent with overconfidence about future attendance and cancellation.
- Reputational commitment has interpersonal costs. Recent psychology research finds that choosing a commitment strategy can reduce perceived integrity-based trust because others infer poor past self-control.
- Game theory supports "hostage posting" when the pledged asset binds behavior, compensates the other party, or signals trustworthiness. This maps well to deposits, partner obligations, and reversible privilege locks.
- Repeated-game reputation suggests reliability can be built through visible consistency over time, but reputation systems need careful privacy controls because they can create shame and discourage adoption.

### 17.2 Product Approaches Derived From Research

#### Approach A: Adaptive Commitment Strength

Do not ask every user to pick a harsh penalty. Start with a light commitment and escalate only when the user repeatedly misses similar goals.

Implementation:

- New users begin with Reflection Unlock or Friction Debt.
- After three completed goals, unlock Evidence Upgrade and Time Escrow.
- After repeated failures, automatically recommend smaller goals rather than larger penalties.
- Keep high-stakes penalties opt-in and category-limited.

Rationale:

This accounts for research showing that users may misjudge their own self-control and choose harmful contracts.

#### Approach B: Flexibility-Preserving Penalties

A commitment product should not trap users when future opportunity costs change. Instead of rigid deadlines only, support planned flexibility.

Implementation:

- Let users predefine emergency rules before the goal starts.
- Allow a limited number of "reschedule tokens" that must be earned through completion.
- Require partner approval for last-minute deadline changes on high-stakes goals.
- Use Time Escrow to preserve commitment while allowing the exact recovery block to move.

Rationale:

This follows the trade-off in commitment theory: strong restrictions help self-control but destroy flexibility when circumstances legitimately change.

#### Approach C: Hostage Posting Without App Profit From Failure

Use pledged assets that the user values, but avoid making the app financially dependent on users failing.

Implementation:

- Goal Deposit to Self: funds go into a locked user savings bucket.
- Partner Task Transfer: missed goals create a partner-defined helpful obligation.
- Privilege Cooldown: app privileges are temporarily locked until recovery.
- Service Credit: failure creates a prosocial task rather than a payment to the company.

Rationale:

Game-theoretic hostage posting works because the posted asset changes incentives, compensates affected parties, or signals sincerity. The app does not need to capture the asset.

#### Approach D: Reputation as a Small-Group Mechanism

Use reputation only where it improves coordination with trusted partners. Avoid broad public leaderboards for failure.

Implementation:

- Reliability Score is private by default.
- Users can share reliability with selected partners or teams.
- Scores should recover through consistent completion.
- Hide commitment-method details from casual observers so users are not penalized socially for needing commitment support.

Rationale:

Repeated-game theory supports reputation as a way to shape future behavior, but interpersonal research suggests visible commitment-device use can reduce perceived trustworthiness.

#### Approach E: Anti-Naivete Goal Calibration

Before allowing strong penalties, the app should estimate whether the user is overconfident.

Implementation:

- Ask for expected difficulty, expected completion probability, and fallback plan.
- Compare estimated completion probability against historical completion rate.
- Warn users when they choose goals much larger than their past behavior supports.
- Offer an auto-split into smaller milestones.
- Use Commitment Ratchet after misses to make overpromising harder.

Rationale:

Consumer economics research on health clubs and commitment contracts shows that users often overestimate future follow-through.

#### Approach F: Goal Size and Penalty Size Should Move Oppositely

Large goals should start with softer penalties. Small, repeatable goals can support stricter penalties.

Implementation:

- Big one-time goals use Reflection Unlock, Time Escrow, and milestone splitting.
- Small recurring goals can use Evidence Upgrade, Partner Task Transfer, or limited deposits.
- The app blocks combinations like "huge goal plus harsh financial penalty" unless the user has proven reliability.

Rationale:

Loss aversion can make users set conservative goals when monetary stakes are attached. Softer penalties preserve ambition; stricter penalties fit narrow behaviors.

#### Approach G: Contract Framing Matters

The same economic mechanism can feel different depending on whether it is framed as a penalty, deposit, restoration path, or privilege lock.

Implementation:

- Prefer "unlock after recovery" language over "you are punished."
- Show penalties as pre-agreed recovery mechanics.
- Use deposits, cooldowns, and effort obligations instead of clawbacks where possible.
- Avoid surprising the user after failure; every consequence must be previewed at commitment time.

Rationale:

Research on incentive framing and loss aversion shows that users react strongly to penalties and clawbacks even when economically equivalent to bonuses.

### 17.3 Recommended Penalty Architecture

Earned Commitment should model penalties as a ladder:

1. Level 1: Cognitive friction
   - Reflection Unlock
   - Friction Debt
   - Default Downgrade

2. Level 2: Proof friction
   - Evidence Upgrade
   - Partner verification
   - Shorter milestone intervals

3. Level 3: Time friction
   - Time Escrow
   - Focus Bond
   - Protected calendar recovery block

4. Level 4: Social/reputation friction
   - Partner Task Transfer
   - Small-group Reliability Score
   - Team-visible recovery status

5. Level 5: Asset lock
   - Goal Deposit to Self
   - Refundable commitment stake
   - Limited, user-owned financial lock

Users should not start at Level 5. The app earns trust by proving that lighter mechanisms are insufficient before recommending stronger ones.

### 17.4 Research Sources

- Laibson, "Why don't present-biased agents make commitments?": https://pmc.ncbi.nlm.nih.gov/articles/PMC4957524/
- Bryan, Karlan, and Nelson, "Commitment Devices": https://www.annualreviews.org/doi/pdf/10.1146/annurev.economics.102308.124324
- DellaVigna and Malmendier, "Contract Design and Self-Control": https://www.gsb.stanford.edu/faculty-research/working-papers/contract-design-self-control-theory-evidence
- DellaVigna and Malmendier, "Overestimating Self-Control": https://www.nber.org/papers/w10819
- Carrera et al., "Who Chooses Commitment?": https://www.nber.org/papers/w26161
- Bhattacharya, Garber, and Goldhaber-Fiebert, "Nudges in Exercise Commitment Contracts": https://www.nber.org/papers/w21406
- "Put a bet on it: Can self-funded commitment contracts curb fitness procrastination?": https://www.sciencedirect.com/science/article/pii/S0167629624000882
- John, "When Commitment Fails": https://pubsonline.informs.org/doi/10.1287/mnsc.2018.3236
- Bai et al., "Self-Control and Demand for Preventive Health": https://www.nber.org/papers/w23727
- Brink and Rankin, "The Effects of Risk Preference and Loss Aversion on Individual Behavior Under Bonus, Penalty, and Combined Contract Frames": https://papers.ssrn.com/sol3/papers.cfm?abstract_id=1187013
- "Bonuses and loss aversion": https://www.sciencedirect.com/science/article/pii/S0167268126000260
- Raub, "Hostage Posting as a Mechanism of Trust": https://journals.sagepub.com/doi/10.1177/1043463104044682
- "Hostages as a commitment device": https://www.sciencedirect.com/science/article/pii/016726819390039R
- "Going beyond the self in self-control": https://pubmed.ncbi.nlm.nih.gov/38602791/
- Amaldoss and Harutyunyan, "Pricing of Vice Goods for Goal-Driven Consumers": https://pubsonline.informs.org/doi/10.1287/mnsc.2022.4567

## 18. Feasibility Recommendation

### 18.1 Most Feasible Product Direction

The app should control the user's commitment contract, proof requirements, and recovery workflow. It should not position itself as a system-level enforcer that can force behavior across the entire iPhone.

Recommended core loop:

1. User creates a small, measurable commitment.
2. User chooses proof and an accountability partner.
3. User pre-commits a recovery block on the calendar.
4. The app sends escalating reminders as the deadline approaches.
5. A missed deadline triggers a recovery contract: reflection, smaller replacement goal, stronger proof, and protected calendar time.
6. Repeated misses increase friction and reduce the size of future commitments.
7. Successful completion restores privileges and gradually increases commitment capacity.

This is feasible because the app owns the goal state, proof records, partner workflow, and penalty rules. It creates meaningful consequences without depending on an external payment processor, charity, device-management entitlement, or unreliable self-reporting.

### 18.2 Feasibility Ranking

| Mechanism | Feasibility | Recommendation |
|---|---:|---|
| Reflection Unlock and Friction Debt | Very high | Build in MVP. Entirely controlled by app logic and easy to explain. |
| Commitment Ratchet | Very high | Build in MVP. Differentiated and directly aligned with overpromising research. |
| Evidence Upgrade | High | Build in MVP. Requires only proof storage and partner review. |
| Partner Task Transfer | High | Build after the core loop. Adds social accountability without public shaming. |
| Time Escrow through Calendar | High | Build in MVP as a user-approved calendar event. EventKit supports creating calendar events, including write-only access on modern iOS. |
| Goal Deposit to Self | Medium | Add later through a licensed payment provider and explicit refund rules. Do not make the company profit from failure. |
| Screen Time or app blocking | Low to medium | Keep optional and experimental. Apple's Family Controls and Managed Settings require special authorization and are designed around parental-control use cases. |
| Automatic calls, texts, or public reputation | Low | Avoid in MVP because of privacy, abuse, and social-harm risks. |

### 18.3 What the App Can and Cannot Control

The app can control:

- Whether a goal remains active or is marked failed.
- What proof is required for the next goal.
- Whether new ambitious goals are temporarily locked.
- Which recovery task must be completed.
- Whether a partner is asked to review proof.
- Whether a recovery block is placed on the user's calendar.
- The user's private reliability history and commitment limits.

The app cannot reliably guarantee that a user:

- Completes work outside the app.
- Keeps a calendar event instead of deleting it.
- Does not uninstall the app or revoke permissions.
- Provides truthful evidence without a trusted verifier.
- Stops using distracting apps unless the user grants supported system-control permissions.

The product should make these limits explicit in the commitment screen. A penalty is credible when it is automatic inside the app and useful after failure; it is not credible merely because the UI says it is mandatory.

### 18.4 Recommended MVP Contract

Use a three-level penalty ladder:

- Level 1: Reflection Unlock plus a five-minute failure review.
- Level 2: Evidence Upgrade and a smaller replacement goal due within 24 to 72 hours.
- Level 3: Time Escrow, where a recovery work block is added to the calendar and the user must complete it before creating another ambitious goal.

After three successful commitments, the user can unlock larger goals or lighter proof requirements. After repeated misses, the app reduces goal size and shortens the planning horizon. This turns failure into calibration rather than a permanent loss of progress.

### 18.5 Product Positioning

The strongest positioning is not "an app that punishes you." It is "a commitment system that makes overpromising expensive and recovery unavoidable." That distinction matters for retention, App Store review, and user trust.

Money penalties, public humiliation, and device lockouts create stronger headline appeal but add payment, regulatory, platform, privacy, and abuse risks. They should be optional extensions only after the non-financial commitment loop demonstrates that users return, complete recovery tasks, and improve their completion rate.

## 19. Founding Feature: Earned Commitment

### 19.1 Product Decision

The founding feature should be Commitment Capacity, presented to users as **Earned Commitment**.

The app does not give every user unlimited permission to make large promises. It gives each user a dynamic commitment capacity based on recent behavior. Users earn the ability to make larger, longer, and lower-friction commitments by completing smaller commitments consistently.

This feature should be the primary marketing message because it is:

- Distinct from a normal task manager, streak tracker, or simple penalty app.
- Directly connected to the user's actual behavior.
- Capable of coordinating all five initial features.
- Meaningful even when no money changes hands.
- Easier to implement and explain than device blocking or financial forfeiture.

### 19.2 Behavioral-Economic Basis

The feature addresses two well-supported problems:

- Present bias: the future self wants the benefit of the goal, while the present self wants to avoid the work.
- Overconfidence: people often overestimate how much time, energy, and self-control they will have later.

Research on health-club contracts found that consumers often choose plans based on overly optimistic expectations of future attendance. Research on commitment devices also finds that people demand mechanisms that help their future selves follow through, but that commitment strength must be calibrated because some users are overly optimistic about their own self-control.

The product implication is not simply to make penalties harsher. It is to make the user's available commitment size respond to demonstrated reliability.

### 19.3 How It Works

Each user has a private capacity score composed of:

- Completion rate.
- On-time rate.
- Number of active commitments.
- Frequency of abandoned goals.
- Recovery-task completion.
- Proof quality and verification history.

Capacity affects:

- Maximum number of active goals.
- Maximum deadline distance.
- Allowed goal size or estimated effort.
- Required proof strength.
- Whether partner verification is required.
- Whether a calendar recovery block is mandatory.

Example progression:

1. New user: three small goals, short deadlines, self-confirmation allowed.
2. Reliable user: more active goals, longer projects, lighter proof requirements.
3. User with repeated misses: fewer active goals, smaller milestones, stronger proof, and mandatory recovery blocks.
4. User who completes recovery: capacity begins to return immediately, but the original failure remains visible.

### 19.4 User-Facing Language

Avoid language such as "you are being punished" or "your score has been reduced."

Use language such as:

- "Your current commitment capacity is 4."
- "Earn room for a larger promise."
- "Complete two recovery commitments to unlock longer goals."
- "This goal is larger than your recent follow-through supports."
- "Start smaller, prove consistency, then scale."

Suggested marketing lines:

- "Earn the right to promise more."
- "Your goals should match your follow-through."
- "Build capacity. Keep promises."

### 19.5 Guardrails

Commitment Capacity must be framed as calibration, not a judgment of personal worth.

- Never expose a global public score by default.
- Explain exactly why capacity changed.
- Provide a recovery path after every downgrade.
- Do not reduce capacity because of a missed reminder, technical error, illness, or user-approved exception.
- Allow a limited number of pre-declared pause days.
- Keep the score private unless the user explicitly shares it with a partner.
- Do not use the feature to encourage compulsive overwork or excessive goal setting.

### 19.6 Relationship to the Other Four Founding Features

Commitment Capacity is the control layer for the initial product system:

| Feature | Role inside Earned Commitment |
|---|---|
| Recovery Debt | Required work to restore capacity after a miss. |
| Goal Compression | Converts oversized commitments into achievable next steps. |
| Proof Escalation | Increases evidence requirements when reliability falls. |
| Calendar Recovery Block | Makes recovery time concrete and unavoidable. |

The product should advertise Earned Commitment, while these four mechanisms provide the actual behavioral system underneath it.

## 20. Apple-Platform Implementation Specification

### 20.1 Technical Goals

The implementation should be:

- Local-first, so the core commitment loop works without a network connection.
- Deterministic, so the same goal history always produces the same capacity result.
- Testable, with penalty and capacity rules independent of SwiftUI and persistence.
- Privacy-preserving, with permissions requested only when a user enables the related feature.
- Accessible, supporting Dynamic Type, VoiceOver, reduced motion, and full keyboard navigation on iPad.
- Resilient to app termination, missed background execution, revoked permissions, and calendar changes.

The app should target iOS 17 or later for the first release. This allows SwiftUI Observation and the current SwiftData integration. Apple documents Observation as the preferred way for SwiftUI views to track observable model data, while SwiftData provides model containers, persistence, and schema migration support.

### 20.2 Recommended Stack

| Concern | Technology | Rule |
|---|---|---|
| UI | SwiftUI | Use small, composable views. Keep business rules out of view bodies. |
| UI state | Observation (`@Observable`) | Use for feature state and navigation state. Use `@Bindable` only where a view needs a writable binding. |
| Persistence | SwiftData (`@Model`) | Store durable user data locally. Define explicit schema versions and migration tests. |
| Async work | Swift Concurrency | Use `async`/`await`, task cancellation, actors, and strict concurrency checking. Avoid callback pyramids and unstructured global tasks. |
| Notifications | UserNotifications | Schedule local reminders from committed deadlines. Treat notifications as prompts, never proof of completion. |
| Calendar | EventKit | Use write-only calendar access when the feature only creates recovery blocks. Reconcile deleted or edited events gracefully. |
| Secure secrets | Keychain | Store only tokens and sensitive credentials. Never put secrets in SwiftData or analytics events. |
| Sharing | ShareLink and system share sheet | Let users share a specific commitment or recovery status only through an explicit action. |
| Optional system controls | FamilyControls / ManagedSettings | Defer until a separate entitlement and privacy review. Not required for MVP. |
| Testing | XCTest and Swift Testing | Unit-test domain rules heavily; use UI tests for critical user journeys. |

Apple's SwiftData `ModelContainer` is responsible for the app's schema and persistent storage, and `ModelActor` can provide serialized access for background model work. The app should use those primitives instead of inventing a custom persistence layer for MVP.

### 20.3 Project Structure

Use a feature-oriented structure with a small domain core:

```text
App/
  App/
    EarnedCommitmentApp.swift
    AppDependencies.swift
  Domain/
    Goal.swift
    CommitmentCapacity.swift
    PenaltyRules.swift
    RecoveryPlan.swift
    GoalState.swift
    DomainErrors.swift
  Features/
    Today/
    GoalCreation/
    GoalDetail/
    Recovery/
    Capacity/
    PartnerReview/
    Settings/
  Persistence/
    SwiftDataModels.swift
    ModelContainerFactory.swift
    SchemaMigrationPlan.swift
    Repositories.swift
  Integrations/
    CalendarClient.swift
    NotificationClient.swift
    MediaClient.swift
  Services/
    CommitmentEngine.swift
    DeadlineEvaluator.swift
    CapacityCalculator.swift
    RecoveryCoordinator.swift
  Resources/
    Localizable.xcstrings
```

The domain layer must not import SwiftUI, SwiftData, EventKit, or UserNotifications. Integration clients should be protocols with live and test implementations. This keeps the commitment engine deterministic and makes failure cases testable without a device.

### 20.4 Domain Model

The persisted model should contain:

- `Goal`: title, description, category, effort estimate, deadline, state, created date, and commitment level.
- `Milestone`: parent goal, title, due date, completion state, and required evidence type.
- `EvidenceSubmission`: goal or milestone, submission date, evidence kind, local asset reference, and verification state.
- `PenaltyContract`: the pre-committed consequence, level, grace period, and cancellation rules.
- `RecoveryTask`: failure reason, task type, due date, completion state, and capacity impact.
- `CapacitySnapshot`: score, active-goal limit, effort limit, proof level, and calculation date.
- `CapacityEvent`: a signed domain event explaining why capacity changed.
- `CalendarLink`: local event identifier, goal identifier, recovery block identifier, and link status.
- `PartnerReview`: partner identifier, review state, decision, and audit timestamps.

Use enums for finite states and `Codable` value types for stored configuration. Keep user-facing strings out of domain enums; map them through localized presentation types.

### 20.5 Goal State Machine

Goal transitions must be explicit and validated by the domain engine:

```text
Draft -> Committed -> InProgress -> Submitted -> Verified
                           |             |
                           v             v
                         Failed <----- Rejected
                           |
                           v
                        Recovering -> Recovered
```

Rules:

- A goal becomes immutable in its penalty terms when it moves from `Draft` to `Committed`.
- Deadline evaluation is idempotent. Running it twice cannot create two penalties or two recovery tasks.
- `Failed` remains part of history even after `Recovered`.
- A partner rejection requires either corrected evidence before the cutoff or a transition to `Failed`.
- Calendar and notification failures do not change the goal state.
- User-approved exceptions must be recorded as domain events, not silently overwrite deadlines.

### 20.6 Commitment Capacity Algorithm

Capacity is a private, explainable score. Do not use a black-box machine-learning model in MVP.

Inputs should be normalized over a rolling window:

- On-time completion rate: 40%.
- Recovery completion rate: 20%.
- Active commitment load: 15%.
- Abandonment rate: 15%.
- Verification quality: 10%.

The score should be bounded from 0 to 100 and translated into product limits:

```text
Capacity 0-29:    one active goal; small effort; partner proof required
Capacity 30-59:   three active goals; moderate effort; evidence required
Capacity 60-79:   five active goals; longer deadlines; lighter proof allowed
Capacity 80-100:  expanded limits; user may opt into stronger contracts
```

These numbers are initial product parameters, not scientific constants. Store the parameters in a versioned configuration so they can be tuned without rewriting historical events.

Every capacity change must produce an explanation such as:

> "Capacity decreased by 8 because two of your last five commitments missed their deadlines. Complete two recovery tasks to restore capacity."

Never decrease capacity for a technical failure, revoked optional permission, illness exception, or a pause day granted under the contract.

### 20.7 Feature Flows

#### Earned Commitment

- Show current capacity before goal creation.
- Preview the goal's estimated load and required proof.
- Warn when the proposed goal exceeds capacity.
- Offer a one-tap split into milestones.
- Require explicit confirmation of the penalty contract.

#### Recovery Debt

- Create exactly one recovery plan per failed goal.
- Offer a short reflection, smaller replacement goal, or scheduled recovery block.
- Prevent new ambitious goals until the required recovery condition is met.
- Preserve the failure record after recovery.

#### Goal Compression

- Generate a smaller goal from the original goal's measurable outcome.
- Require the user to confirm the compressed scope.
- Never silently rewrite the user's goal.
- Use short time horizons, generally 24 to 72 hours.

#### Proof Escalation

- Start with the least invasive proof that is credible for the goal type.
- Escalate only after a documented miss or rejected submission.
- Keep evidence local by default and delete it when the retention period expires.
- Require partner approval only for higher-risk or repeatedly failed commitments.

#### Calendar Recovery Block

- Ask for calendar access at the moment the user enables the feature.
- Prefer write-only calendar access when the app only creates events.
- Save the EventKit identifier and reconcile external changes.
- If the event is deleted, mark the recovery block as unresolved and offer a replacement; do not pretend the block happened.

### 20.8 Background and Reliability Strategy

The app must not depend on continuous background execution.

- Schedule local notifications at commitment time.
- Re-evaluate overdue commitments when the app launches, becomes active, receives a background refresh, or handles a notification action.
- Use a server only for partner invitations, partner review synchronization, and optional cross-device backup.
- Make deadline evaluation deterministic from persisted timestamps and the user's time zone.
- Store all times as absolute `Date` values and render them in the user's current locale and calendar.
- Protect against duplicate processing with idempotency keys based on goal identifier and deadline version.

### 20.9 Privacy and Safety Requirements

- No contacts, calendar, health, location, or photo-library permission on first launch.
- Explain the purpose immediately before each permission request.
- Make partner sharing opt-in and granular by goal.
- Do not share capacity scores publicly by default.
- Provide export and deletion controls for all user-created data.
- Include a clear pause, exception, and dispute flow.
- Avoid language that frames failure as moral weakness.
- Detect potentially harmful patterns such as excessive active goals, repeated sleep-reducing deadlines, or compulsive penalty escalation, and recommend reducing intensity.

### 20.10 Testing Requirements

Unit tests must cover:

- Every valid and invalid goal-state transition.
- Deadline plus grace-period evaluation across time zones and daylight-saving changes.
- Idempotent failure processing.
- Capacity calculation and explanation generation.
- Capacity recovery after successful recovery tasks.
- Goal compression and milestone generation.
- Proof escalation rules.
- Pause days and approved exceptions.

Integration tests must cover:

- SwiftData migration from each released schema version.
- Calendar event creation, deletion, editing, and permission denial.
- Notification scheduling and cancellation.
- Offline creation and later synchronization.
- Partner approval, rejection, and conflict resolution.

UI tests must cover:

- Creating and committing a goal.
- Submitting proof before a deadline.
- Missing a deadline and completing recovery.
- Restoring capacity after recovery.
- Denying optional permissions while the core app remains usable.

### 20.11 MVP Acceptance Criteria

The first release is complete when:

- A user can create, commit, complete, fail, and recover from a goal without network access.
- A missed deadline creates one and only one recovery contract.
- Capacity changes are explainable and reproducible from stored events.
- The user cannot lower the penalty after commitment without following the contract's exception flow.
- Calendar and notification permissions are optional.
- The app remains useful if every optional permission is denied.
- All core domain rules have automated tests.
- The app supports Dynamic Type, VoiceOver labels, reduced motion, and localization-ready strings.
