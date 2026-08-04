import Foundation
import Testing
import SwiftData
@testable import EarnedCommitment

struct GoalDomainTests {
    private func goal(size: CommitmentSize = .small) -> GoalRecord {
        GoalRecord(title: "Submit draft", details: "", deadline: .now.addingTimeInterval(3600), size: size, evidence: .selfConfirmation, committedCapacity: GoalRules.startingScore)
    }

    @Test func completingCommittedGoalRecordsCompletion() throws {
        let item = goal()
        try GoalStateMachine.complete(item)
        #expect(item.status == .completed)
        #expect(item.completedAt != nil)
    }

    @Test func missCreatesCorrectRecoveryDebt() throws {
        let item = goal(size: .large)
        try GoalStateMachine.applyMiss(item)
        #expect(item.status == .recovering)
        #expect(item.recoveryItemsTotal == 3)
        #expect(item.failedAt != nil)
    }

    @Test func finalRecoveryItemRestoresGoal() throws {
        let item = goal(size: .small)
        try GoalStateMachine.applyMiss(item)
        let delta = try GoalStateMachine.completeRecoveryItem(item)
        #expect(delta == 6)
        #expect(item.status == .recovered)
        #expect(item.failedAt != nil)
        #expect(item.recoveredAt != nil)
    }

    @Test func recoveryRestoresPenaltyInParts() throws {
        let item = goal(size: .standard)
        try GoalStateMachine.applyMiss(item)
        let firstDelta = try GoalStateMachine.completeRecoveryItem(item)
        let secondDelta = try GoalStateMachine.completeRecoveryItem(item)

        #expect(firstDelta == 5)
        #expect(secondDelta == 6)
        #expect(firstDelta + secondDelta == item.size.loss)
        #expect(item.status == .recovered)
    }

    @Test func recoveryCannotBeCompletedAfterFinalItem() throws {
        let item = goal(size: .small)
        try GoalStateMachine.applyMiss(item)
        _ = try GoalStateMachine.completeRecoveryItem(item)

        #expect(throws: GoalDomainError.missingRecovery) {
            try GoalStateMachine.completeRecoveryItem(item)
        }
    }

    @Test func deadlineAtTheExactInstantIsMissed() throws {
        let item = goal()
        try GoalStateMachine.applyMiss(item, now: item.deadline)
        #expect(item.status == .recovering)
        #expect(item.failedAt == item.deadline)
    }

    @Test func tierRulesMatchDesignerContract() {
        #expect(CapacityTier.forScore(GoalRules.startingScore) == .standing)
        #expect(CapacityTier.forScore(75) == .extended)
        #expect(CapacityTier.forScore(90) == .full)
        #expect(CapacityTier.standing.maximumHours == 168)
        #expect(CapacityTier.extended.maximumSize == .large)
    }

    @Test @MainActor func deadlineProcessingIsIdempotent() throws {
        let container = try ModelContainer(for: GoalRecord.self, LedgerEntry.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let item = goal(size: .standard)
        item.deadline = Date(timeIntervalSince1970: 1_000)
        context.insert(item)
        try context.save()
        let state = AppState()

        _ = try DeadlineProcessor.process(goals: [item], context: context, appState: state, now: Date(timeIntervalSince1970: 1_001))
        _ = try DeadlineProcessor.process(goals: [item], context: context, appState: state, now: Date(timeIntervalSince1970: 1_002))

        let entries = try context.fetch(FetchDescriptor<LedgerEntry>())
        #expect(item.status == .recovering)
        #expect(entries.count == 1)
        #expect(state.score == 51)
    }

    @Test @MainActor func recoveryEscalationIsIdempotentPerWindow() throws {
        let container = try ModelContainer(for: GoalRecord.self, LedgerEntry.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let item = goal()
        item.status = .recovering
        item.recoveryDeadline = Date(timeIntervalSince1970: 1_000)
        item.recoveryItemsTotal = 1
        context.insert(item)
        try context.save()
        let state = AppState()

        _ = try DeadlineProcessor.process(goals: [item], context: context, appState: state, now: Date(timeIntervalSince1970: 1_001))
        _ = try DeadlineProcessor.process(goals: [item], context: context, appState: state, now: Date(timeIntervalSince1970: 1_002))

        let entries = try context.fetch(FetchDescriptor<LedgerEntry>())
        #expect(item.recoveryEscalationCount == 1)
        #expect(entries.count == 1)
        #expect(state.score == 58)
    }

    @Test @MainActor func duplicateLedgerEventDoesNotChangeScoreTwice() throws {
        let container = try ModelContainer(for: GoalRecord.self, LedgerEntry.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let first = try LedgerStore.append(eventID: "same-event", goalIdentifier: nil, delta: -11, reason: "Missed", kind: .missed, context: context)
        let second = try LedgerStore.append(eventID: "same-event", goalIdentifier: nil, delta: -11, reason: "Missed", kind: .missed, context: context)
        try context.save()

        #expect(first.inserted)
        #expect(!second.inserted)
        #expect(second.score == first.score)
        #expect(try context.fetch(FetchDescriptor<LedgerEntry>()).count == 1)
    }

    @Test func deadlineUsesAbsoluteInstantAcrossTimeZones() throws {
        let item = goal()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        item.timeZoneIdentifier = "America/New_York"
        item.deadline = calendar.date(from: DateComponents(year: 2026, month: 8, day: 1, hour: 9))!

        let evaluation = try DeadlineEvaluator.evaluate(goals: [item], now: item.deadline.addingTimeInterval(1))

        #expect(evaluation.missedGoalIDs == [item.identifier])
        #expect(item.status == .recovering)
    }

    @Test func pauseAndApprovedExceptionPreventPrematureMiss() throws {
        let item = goal()
        let now = Date(timeIntervalSince1970: 2_000)
        item.deadline = now.addingTimeInterval(-10)
        try GoalStateMachine.approveException(item, reason: "Medical appointment", newDeadline: now.addingTimeInterval(3_600), now: now)
        let exceptionEvaluation = try DeadlineEvaluator.evaluate(goals: [item], now: now)
        #expect(exceptionEvaluation.missedGoalIDs.isEmpty)

        let second = goal()
        second.deadline = now.addingTimeInterval(-10)
        try GoalStateMachine.pause(second, until: now.addingTimeInterval(300), now: now)
        let pauseEvaluation = try DeadlineEvaluator.evaluate(goals: [second], now: now.addingTimeInterval(100))
        #expect(pauseEvaluation.missedGoalIDs.isEmpty)
    }

    @Test func committedTermsCannotBeEdited() {
        let item = goal()
        #expect(throws: GoalDomainError.editingLocked) {
            try GoalStateMachine.edit(item, title: "Changed", details: "", deadline: .now.addingTimeInterval(999))
        }
    }

    @Test func completionAfterDeadlineIsRejected() {
        let item = goal()
        let now = item.deadline.addingTimeInterval(1)
        #expect(throws: GoalDomainError.invalidTransition) {
            try GoalStateMachine.complete(item, now: now)
        }
        #expect(item.status == .committed)
    }
}
