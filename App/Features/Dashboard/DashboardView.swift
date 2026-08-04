import SwiftUI
import SwiftData

enum Modernist {
    static let canvas = Color(red: 0.953, green: 0.949, blue: 0.949)
    static let surface = Color.white
    static let ink = Color(red: 0.125, green: 0.118, blue: 0.114)
    static let secondary = Color(red: 0.376, green: 0.365, blue: 0.365)
    static let hairline = Color(red: 0.843, green: 0.827, blue: 0.827)
    static let kept = Color(red: 0.059, green: 0.478, blue: 0.275)
    static let missed = Color(red: 0.925, green: 0.188, blue: 0.075)
    static let missTint = Color(red: 1.0, green: 0.878, blue: 0.851)
    static let completeTint = Color(red: 0.894, green: 0.941, blue: 0.910)
}

struct RootView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "square.grid.2x2") }
            RecoveryView()
                .tabItem { Label("Recovery", systemImage: "arrow.uturn.backward") }
            HistoryView()
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
        }
        .tint(Modernist.ink)
    }
}

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query(sort: \GoalRecord.deadline) private var goals: [GoalRecord]
    @State private var showingCreate = false
    @State private var showingCapacity = false
    @State private var showingMiss = false
    @State private var missedGoal: GoalRecord?

    private var policy: CapacityPolicy {
        let tier = CapacityTier.forScore(appState.score)
        return CapacityPolicy(score: appState.score, tier: tier, openSlots: max(0, tier.slots - openGoals.count))
    }
    private var openGoals: [GoalRecord] { goals.filter { $0.status == .committed || $0.status == .recovering } }
    private var recoveryGoals: [GoalRecord] { goals.filter { $0.status == .recovering } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    CapacityCard(policy: policy, score: appState.score, usedSlots: openGoals.count) {
                        showingCapacity = true
                    }
                    if !recoveryGoals.isEmpty { RecoveryBanner(count: recoveryGoals.count) }
                    sectionTitle("OPEN COMMITMENTS")
                    if openGoals.isEmpty {
                        EmptyCommitmentsView { showingCreate = true }
                    } else {
                        VStack(spacing: 0) {
                            ForEach(openGoals) { goal in
                                NavigationLink { GoalDetailView(goal: goal) } label: { CommitmentRow(goal: goal) }
                                    .buttonStyle(.plain)
                            }
                        }
                        .background(Modernist.surface)
                    }
                    sectionTitle("MAKE A PROMISE")
                    Button {
                        showingCreate = true
                    } label: {
                        HStack {
                            Text(policy.hasOpenSlot ? "Make a commitment" : "No open slot at Tier \(policy.tier.rawValue)")
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(policy.hasOpenSlot ? Modernist.surface : Modernist.secondary)
                        .padding(.horizontal, 16)
                        .frame(minHeight: 52)
                        .background(policy.hasOpenSlot ? Modernist.ink : Modernist.hairline)
                    }
                    .disabled(!policy.hasOpenSlot)
                    if !policy.hasOpenSlot {
                        Text("Complete or recover an open commitment to create another.")
                            .font(.system(size: 12))
                            .foregroundStyle(Modernist.secondary)
                            .padding(.top, 8)
                    }
                }
            }
            .background(Modernist.canvas)
            .scrollIndicators(.hidden)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingCreate) { CreateGoalView(policy: policy) }
            .sheet(isPresented: $showingCapacity) { CapacityExplanationView(policy: policy) }
            .sheet(isPresented: $showingMiss) {
                if let missedGoal { MissedModal(goal: missedGoal) }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            Image("EarnedCommitmentLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .accessibilityLabel("Earned Commitment")
            VStack(alignment: .leading, spacing: 5) {
                Text(Date.now, format: .dateTime.weekday(.wide).month(.abbreviated).day())
                    .font(.system(size: 12, weight: .bold))
                    .tracking(1.2)
                    .textCase(.uppercase)
                    .foregroundStyle(Modernist.secondary)
                Text("Today")
                    .font(.system(size: 30, weight: .black))
                    .foregroundStyle(Modernist.ink)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 10) {
                NavigationLink { SettingsView() } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Modernist.ink)
                        .frame(width: 32, height: 32)
                }
                .accessibilityLabel("Settings")
                Text("\(openGoals.count) OPEN")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(Modernist.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 22)
        .padding(.bottom, 18)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .bold))
            .tracking(1.5)
            .foregroundStyle(Modernist.secondary)
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 9)
    }

}

struct CapacityCard: View {
    let policy: CapacityPolicy
    let score: Int
    let usedSlots: Int
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("COMMITMENT CAPACITY")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.3)
                        .foregroundStyle(Modernist.secondary)
                    Text("\(score)")
                        .font(.system(size: 44, weight: .black))
                        .foregroundStyle(stateColor)
                }
                Spacer()
                Text(policy.tier.name.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(stateColor)
            }
            HStack(spacing: 3) {
                ForEach(1...5, id: \.self) { index in
                    Rectangle()
                        .fill(index <= usedSlots ? Modernist.ink : (index <= policy.tier.slots ? Modernist.ink.opacity(0.28) : Modernist.hairline))
                        .frame(height: 13)
                }
            }
            HStack(spacing: 18) {
                metric("DURATION", policy.durationLabel)
                metric("SIZE", policy.tier.maximumSize.label)
                metric("SLOTS", "\(policy.openSlots)/\(policy.tier.slots)")
            }
            Text(policy.tier == .standing ? "Holding steady. Keep promises to extend your ceiling." : "Your ceiling is based on recent follow-through.")
                .font(.system(size: 12))
                .foregroundStyle(Modernist.secondary)
            Button("Why this tier", action: action)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Modernist.ink)
                .underline()
        }
        .padding(16)
        .background(Modernist.surface)
        .overlay(Rectangle().stroke(Modernist.ink, lineWidth: 2))
        .padding(.horizontal, 16)
    }

    private func metric(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label).font(.system(size: 9, weight: .bold)).tracking(1).foregroundStyle(Modernist.secondary)
            Text(value).font(.system(size: 12, weight: .bold)).foregroundStyle(Modernist.ink)
        }
    }

    private var stateColor: Color { score >= 55 ? Modernist.kept : Modernist.missed }
}

struct CommitmentRow: View {
    let goal: GoalRecord
    var body: some View {
        HStack(spacing: 12) {
            Rectangle().fill(goal.status == .recovering ? Modernist.missed : Modernist.ink).frame(width: 3)
            VStack(alignment: .leading, spacing: 5) {
                Text(goal.title).font(.system(size: 15, weight: .bold)).foregroundStyle(Modernist.ink).lineLimit(2)
                Text(goal.deadline, format: .dateTime.month(.abbreviated).day().hour().minute()).font(.system(size: 12)).foregroundStyle(Modernist.secondary)
            }
            Spacer()
            Text(goal.status.label.uppercased()).font(.system(size: 9, weight: .bold)).tracking(1).foregroundStyle(goal.status == .recovering ? Modernist.missed : Modernist.secondary)
        }
        .padding(.horizontal, 13)
        .frame(minHeight: 70)
        .background(Modernist.surface)
        .overlay(alignment: .bottom) { Rectangle().fill(Modernist.hairline).frame(height: 1) }
    }
}

struct RecoveryBanner: View {
    let count: Int
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.uturn.backward.circle.fill")
            VStack(alignment: .leading, spacing: 3) {
                Text("RECOVERY WORK")
                    .font(.system(size: 10, weight: .bold)).tracking(1).foregroundStyle(Modernist.missed)
                Text("\(count) commitment\(count == 1 ? "" : "s") need recovery.")
                    .font(.system(size: 12, weight: .bold)).foregroundStyle(Modernist.ink)
            }
        }
        .foregroundStyle(Modernist.missed)
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Modernist.missTint)
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
}

struct EmptyCommitmentsView: View {
    let action: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nothing open yet.").font(.system(size: 15, weight: .bold))
            Button("Make a commitment", action: action).font(.system(size: 13, weight: .bold)).underline()
        }
        .foregroundStyle(Modernist.ink)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Modernist.surface)
    }
}

struct CapacityExplanationView: View {
    @Environment(\.dismiss) private var dismiss
    let policy: CapacityPolicy
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text("Your capacity is a limit on how much you can promise at once. Keep commitments to unlock more duration, size, and slots.")
                    .font(.system(size: 16))
                ForEach(CapacityTier.allCases) { tier in
                    HStack {
                        Text("TIER \(tier.rawValue)").font(.system(size: 10, weight: .bold)).tracking(1)
                        Text(tier.name).font(.system(size: 14, weight: tier == policy.tier ? .black : .regular))
                        Spacer()
                        Text(tier == policy.tier ? "CURRENT" : "\(tier.floor)+")
                            .font(.system(size: 10, weight: .bold)).foregroundStyle(tier == policy.tier ? Modernist.kept : Modernist.secondary)
                    }
                    .padding(.vertical, 10)
                    .overlay(alignment: .bottom) { Rectangle().fill(Modernist.hairline).frame(height: 1) }
                }
                Spacer()
            }
            .padding(16)
            .background(Modernist.canvas)
            .navigationTitle("Why this tier")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }
}
