import SwiftUI
import SwiftData

struct GoalDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    let goal: GoalRecord
    @State private var showingCompleteConfirmation = false
    @State private var showingMiss = false
    @State private var showingCompletion = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(goal.title).font(.system(size: 27, weight: .black)).foregroundStyle(Modernist.ink).padding(.bottom, 22)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 1) {
                    detailCell("DUE", goal.deadline.formatted(date: .abbreviated, time: .shortened))
                    detailCell("SIZE", goal.size.label)
                    detailCell("ON COMPLETION", "+\(goal.size.gain) capacity")
                    detailCell("ON MISS", "−\(goal.size.loss) capacity")
                }
                .background(Modernist.hairline)
                .padding(.bottom, 22)
                Text("You committed to \(goal.title.lowercased()). If you keep it, capacity rises by \(goal.size.gain). If you miss it, capacity falls by \(goal.size.loss) and recovery work opens.")
                    .font(.system(size: 15)).foregroundStyle(Modernist.ink).padding(.bottom, 24)
                if goal.status == .committed {
                    VStack(spacing: 10) {
                        Button("Mark complete") { showingCompleteConfirmation = true }
                            .buttonStyle(ModernistPrimaryButton())
                        Button("Release early") { showingMiss = true }
                            .font(.system(size: 13, weight: .bold)).foregroundStyle(Modernist.missed).underline()
                    }
                } else if goal.status == .recovering {
                    RecoveryDebtPanel(goal: goal) { completeRecovery() }
                } else {
                    Text(goal.status.label.uppercased()).font(.system(size: 11, weight: .bold)).tracking(1).foregroundStyle(goal.status == .completed || goal.status == .recovered ? Modernist.kept : Modernist.missed)
                }
                if let errorMessage { Text(errorMessage).font(.system(size: 12)).foregroundStyle(Modernist.missed).padding(.top, 14) }
            }
            .padding(16)
        }
        .background(Modernist.canvas)
        .navigationTitle("Commitment")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Mark this commitment complete?", isPresented: $showingCompleteConfirmation, titleVisibility: .visible) {
            Button("Yes, I completed it") { complete() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You confirm once. An unconfirmed commitment counts as missed at the deadline.")
        }
        .sheet(isPresented: $showingMiss) { MissedModal(goal: goal) }
        .sheet(isPresented: $showingCompletion) { CompletionView(goal: goal, score: appState.score) }
    }

    private func detailCell(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.system(size: 9, weight: .bold)).tracking(1).foregroundStyle(Modernist.secondary)
            Text(value).font(.system(size: 14, weight: .bold)).foregroundStyle(Modernist.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Modernist.surface)
    }

    private func complete() {
        do {
            try GoalStateMachine.complete(goal)
            _ = try LedgerStore.append(eventID: GoalEventID.completed(goal), goalIdentifier: goal.identifier, delta: goal.size.gain, reason: "Kept \"\(goal.title)\"", kind: .kept, context: modelContext)
            try modelContext.save()
            appState.refresh(context: modelContext)
            Task { await NotificationManager.cancel(for: goal.identifier) }
            showingCompletion = true
        } catch { errorMessage = error.localizedDescription }
    }

    private func completeRecovery() {
        do {
            let delta = try GoalStateMachine.completeRecoveryItem(goal)
            _ = try LedgerStore.append(eventID: GoalEventID.recovery(goal, item: goal.recoveryItemsCompleted), goalIdentifier: goal.identifier, delta: delta, reason: "Recovery work for \"\(goal.title)\"", kind: .recovery, context: modelContext)
            try modelContext.save()
            appState.refresh(context: modelContext)
            if goal.status == .recovered { Task { await NotificationManager.cancel(for: goal.identifier) } }
        } catch { errorMessage = error.localizedDescription }
    }
}

struct ModernistPrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(Modernist.surface)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(configuration.isPressed ? Modernist.secondary : Modernist.ink)
    }
}

struct RecoveryDebtPanel: View {
    let goal: GoalRecord
    let action: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECOVERY DEBT").font(.system(size: 10, weight: .bold)).tracking(1.2).foregroundStyle(Modernist.missed)
            Text(goal.recoveryTask ?? "Complete the next small recovery item.").font(.system(size: 15, weight: .bold))
            Text("\(goal.recoveryItemsCompleted) of \(goal.recoveryItemsTotal) items confirmed · capacity restores in parts").font(.system(size: 12)).foregroundStyle(Modernist.secondary)
            Button("Confirm next recovery item", action: action).buttonStyle(ModernistPrimaryButton())
        }
        .padding(14)
        .background(Modernist.missTint)
    }
}

struct MissedModal: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    let goal: GoalRecord
    @State private var applied = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("CAPACITY REDUCED").font(.system(size: 11, weight: .bold)).tracking(1.3).foregroundStyle(Modernist.surface)
            Text("Your capacity is temporarily reduced.").font(.system(size: 30, weight: .black)).foregroundStyle(Modernist.surface)
            Text("\"\(goal.title)\" was not confirmed by the deadline.").font(.system(size: 15)).foregroundStyle(Modernist.surface)
            HStack {
                Text("−\(goal.size.loss) capacity").font(.system(size: 22, weight: .black))
                Spacer()
                Text("Tier \(CapacityTier.forScore(appState.score).rawValue)").font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(Modernist.surface)
            VStack(alignment: .leading, spacing: 8) {
                Text("Nothing you have already promised was cancelled.")
                    .font(.system(size: 14, weight: .bold))
                Text("Recovery work is small by design: each item restores part of the lost capacity, and all \(goal.size.recoveryItems) item\(goal.size.recoveryItems == 1 ? "" : "s") are needed for full restoration.")
                    .font(.system(size: 13))
            }
            .foregroundStyle(Modernist.ink)
            .padding(14)
            .background(Modernist.missTint)
            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Modernist.surface)
            }
            Button("See recovery work") {
                guard !applied else { dismiss(); return }
                do {
                    try GoalStateMachine.applyMiss(goal)
                    _ = try LedgerStore.append(eventID: GoalEventID.missed(goal), goalIdentifier: goal.identifier, delta: -goal.size.loss, reason: "Missed \"\(goal.title)\"", kind: .missed, context: modelContext)
                    try modelContext.save()
                    appState.refresh(context: modelContext)
                    Task { await NotificationManager.cancel(for: goal.identifier); await NotificationManager.scheduleRecovery(for: goal) }
                    applied = true
                    dismiss()
                } catch {
                    errorMessage = "The miss could not be recorded. Try again."
                }
            }
            .buttonStyle(ModernistPrimaryButton())
            Spacer()
        }
        .padding(20)
        .background(Modernist.missed)
        .interactiveDismissDisabled(true)
    }
}

struct CompletionView: View {
    @Environment(\.dismiss) private var dismiss
    let goal: GoalRecord
    let score: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("KEPT").font(.system(size: 11, weight: .bold)).tracking(1.3).foregroundStyle(Modernist.surface)
            Text("You kept the promise.").font(.system(size: 30, weight: .black)).foregroundStyle(Modernist.surface)
            Text(goal.title).font(.system(size: 17, weight: .bold)).foregroundStyle(Modernist.surface)
            HStack {
                Text("+\(goal.size.gain) capacity").font(.system(size: 22, weight: .black))
                Spacer()
                Text("Score \(score)").font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(Modernist.surface)
            Text("Consistent follow-through earns room for larger commitments.")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Modernist.ink)
                .padding(14)
                .background(Modernist.completeTint)
            Button("Done") { dismiss() }
                .buttonStyle(ModernistPrimaryButton())
            Spacer()
        }
        .padding(20)
        .background(Modernist.kept)
    }
}
