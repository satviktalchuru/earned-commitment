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

struct ResearchEntry: Identifiable {
    let id = UUID()
    let theory: String
    let summary: String
    let application: String
    let citation: String
    let url: URL
}

struct ResearchView: View {
    private let entries: [ResearchEntry] = [
        ResearchEntry(
            theory: "Autonomy and intrinsic motivation",
            summary: "People are more likely to sustain behavior when they experience choice, competence, and ownership.",
            application: "You choose the promise, confirm it yourself, and receive recovery work instead of surveillance or public shame.",
            citation: "Ryan & Deci, 2000",
            url: URL(string: "https://doi.org/10.1037/0003-066X.55.1.68")!
        ),
        ResearchEntry(
            theory: "Commitment devices",
            summary: "Precommitting before temptation arrives can help people follow through on intentions they already value.",
            application: "A deadline and a known capacity consequence make the commitment concrete before the difficult moment arrives.",
            citation: "Ariely & Wertenbroch, 2002",
            url: URL(string: "https://doi.org/10.1111/1467-9280.00441")!
        ),
        ResearchEntry(
            theory: "Implementation intentions",
            summary: "Specific plans connect a future situation with an intended action, reducing the gap between wanting and doing.",
            application: "The app asks for one clear promise and a precise deadline instead of a vague intention.",
            citation: "Gollwitzer, 1999",
            url: URL(string: "https://doi.org/10.1037/0003-066X.54.7.493")!
        ),
        ResearchEntry(
            theory: "Specific goal setting",
            summary: "Clear, specific goals provide a stronger target for attention and effort than general goals.",
            application: "The commitment flow starts with a concrete finish line and shows the consequence before you agree.",
            citation: "Locke & Latham, 2002",
            url: URL(string: "https://doi.org/10.1037/0003-066X.57.9.705")!
        ),
        ResearchEntry(
            theory: "Self-efficacy and mastery",
            summary: "Confidence grows through manageable experiences of taking action and succeeding at the next step.",
            application: "Recovery breaks a miss into small confirmations so progress can be rebuilt without pretending the miss did not happen.",
            citation: "Bandura, 1977",
            url: URL(string: "https://doi.org/10.1037/0033-295X.84.2.191")!
        )
    ]

    var body: some View {
        List {
            Section {
                Text("Earned Commitment uses behavioral science as a design input, not as a promise that any technique works for everyone.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
            }
            ForEach(entries) { entry in
                Section(entry.theory) {
                    Text(entry.summary)
                        .font(.body)
                    Text(entry.application)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Link("Read \(entry.citation)", destination: entry.url)
                        .font(.footnote.weight(.semibold))
                }
            }
        }
        .navigationTitle("Behavior research")
        .navigationBarTitleDisplayMode(.inline)
    }
}
