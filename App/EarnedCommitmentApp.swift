import SwiftUI
import SwiftData
import Observation
import BackgroundTasks

@MainActor
@Observable
final class AppState {
    var score: Int = LedgerStore.startingScore
    var errorMessage: String?

    func refresh(context: ModelContext) {
        do {
            score = try LedgerStore.currentScore(context: context)
            errorMessage = nil
        } catch {
            errorMessage = "Your local score could not be refreshed."
        }
    }
}

@main
struct EarnedCommitmentApp: App {
    @State private var modelContainer: ModelContainer?
    @State private var storageErrorMessage: String?

    init() {
        DeadlineRefreshScheduler.register()
        do {
            _modelContainer = State(initialValue: try ModelContainerFactory.make())
        } catch {
            _modelContainer = State(initialValue: nil)
            _storageErrorMessage = State(initialValue: "The app could not open its local data.")
        }
    }

    var body: some Scene {
        WindowGroup {
            if let modelContainer {
                AppShellView()
                    .modelContainer(modelContainer)
            } else {
                StorageFailureView(message: storageErrorMessage ?? "The app could not access its local data.") {
                    do {
                        modelContainer = try ModelContainerFactory.make()
                        storageErrorMessage = nil
                    } catch {
                        storageErrorMessage = "The app could not open its local data. Relaunch and try again."
                    }
                }
            }
        }
    }
}

struct AppShellView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var goals: [GoalRecord]
    @Query private var ledger: [LedgerEntry]
    @State private var appState = AppState()
    @State private var showNotificationEducation = false
    @State private var showFirstOpenGuide = false
    @AppStorage("firstOpenGuideSeen") private var firstOpenGuideSeen = false
    @AppStorage("notificationEducationSeen") private var notificationEducationSeen = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        RootView()
            .environment(appState)
            .preferredColorScheme(.light)
            .alert("Local data unavailable", isPresented: Binding(get: { appState.errorMessage != nil }, set: { if !$0 { appState.errorMessage = nil } })) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(appState.errorMessage ?? "The app could not refresh local data.")
            }
            .sheet(isPresented: $showFirstOpenGuide, onDismiss: {
                if !notificationEducationSeen {
                    notificationEducationSeen = true
                    showNotificationEducation = true
                }
            }) {
                FirstOpenGuideView()
            }
            .sheet(isPresented: $showNotificationEducation) {
                NotificationEducationView()
            }
            .task {
                await refreshDeadlines()
                if !firstOpenGuideSeen {
                    firstOpenGuideSeen = true
                    showFirstOpenGuide = true
                } else if !notificationEducationSeen {
                    notificationEducationSeen = true
                    showNotificationEducation = true
                }
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    Task { await refreshDeadlines() }
                } else if phase == .background {
                    DeadlineRefreshScheduler.schedule()
                }
            }
    }

    @MainActor
    private func refreshDeadlines() async {
        appState.refresh(context: modelContext)
        let evaluation: DeadlineEvaluation
        do {
            evaluation = try DeadlineProcessor.process(goals: goals, context: modelContext, appState: appState)
        } catch {
            appState.errorMessage = "Your deadlines could not be evaluated."
            return
        }
        for goal in goals { await NotificationManager.cancel(for: goal.identifier) }
        for goal in goals where goal.status == .committed || goal.status == .recovering {
            await NotificationManager.schedule(for: goal)
            if goal.status == .recovering { await NotificationManager.scheduleRecovery(for: goal) }
        }
        for goalID in evaluation.missedGoalIDs {
            if let goal = goals.first(where: { $0.identifier == goalID }) {
                await NotificationManager.scheduleMissed(for: goal)
            }
        }
    }
}

struct FirstOpenGuideView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image("EarnedCommitmentLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)
                .accessibilityHidden(true)
            Text("How it works")
                .font(.system(size: 30, weight: .black))
                .foregroundStyle(Modernist.ink)
            Text("Earned Commitment helps you make fewer promises and finish more of them.")
                .font(.system(size: 15))
                .foregroundStyle(Modernist.secondary)
            GuideRow(number: "1", title: "Make a promise", detail: "Choose one goal and a real deadline.")
            GuideRow(number: "2", title: "Confirm it", detail: "Mark it complete before the deadline.")
            GuideRow(number: "3", title: "Recover if you miss", detail: "A missed promise reduces capacity and opens small recovery work.")
            Text("Your data stays on this iPhone. There is no account or login.")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Modernist.ink)
                .padding(.top, 4)
            Spacer()
            Button("Get started") { dismiss() }
                .buttonStyle(ModernistPrimaryButton())
        }
        .padding(22)
        .background(Modernist.canvas)
    }
}

struct GuideRow: View {
    let number: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.system(size: 14, weight: .black))
                .frame(width: 28, height: 28)
                .background(Modernist.ink)
                .foregroundStyle(Modernist.surface)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 15, weight: .bold)).foregroundStyle(Modernist.ink)
                Text(detail).font(.system(size: 13)).foregroundStyle(Modernist.secondary).fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct StorageFailureView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: "externaldrive.badge.xmark").font(.system(size: 36))
            Text("Your commitments could not be opened.").font(.system(size: 24, weight: .black))
            Text(message).foregroundStyle(.secondary)
            Button("Try again", action: retry)
                .buttonStyle(ModernistPrimaryButton())
        }
        .padding(24)
    }
}

struct NotificationEducationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isRequesting = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Stay aware, not controlled.").font(.system(size: 29, weight: .black))
            Text("Notifications are reminders for your deadlines and recovery work. They never decide whether you completed a goal.").font(.system(size: 15)).foregroundStyle(.secondary)
            Spacer()
            if let errorMessage { Text(errorMessage).font(.footnote).foregroundStyle(.red) }
            Button("Allow deadline reminders") {
                isRequesting = true
                Task {
                    do { _ = try await NotificationManager.requestAuthorization(); dismiss() }
                    catch { errorMessage = "Notifications could not be enabled. You can change this later in Settings." }
                    isRequesting = false
                }
            }
            .buttonStyle(ModernistPrimaryButton())
            .disabled(isRequesting)
            Button("Not now") { dismiss() }
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .padding(22)
        .background(Modernist.canvas)
    }
}
