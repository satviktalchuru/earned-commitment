import SwiftUI
import SwiftData

struct RecoveryView: View {
    @Query(sort: \GoalRecord.failedAt) private var goals: [GoalRecord]
    private var recoveryGoals: [GoalRecord] { goals.filter { $0.status == .recovering } }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Recovery").font(.system(size: 30, weight: .black)).padding(.horizontal, 16).padding(.top, 22)
                        Text("Small work restores capacity. The miss stays in your history.").font(.system(size: 13)).foregroundStyle(Modernist.secondary).padding(16)
                        if recoveryGoals.isEmpty {
                            Text("No recovery debt.").font(.system(size: 17, weight: .bold)).padding(16)
                        } else {
                            ForEach(recoveryGoals) { goal in
                                NavigationLink { GoalDetailView(goal: goal) } label: {
                                    CommitmentRow(goal: goal)
                                }.buttonStyle(.plain)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.white)
                .navigationBarHidden(true)
            }
        }
    }
}
