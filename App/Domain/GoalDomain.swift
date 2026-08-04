import Foundation

enum GoalStatus: String, Codable, CaseIterable {
    case committed
    case completed
    case recovering
    case recovered
    case released

    var label: String {
        switch self {
        case .committed: "Open"
        case .completed: "Kept"
        case .recovering: "Recovery debt"
        case .recovered: "Recovered"
        case .released: "Missed"
        }
    }
}

enum EvidenceLevel: String, Codable, CaseIterable {
    case selfConfirmation
    case note
    case attachment
    case partner

    var label: String {
        switch self {
        case .selfConfirmation: "Self-check"
        case .note: "Short note"
        case .attachment: "Photo or file"
        case .partner: "Partner review"
        }
    }
}

enum CommitmentSize: String, Codable, CaseIterable, Identifiable {
    case small
    case standard
    case large

    var id: String { rawValue }

    var label: String { rawValue.capitalized }
    var gain: Int {
        switch self { case .small: 4; case .standard: 7; case .large: 12 }
    }
    var loss: Int {
        switch self { case .small: 6; case .standard: 11; case .large: 18 }
    }
    var recoveryItems: Int {
        switch self { case .small: 1; case .standard: 2; case .large: 3 }
    }
    var effortLimit: Int {
        switch self { case .small: 3; case .standard: 6; case .large: 10 }
    }
}

enum GoalRules {
    static let startingScore = 62
    static let recoveryWindowHours = 72
    static let recoveryEscalationLoss = 4
    static let dueSoonReminderHours = 24
    static let backgroundRefreshMinutes = 15
}

enum CapacityTier: Int, CaseIterable, Identifiable {
    case provisional = 1
    case steady = 2
    case standing = 3
    case extended = 4
    case full = 5

    var id: Int { rawValue }
    var name: String {
        switch self { case .provisional: "Provisional"; case .steady: "Steady"; case .standing: "Standing"; case .extended: "Extended"; case .full: "Full" }
    }
    var floor: Int {
        switch self { case .provisional: 0; case .steady: 30; case .standing: 55; case .extended: 75; case .full: 90 }
    }
    var maximumHours: Int {
        switch self { case .provisional: 24; case .steady: 72; case .standing: 168; case .extended: 336; case .full: 720 }
    }
    var maximumSize: CommitmentSize {
        switch self { case .provisional, .steady: .standard; case .standing: .standard; case .extended, .full: .large }
    }
    var slots: Int {
        switch self { case .provisional: 2; case .steady: 3; case .standing: 4; case .extended, .full: 5 }
    }

    static func forScore(_ score: Int) -> CapacityTier {
        allCases.last(where: { score >= $0.floor }) ?? .provisional
    }
}

enum LedgerKind: String, Codable {
    case kept
    case missed
    case recovery
}

enum GoalEventID {
    static func missed(_ goal: GoalRecord) -> String { "goal.missed.\(goal.identifier.uuidString)" }
    static func completed(_ goal: GoalRecord) -> String { "goal.completed.\(goal.identifier.uuidString)" }
    static func recovery(_ goal: GoalRecord, item: Int) -> String { "goal.recovery.\(goal.identifier.uuidString).\(item)" }
    static func recoveryEscalated(_ goal: GoalRecord) -> String {
        "goal.recovery-expired.\(goal.identifier.uuidString).\(goal.recoveryDeadline?.timeIntervalSince1970 ?? 0)"
    }
}

struct CapacityPolicy: Sendable, Equatable {
    let score: Int
    let tier: CapacityTier
    let openSlots: Int

    var hasOpenSlot: Bool { openSlots > 0 }
    var durationLabel: String {
        switch tier.maximumHours {
        case 24: "24 hours"
        case 72: "3 days"
        case 168: "7 days"
        case 336: "14 days"
        default: "30 days"
        }
    }
}

enum GoalDomainError: LocalizedError, Equatable {
    case invalidTransition
    case capacityExceeded(String)
    case missingRecovery
    case editingLocked
    case invalidPause
    case exceptionRequiresReason

    var errorDescription: String? {
        switch self {
        case .invalidTransition: "That commitment cannot make this transition."
        case let .capacityExceeded(message): message
        case .missingRecovery: "This commitment has no recovery work to complete."
        case .editingLocked: "Committed terms cannot be edited."
        case .invalidPause: "A pause must end after it starts."
        case .exceptionRequiresReason: "An approved exception needs a reason."
        }
    }
}

enum GoalStateMachine {
    static func edit(_ goal: GoalRecord, title: String, details: String, deadline: Date) throws {
        guard goal.status == .committed, goal.proofConfirmedAt == nil else { throw GoalDomainError.editingLocked }
        throw GoalDomainError.editingLocked
    }

    static func pause(_ goal: GoalRecord, until: Date, now: Date = .now) throws {
        guard goal.status == .committed, until > now else { throw GoalDomainError.invalidPause }
        let pauseDuration = until.timeIntervalSince(now)
        goal.deadline = goal.deadline.addingTimeInterval(pauseDuration)
        goal.pauseUntil = until
    }

    static func approveException(_ goal: GoalRecord, reason: String, newDeadline: Date? = nil, now: Date = .now) throws {
        guard goal.status == .committed, !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw GoalDomainError.exceptionRequiresReason
        }
        goal.exceptionReason = reason
        goal.exceptionApprovedAt = now
        if let newDeadline, newDeadline > now { goal.deadline = newDeadline }
    }

    static func complete(_ goal: GoalRecord, now: Date = .now) throws {
        guard goal.status == .committed,
              now < goal.deadline,
              goal.pauseUntil == nil || goal.pauseUntil! <= now
        else { throw GoalDomainError.invalidTransition }
        goal.status = .completed
        goal.completedAt = now
        goal.proofConfirmedAt = now
    }

    static func applyMiss(_ goal: GoalRecord, now: Date = .now) throws {
        guard goal.status == .committed else { throw GoalDomainError.invalidTransition }
        goal.status = .recovering
        goal.failedAt = now
        goal.recoveryItemsTotal = goal.size.recoveryItems
        goal.recoveryItemsCompleted = 0
        goal.recoveryTask = "Complete a smaller repeat of the missed action, then keep the next small promise."
        goal.recoveryDeadline = Calendar(identifier: .gregorian).date(byAdding: .hour, value: GoalRules.recoveryWindowHours, to: now)
    }

    static func completeRecoveryItem(_ goal: GoalRecord) throws -> Int {
        guard goal.status == .recovering, goal.recoveryItemsCompleted < goal.recoveryItemsTotal else {
            throw GoalDomainError.missingRecovery
        }
        let completedBefore = goal.recoveryItemsCompleted
        goal.recoveryItemsCompleted += 1
        let completedAfter = goal.recoveryItemsCompleted
        let isLast = goal.recoveryItemsCompleted == goal.recoveryItemsTotal
        if isLast {
            goal.status = .recovered
            goal.recoveredAt = .now
        }
        let totalItems = max(1, goal.recoveryItemsTotal)
        let restoredBefore = (goal.size.loss * completedBefore) / totalItems
        let restoredAfter = (goal.size.loss * completedAfter) / totalItems
        return restoredAfter - restoredBefore
    }
}

struct DeadlineEvaluation: Equatable, Sendable {
    var missedGoalIDs: [UUID] = []
    var escalatedGoalIDs: [UUID] = []
}

enum DeadlineEvaluator {
    static func evaluate(goals: [GoalRecord], now: Date, calendar: Calendar = .current) throws -> DeadlineEvaluation {
        var result = DeadlineEvaluation()
        for goal in goals {
            if goal.status == .committed, let pauseUntil = goal.pauseUntil, pauseUntil > now {
                continue
            } else if goal.status == .committed, goal.deadline <= now {
                try GoalStateMachine.applyMiss(goal, now: now)
                result.missedGoalIDs.append(goal.identifier)
            } else if goal.status == .recovering, let recoveryDeadline = goal.recoveryDeadline, recoveryDeadline <= now {
                goal.recoveryEscalationCount += 1
                goal.recoveryDeadline = calendar.date(byAdding: .hour, value: GoalRules.recoveryWindowHours, to: now)
                goal.recoveryTask = "Recovery is overdue. Complete the next small item to stop the debt from escalating."
                result.escalatedGoalIDs.append(goal.identifier)
            }
        }
        return result
    }
}
