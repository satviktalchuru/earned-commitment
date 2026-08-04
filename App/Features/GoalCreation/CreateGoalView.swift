import SwiftUI
import SwiftData

struct CreateGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    let policy: CapacityPolicy
    @State private var step = 1
    @State private var title = ""
    @State private var deadline = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
    @State private var size: CommitmentSize = .small
    @State private var showingConfirmation = false
    @State private var errorMessage: String?

    private var durationHours: Int { max(1, Int(deadline.timeIntervalSinceNow / 3600)) }
    private var sizeAllowed: Bool { size != .large || policy.tier == .extended || policy.tier == .full }
    private var durationAllowed: Bool { durationHours <= policy.tier.maximumHours }
    private var canCommit: Bool { !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && sizeAllowed && durationAllowed }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    ForEach(1...3, id: \.self) { index in
                        Rectangle().fill(index <= step ? Modernist.ink : Modernist.hairline).frame(height: 3)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        Text(stepTitle).font(.system(size: 27, weight: .black)).foregroundStyle(Modernist.ink)
                        Text(stepSubtitle).font(.system(size: 13)).foregroundStyle(Modernist.secondary)
                        stepContent
                    }
                    .padding(16)
                }
                .scrollIndicators(.hidden)
                footer
            }
            .background(Modernist.canvas)
            .navigationTitle("New commitment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
            .alert("Cannot commit", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK") { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
        }
    }

    @ViewBuilder private var stepContent: some View {
        switch step {
        case 1:
            VStack(alignment: .leading, spacing: 16) {
                TextField("What will you finish?", text: $title, axis: .vertical)
                    .font(.system(size: 18, weight: .bold))
                    .lineLimit(2...4)
                    .padding(.bottom, 10)
                    .overlay(alignment: .bottom) { Rectangle().fill(Modernist.ink).frame(height: 2) }
                Text("SIZE").font(.system(size: 10, weight: .bold)).tracking(1.3).foregroundStyle(Modernist.secondary)
                ForEach(CommitmentSize.allCases) { option in
                    Button { size = option } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(option.label).font(.system(size: 15, weight: .bold))
                                Text("+\(option.gain) kept · −\(option.loss) missed · \(option.recoveryItems) recovery item\(option.recoveryItems == 1 ? "" : "s")")
                                    .font(.system(size: 11)).foregroundStyle(Modernist.secondary)
                            }
                            Spacer()
                            Image(systemName: size == option ? "checkmark.square.fill" : "square")
                        }
                        .foregroundStyle(sizeAllowed || option != .large ? Modernist.ink : Modernist.secondary)
                        .padding(12)
                        .background(Modernist.surface)
                        .overlay(Rectangle().stroke(size == option ? Modernist.ink : Modernist.hairline, lineWidth: size == option ? 2 : 1))
                    }
                    .disabled(option == .large && !sizeAllowed)
                }
                if !sizeAllowed { Text("This goal is larger than your recent follow-through supports. Tier 4 unlocks Large.").font(.system(size: 12)).foregroundStyle(Modernist.missed) }
            }
        case 2:
            VStack(alignment: .leading, spacing: 18) {
                Text("DEADLINE").font(.system(size: 10, weight: .bold)).tracking(1.3).foregroundStyle(Modernist.secondary)
                DatePicker("Finish by", selection: $deadline, in: .now..., displayedComponents: [.date, .hourAndMinute])
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Modernist.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if !durationAllowed { Text("Longer than Tier \(policy.tier.rawValue) supports. Keep two more promises to extend the ceiling.").font(.system(size: 12)).foregroundStyle(Modernist.missed) }
                Text("PROOF").font(.system(size: 10, weight: .bold)).tracking(1.3).foregroundStyle(Modernist.secondary).padding(.top, 8)
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "checkmark.square.fill")
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Self-check")
                        Text("You confirm completion yourself.")
                            .font(.system(size: 11))
                            .foregroundStyle(Modernist.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Modernist.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                Text("You mark it done and confirm once. An unconfirmed commitment counts as missed at the deadline.")
                    .font(.system(size: 12)).foregroundStyle(Modernist.secondary)
            }
        default:
            VStack(alignment: .leading, spacing: 18) {
                Text("BEFORE YOU AGREE").font(.system(size: 10, weight: .bold)).tracking(1.3).foregroundStyle(Modernist.secondary)
                contractRow("Promise", title.isEmpty ? "Untitled commitment" : title)
                contractRow("Deadline", deadline.formatted(date: .abbreviated, time: .shortened))
                contractRow("On completion", "+\(size.gain) capacity")
                contractRow("On miss", "−\(size.loss) capacity")
                VStack(alignment: .leading, spacing: 8) {
                    Text("RECOVERY WORK").font(.system(size: 10, weight: .bold)).tracking(1.2).foregroundStyle(Modernist.missed)
                    Text("\(size.recoveryItems) small recovery item\(size.recoveryItems == 1 ? "" : "s") open if you miss this commitment.")
                        .font(.system(size: 15, weight: .bold))
                }
                .padding(14)
                .background(Modernist.missTint)
                Text("Nothing already promised will be cancelled if this commitment changes your tier.")
                    .font(.system(size: 12)).foregroundStyle(Modernist.secondary)
            }
        }
    }

    private var footer: some View {
        HStack {
            if step > 1 { Button("Back") { step -= 1 }.foregroundStyle(Modernist.ink) }
            Spacer()
            Button(step == 3 ? "Commit" : "Continue") {
                if step < 3 { step += 1 } else { commit() }
            }
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(canAdvance ? Modernist.surface : Modernist.secondary)
            .padding(.horizontal, 20)
            .frame(minHeight: 50)
            .background(canAdvance ? Modernist.ink : Modernist.hairline)
            .disabled(!canAdvance)
        }
        .padding(16)
        .background(Modernist.surface)
        .overlay(alignment: .top) { Rectangle().fill(Modernist.ink).frame(height: 2) }
    }

    private var canAdvance: Bool { step == 1 ? !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty : step == 2 ? durationAllowed : canCommit }
    private var stepTitle: String { ["Make the promise", "Set the terms", "See the consequence"][step - 1] }
    private var stepSubtitle: String { ["Start with something you can prove.", "The contract is part of the commitment.", "Nothing should surprise you after you agree."][step - 1] }

    private func contractRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label.uppercased()).font(.system(size: 9, weight: .bold)).tracking(1).foregroundStyle(Modernist.secondary)
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Modernist.ink)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom, 10)
        .overlay(alignment: .bottom) { Rectangle().fill(Modernist.hairline).frame(height: 1) }
    }

    private func commit() {
        guard canCommit else { errorMessage = "This commitment exceeds your current tier."; return }
        let goal = GoalRecord(title: title.trimmingCharacters(in: .whitespacesAndNewlines), details: "", deadline: deadline, size: size, evidence: .selfConfirmation, committedCapacity: appState.score)
        modelContext.insert(goal)
        do {
            try modelContext.save()
            Task { await NotificationManager.schedule(for: goal) }
            dismiss()
        } catch {
            modelContext.delete(goal)
            errorMessage = "This commitment could not be saved. Try again."
        }
    }
}
