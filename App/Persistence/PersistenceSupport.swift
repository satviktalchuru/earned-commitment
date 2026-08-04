import Foundation
import BackgroundTasks
import SwiftData
import UserNotifications

enum EarnedCommitmentSchema: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] { [GoalRecord.self, LedgerEntry.self] }
}

enum EarnedCommitmentMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [EarnedCommitmentSchema.self] }
    static var stages: [MigrationStage] { [] }
}

enum ModelContainerFactory {
    static func make() throws -> ModelContainer {
        try ModelContainer(
            for: GoalRecord.self, LedgerEntry.self,
            migrationPlan: EarnedCommitmentMigrationPlan.self
        )
    }
}

@MainActor
enum LedgerStore {
    static let startingScore = GoalRules.startingScore

    static func currentScore(context: ModelContext) throws -> Int {
        let entries = try context.fetch(FetchDescriptor<LedgerEntry>())
        return score(from: entries)
    }

    static func score(from entries: [LedgerEntry]) -> Int {
        let total = startingScore + entries.reduce(0) { $0 + $1.delta }
        return max(0, min(100, total))
    }

    @discardableResult
    static func append(
        eventID: String,
        goalIdentifier: UUID?,
        delta: Int,
        reason: String,
        kind: LedgerKind,
        context: ModelContext
    ) throws -> (inserted: Bool, score: Int) {
        let existing = try context.fetch(FetchDescriptor<LedgerEntry>(predicate: #Predicate { $0.eventID == eventID }))
        let current = try currentScore(context: context)
        guard existing.isEmpty else { return (false, current) }
        let next = max(0, min(100, current + delta))
        context.insert(LedgerEntry(eventID: eventID, goalIdentifier: goalIdentifier, delta: delta, scoreAfter: next, reason: reason, kind: kind))
        return (true, next)
    }
}

@MainActor
enum DeadlineProcessor {
    static func process(goals: [GoalRecord], context: ModelContext, appState: AppState, now: Date = .now) throws -> DeadlineEvaluation {
        let evaluation = try DeadlineEvaluator.evaluate(goals: goals, now: now)
        for goalID in evaluation.missedGoalIDs {
            guard let goal = goals.first(where: { $0.identifier == goalID }) else { continue }
            _ = try LedgerStore.append(eventID: GoalEventID.missed(goal), goalIdentifier: goal.identifier, delta: -goal.size.loss, reason: "Missed \"\(goal.title)\"", kind: .missed, context: context)
        }
        for goalID in evaluation.escalatedGoalIDs {
            guard let goal = goals.first(where: { $0.identifier == goalID }) else { continue }
            _ = try LedgerStore.append(eventID: GoalEventID.recoveryEscalated(goal), goalIdentifier: goal.identifier, delta: -GoalRules.recoveryEscalationLoss, reason: "Recovery overdue for \"\(goal.title)\"", kind: .recovery, context: context)
        }
        if !evaluation.missedGoalIDs.isEmpty || !evaluation.escalatedGoalIDs.isEmpty { try context.save() }
        appState.refresh(context: context)
        return evaluation
    }

}

@MainActor
enum DeadlineRefreshScheduler {
    static let identifier = "com.satviktalchuru.earnedcommitment.deadline-refresh"

    static func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: nil) { task in
            let success = MainActor.assumeIsolated { process() }
            task.setTaskCompleted(success: success)
        }
    }

    static func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: TimeInterval(GoalRules.backgroundRefreshMinutes * 60))
        do { try BGTaskScheduler.shared.submit(request) } catch { }
    }

    @MainActor
    private static func process() -> Bool {
        defer { schedule() }
        do {
            let container = try ModelContainerFactory.make()
            let context = ModelContext(container)
            let goals = try context.fetch(FetchDescriptor<GoalRecord>())
            let appState = AppState()
            _ = try DeadlineProcessor.process(goals: goals, context: context, appState: appState)
            return true
        } catch {
            return false
        }
    }
}

@MainActor
enum NotificationManager {
    static func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
    }

    static func schedule(for goal: GoalRecord) async {
        let center = UNUserNotificationCenter.current()
        let now = Date.now
        var requests: [UNNotificationRequest] = []
        let dates: [(String, Date, String)] = [
            ("due-soon", goal.deadline.addingTimeInterval(-TimeInterval(GoalRules.dueSoonReminderHours * 3600)), "Your commitment is due tomorrow."),
            ("due", goal.deadline, "Your commitment deadline is now.")
        ]
        for (suffix, date, body) in dates where date > now {
            let content = UNMutableNotificationContent()
            content.title = "Earned Commitment"
            content.body = body
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, date.timeIntervalSinceNow), repeats: false)
            requests.append(UNNotificationRequest(identifier: notificationID(goal.identifier, suffix), content: content, trigger: trigger))
        }
        for request in requests { await add(request, using: center) }
    }

    static func scheduleRecovery(for goal: GoalRecord) async {
        guard let deadline = goal.recoveryDeadline, deadline > .now else { return }
        let content = UNMutableNotificationContent()
        content.title = "Recovery work is due"
        content.body = "Complete a small recovery item for \(goal.title)."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, deadline.timeIntervalSinceNow), repeats: false)
        await add(UNNotificationRequest(identifier: notificationID(goal.identifier, "recovery"), content: content, trigger: trigger), using: UNUserNotificationCenter.current())
    }

    static func scheduleMissed(for goal: GoalRecord) async {
        let content = UNMutableNotificationContent()
        content.title = "Commitment missed"
        content.body = "Your capacity changed. Open Earned Commitment to review recovery."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        await add(UNNotificationRequest(identifier: notificationID(goal.identifier, "missed"), content: content, trigger: trigger), using: UNUserNotificationCenter.current())
    }

    static func cancel(for identifier: UUID) async {
        let ids = ["due-soon", "due", "recovery", "missed"].map { notificationID(identifier, $0) }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ids)
    }

    private static func notificationID(_ identifier: UUID, _ suffix: String) -> String { "goal.\(identifier.uuidString).\(suffix)" }

    private static func add(_ request: UNNotificationRequest, using center: UNUserNotificationCenter) async {
        do {
            try await center.add(request)
        } catch {
            #if DEBUG
            print("Notification scheduling failed: \(error.localizedDescription)")
            #endif
        }
    }
}

struct ExportPayload: Codable {
    let exportedAt: Date
    let goals: [ExportGoal]
    let ledger: [ExportLedgerEntry]
}

struct ExportGoal: Codable {
    let id: UUID
    let title: String
    let deadline: Date
    let status: String
    let size: String
    let evidence: String
}

struct ExportLedgerEntry: Codable {
    let eventID: String
    let createdAt: Date
    let delta: Int
    let scoreAfter: Int
    let reason: String
}

@MainActor
enum DataManager {
    static func exportURL(context: ModelContext) throws -> URL {
        let goals = try context.fetch(FetchDescriptor<GoalRecord>())
        let ledger = try context.fetch(FetchDescriptor<LedgerEntry>(sortBy: [SortDescriptor(\.createdAt)]))
        let payload = ExportPayload(
            exportedAt: .now,
            goals: goals.map { ExportGoal(id: $0.identifier, title: $0.title, deadline: $0.deadline, status: $0.statusRawValue, size: $0.sizeRawValue, evidence: $0.evidenceRawValue) },
            ledger: ledger.map { ExportLedgerEntry(eventID: $0.eventID, createdAt: $0.createdAt, delta: $0.delta, scoreAfter: $0.scoreAfter, reason: $0.reason) }
        )
        let data = try JSONEncoder().encode(payload)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("earned-commitment-export.json")
        try data.write(to: url, options: .atomic)
        return url
    }

    static func deleteAll(context: ModelContext, appState: AppState) async throws {
        let goals = try context.fetch(FetchDescriptor<GoalRecord>())
        for goal in goals { await NotificationManager.cancel(for: goal.identifier) }
        try context.delete(model: GoalRecord.self)
        try context.delete(model: LedgerEntry.self)
        try context.save()
        appState.refresh(context: context)
    }
}
