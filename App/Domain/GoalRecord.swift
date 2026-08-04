import Foundation
import SwiftData

@Model
final class GoalRecord {
    var identifier: UUID = UUID()
    var title: String
    var details: String
    var deadline: Date
    var sizeRawValue: String
    var evidenceRawValue: String
    var statusRawValue: String
    var createdAt: Date
    var committedCapacity: Int
    var recoveryTask: String?
    var recoveryItemsTotal: Int
    var recoveryItemsCompleted: Int
    var completedAt: Date?
    var failedAt: Date?
    var recoveredAt: Date?
    var recoveryDeadline: Date?
    var recoveryEscalationCount: Int = 0
    var proofConfirmedAt: Date?
    var timeZoneIdentifier: String = TimeZone.current.identifier
    var pauseUntil: Date?
    var exceptionReason: String?
    var exceptionApprovedAt: Date?

    init(title: String, details: String, deadline: Date, size: CommitmentSize, evidence: EvidenceLevel, committedCapacity: Int) {
        self.identifier = UUID()
        self.title = title
        self.details = details
        self.deadline = deadline
        self.sizeRawValue = size.rawValue
        self.evidenceRawValue = evidence.rawValue
        self.statusRawValue = GoalStatus.committed.rawValue
        self.createdAt = .now
        self.committedCapacity = committedCapacity
        self.recoveryItemsTotal = 0
        self.recoveryItemsCompleted = 0
        self.recoveryEscalationCount = 0
        self.timeZoneIdentifier = TimeZone.current.identifier
        self.pauseUntil = nil
    }

    var status: GoalStatus {
        get { GoalStatus(rawValue: statusRawValue) ?? .committed }
        set { statusRawValue = newValue.rawValue }
    }
    var size: CommitmentSize { CommitmentSize(rawValue: sizeRawValue) ?? .small }
    var evidence: EvidenceLevel { EvidenceLevel(rawValue: evidenceRawValue) ?? .selfConfirmation }
}

@Model
final class LedgerEntry {
    @Attribute(.unique) var eventID: String = UUID().uuidString
    var goalIdentifier: UUID?
    var createdAt: Date
    var delta: Int
    var scoreAfter: Int
    var reason: String
    var kindRawValue: String

    init(eventID: String, goalIdentifier: UUID? = nil, delta: Int, scoreAfter: Int, reason: String, kind: LedgerKind) {
        self.eventID = eventID
        self.goalIdentifier = goalIdentifier
        self.createdAt = .now
        self.delta = delta
        self.scoreAfter = scoreAfter
        self.reason = reason
        self.kindRawValue = kind.rawValue
    }

    var kind: LedgerKind { LedgerKind(rawValue: kindRawValue) ?? .kept }
}

enum PersistenceSchema {
    static let currentVersion = "2"
}
