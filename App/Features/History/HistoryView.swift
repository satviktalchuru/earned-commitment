import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query(sort: \LedgerEntry.createdAt, order: .reverse) private var entries: [LedgerEntry]
    @Query private var goals: [GoalRecord]
    @State private var exportURL: URL?
    @State private var showingDeleteConfirmation = false
    @State private var errorMessage: String?

    private var kept: Int { goals.filter { $0.status == .completed || $0.status == .recovered }.count }
    private var missed: Int { goals.filter { $0.status == .recovering || $0.status == .recovered || $0.status == .released }.count }
    private var percentage: Int { let total = kept + missed; return total == 0 ? 0 : Int(Double(kept) / Double(total) * 100) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("History").font(.system(size: 30, weight: .black)).padding(.horizontal, 16).padding(.top, 22)
                    HStack(spacing: 1) {
                        stat("KEPT", "\(percentage)%")
                        stat("STREAK", "\(kept)")
                        stat("MISSED", "\(missed)")
                    }
                    .background(Modernist.hairline)
                    .padding(16)
                    Text("CAPACITY LEDGER").font(.system(size: 10, weight: .bold)).tracking(1.4).foregroundStyle(Modernist.secondary).padding(.horizontal, 16).padding(.top, 10).padding(.bottom, 9)
                    if entries.isEmpty {
                        Text("Your capacity changes will appear here.").font(.system(size: 14)).padding(16)
                    } else {
                        ForEach(entries) { entry in
                            HStack(spacing: 10) {
                                Rectangle().fill(entry.delta >= 0 ? Modernist.kept : Modernist.missed).frame(width: 3)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.reason).font(.system(size: 13, weight: .bold))
                                    Text(entry.createdAt, format: .dateTime.month(.abbreviated).day().hour().minute()).font(.system(size: 11)).foregroundStyle(Modernist.secondary)
                                }
                                Spacer()
                                Text(entry.delta >= 0 ? "+\(entry.delta)" : "−\(-entry.delta)").font(.system(size: 15, weight: .black)).foregroundStyle(entry.delta >= 0 ? Modernist.kept : Modernist.missed)
                            }
                            .padding(13)
                            .background(Modernist.surface)
                            .overlay(alignment: .bottom) { Rectangle().fill(Modernist.hairline).frame(height: 1) }
                        }
                    }
                }
            }
            .background(Modernist.canvas)
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if let exportURL {
                        ShareLink(item: exportURL) { Image(systemName: "square.and.arrow.up") }
                            .accessibilityLabel("Share exported data")
                    } else {
                        Button { exportData() } label: { Image(systemName: "square.and.arrow.up") }
                            .accessibilityLabel("Export commitment data")
                    }
                    Button(role: .destructive) { showingDeleteConfirmation = true } label: { Image(systemName: "trash") }
                        .accessibilityLabel("Delete all commitment data")
                }
            }
            .confirmationDialog("Delete all commitment data?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete all data", role: .destructive) { deleteData() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This permanently removes goals, recovery history, and the capacity ledger from this device.")
            }
            .alert("Data action failed", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK") { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
        }
    }

    private func exportData() {
        do { exportURL = try DataManager.exportURL(context: modelContext) }
        catch { errorMessage = error.localizedDescription }
    }

    private func deleteData() {
        Task { @MainActor in
            do { try await DataManager.deleteAll(context: modelContext, appState: appState) }
            catch { errorMessage = error.localizedDescription }
        }
    }

    private func stat(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label).font(.system(size: 9, weight: .bold)).tracking(1).foregroundStyle(Modernist.secondary)
            Text(value).font(.system(size: 24, weight: .black))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Modernist.surface)
    }
}
