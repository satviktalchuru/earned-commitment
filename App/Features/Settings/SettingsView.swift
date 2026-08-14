import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        List {
            Section("This device") {
                Label("No account or login", systemImage: "iphone")
                Text("Your commitments, score, and history stay on this iPhone.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Section("Reminders") {
                Button {
                    openURL(URL(string: UIApplication.openSettingsURLString)!)
                } label: {
                    Label("Manage notification permissions", systemImage: "bell")
                }
            }
            Section("Why this works") {
                NavigationLink {
                    ResearchView()
                } label: {
                    Label("Behavior research", systemImage: "book")
                }
            }
            Section("Privacy") {
                NavigationLink {
                    PrivacyPolicyView()
                } label: {
                    Label("Privacy policy", systemImage: "hand.raised")
                }
                Link(destination: URL(string: "https://satviktalchuru.github.io/earned-commitment-privacy/")!) {
                    Label("Open online privacy policy", systemImage: "arrow.up.right.square")
                }
                Text("This version stores your data on this iPhone and does not create an account.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Section("Data") {
                Text("Export and delete your data from the History tab.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.title2.weight(.bold))
                Text("Last updated: July 31, 2026")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                policySection("Summary", "Earned Commitment works without an account. Your goals, confirmations, score, recovery state, and history are stored locally on this iPhone. We do not operate a server for these features and do not sell your information.")
                policySection("Information stored on your device", "The app stores the goal information you enter, deadline and commitment state, self-confirmations, score history, recovery actions, and app preferences such as whether onboarding has been shown. This information is used only to provide the app's features.")
                policySection("Notifications", "If you grant permission, the app schedules local notifications for reminders and state changes. Permission can be changed in iOS Settings. Notifications are prompts; the app's local data remains the source of truth.")
                policySection("Sharing and tracking", "Earned Commitment does not require login, include advertising, use analytics or tracking SDKs, or share your goal data with us or third parties.")
                policySection("Export and deletion", "You can export your local data from History and delete the app's stored data from the same area. Deleting the app also removes its locally stored data according to iOS behavior.")
                policySection("Children", "The app is not directed to children under 13, and it does not knowingly collect personal information from children.")
                policySection("Changes and contact", "We may update this policy when the app's data practices change. Before release, the hosted version of this policy will include the publisher's support contact and an effective date.")
            }
            .padding(20)
        }
        .navigationTitle("Privacy policy")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func policySection(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(body)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}

struct ResearchView: View {
    private let cards = [
        ("Choice builds ownership", "I learned that intrinsic motivation is stronger when people choose their own direction and can see their progress. My interpretation is that the app should let you define the commitment and confirm it yourself, rather than rely on surveillance."),
        ("A commitment changes the decision", "My economics coursework helped me see deadlines as a simple commitment device: deciding in advance can protect a future intention from a present impulse. The app makes the finish line and capacity consequence visible before you agree."),
        ("Specific plans reduce friction", "I learned that a clear action is easier to follow than a broad intention. My interpretation is that one concrete promise, paired with a precise deadline, gives attention a practical target."),
        ("Recovery should rebuild capability", "My interpretation of mastery and self-efficacy is that a miss should be acknowledged without making progress feel impossible. Small recovery commitments let you earn capacity back through consistent action.")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("What I learned")
                    .font(.title2.weight(.bold))
                Text("These four summaries are my own interpretations of ideas I encountered in economics classes at UCSB. They are design input for Earned Commitment, not medical advice or a guarantee that any approach works for everyone.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                ForEach(cards, id: \.0) { title, summary in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.headline)
                        Text(summary)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(20)
        }
        .navigationTitle("What I learned")
        .navigationBarTitleDisplayMode(.inline)
    }
}
