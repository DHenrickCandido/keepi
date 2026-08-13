import SwiftUI
import FirebaseAuth
import WidgetKit

struct MainTabView: View {
    @StateObject private var interactor = HomeInteractor(
        transactionListManager: TransactionListManager(),
        envelopeListManager: EnvelopeListManager()
    )
    @State private var selectedTab: MainTab = .today

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }
                .tag(MainTab.today)

            EntriesTabView()
                .tabItem {
                    Label("Entries", systemImage: "list.bullet.rectangle")
                }
                .tag(MainTab.entries)



            ReflectView()
                .tabItem {
                    Label("Reflect", systemImage: "sparkles")
                }
                .tag(MainTab.reflect)

            InsightsTabView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.xaxis")
                }
                .tag(MainTab.insights)
        }
        .environmentObject(interactor)
        .accentColor(Color("darkGreenKeepi"))
        .onAppear {
            signInAnonymouslyIfNeeded()
            updateWidgetSnapshot()
        }
        .onChange(of: widgetSnapshotRefreshKey) { _ in
            updateWidgetSnapshot()
        }
        .onOpenURL { url in
            handleDeepLink(url)
        }
        .alert("Something went wrong", isPresented: errorAlertBinding) {
            Button("OK", role: .cancel) {
                interactor.errorMessage = nil
            }
        } message: {
            Text(interactor.errorMessage ?? "Please try again.")
        }
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { interactor.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    interactor.errorMessage = nil
                }
            }
        )
    }

    private var widgetSnapshotRefreshKey: String {
        interactor.listTransactions
            .map { "\($0.id)-\($0.value)-\($0.date.timeIntervalSince1970)-\($0.reflectionCompleted)" }
            .joined(separator: "|")
    }

    private func signInAnonymouslyIfNeeded() {
        if Auth.auth().currentUser != nil {
            interactor.loadData()
            return
        }

        Auth.auth().signInAnonymously { _, error in
            if let error {
                interactor.errorMessage = error.localizedDescription
                return
            }

            interactor.loadData()
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "keepi" else { return }

        if url.host == "add" {
            selectedTab = .today
        }
    }

    private func updateWidgetSnapshot() {
        DailyWidgetDataStore.save(trades: interactor.listTransactions)
        WidgetCenter.shared.reloadTimelines(ofKind: "KeepiDailyWidget")
    }
}

enum MainTab {
    case today
    case entries
    case reflect
    case insights
}

private struct EntriesTabView: View {
    @EnvironmentObject var interactor: HomeInteractor

    @State private var showEditTrade = false
    @State private var selectedTrade = 0
    @State private var searchText = ""
    @State private var selectedFilter: EntryFilter = .all
    @State private var showNewEnvelope = false
    @State private var selectedEnvelopeId: String? = nil

    private var filteredEntries: [TransactionModel] {
        interactor.listTransactions.filter { entry in
            let envelopeName = interactor.getEnvelopeNameById(id: entry.envelopeId)
            let searchableText = ([entry.name, envelopeName, entry.journalEntry])
                .joined(separator: " ")
                .lowercased()
            let matchesSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                searchableText.contains(searchText.lowercased())

            let matchesFilter: Bool
            switch selectedFilter {
            case .all:
                matchesFilter = true
            case .pendingReflection:
                matchesFilter = !entry.reflectionCompleted
            case .worthIt:
                matchesFilter = entry.worthIt == true
            case .wouldSkip:
                matchesFilter = entry.worthIt == false
            }

            return matchesSearch && matchesFilter
        }
        .sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color("lightGrayKeepi")
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    Text("Envelopes & Entries")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("blackKeepi"))

                    envelopesSection

                    searchField
                    filterChips

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            if interactor.listTransactions.isEmpty {
                                emptyEntriesState
                            } else if filteredEntries.isEmpty {
                                emptyFilteredState
                            } else {
                                ForEach(filteredEntries) { entry in
                                    Button {
                                        openEdit(for: entry)
                                    } label: {
                                        TransactionCardComponent(
                                            date: entry.date,
                                            name: entry.name,
                                            value: entry.value,
                                            envelopeName: interactor.getEnvelopeNameById(id: entry.envelopeId),
                                            feeling: entry.feeling,
                                            journalEntry: entry.journalEntry,
                                            onEnvelopeTap: {
                                                selectedEnvelopeId = entry.envelopeId
                                            }
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.bottom, 24)
                    }
                }
                .padding(16)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showEditTrade) {
                if interactor.listTransactions.indices.contains(selectedTrade) {
                    EditTransactionView(
                        showEditTransaction: $showEditTrade,
                        index: selectedTrade,
                        trade: $interactor.listTransactions[selectedTrade],
                        selectedIndex: $selectedTrade
                    )
                    .environmentObject(interactor)
                    .presentationDetents([.fraction(0.9)])
                    .interactiveDismissDisabled()
                }
            }
            .sheet(isPresented: Binding(
                get: { selectedEnvelopeId != nil },
                set: { if !$0 { selectedEnvelopeId = nil } }
            )) {
                EnvelopeDetailSheet(envelopeId: $selectedEnvelopeId)
                    .environmentObject(interactor)
            }
            .sheet(isPresented: $showNewEnvelope) {
                NewEnvelopeView(showNewEnvelope: $showNewEnvelope)
                    .environmentObject(interactor)
                    .presentationDetents([.fraction(0.9)])
                    .interactiveDismissDisabled()
            }
        }
    }

    private var envelopesSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(interactor.listEnvelopes) { envelope in
                    Button {
                        selectedEnvelopeId = envelope.id
                    } label: {
                        EnvelopeCardView(
                            icon: envelope.icon,
                            name: envelope.name,
                            monthlyBudget: envelope.monthlyBudget,
                            spent: interactor.spent(forEnvelopeId: envelope.id),
                            entryCount: interactor.entryCount(forEnvelopeId: envelope.id)
                        )
                    }
                    .buttonStyle(.plain)
                }
                
                Button {
                    showNewEnvelope = true
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color("darkGreenKeepi"))
                            .frame(width: 48, height: 48)
                            .background(Color("lightGreenKeepi").opacity(0.3))
                            .clipShape(Circle())
                        
                        Text("New")
                            .font(.headline)
                            .foregroundColor(Color("blackKeepi"))
                    }
                    .frame(width: 140, height: 160)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var emptyEntriesState: some View {
        VStack(spacing: 12) {
            Image("keepiTrocas")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 160)

            Text("No entries yet")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color("blackKeepi"))

            Text("Use the Add tab to record your first purchase, transaction, or money moment.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(.systemGray))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    private var emptyFilteredState: some View {
        VStack(spacing: 10) {
            Text("No entries match")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color("blackKeepi"))

            Text("Try a different search or filter.")
                .font(.subheadline)
                .foregroundColor(Color(.systemGray))

            Button {
                searchText = ""
                selectedFilter = .all
            } label: {
                Text("Clear filters")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color("darkGreenKeepi"))
                    .cornerRadius(16)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(.systemGray))

            TextField("Search entries, envelopes, motivations", text: $searchText)
                .font(.body)
                .foregroundColor(Color("blackKeepi"))

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(.systemGray))
                }
            }
        }
        .padding(14)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(EntryFilter.allCases, id: \.self) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(filter.title)
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(selectedFilter == filter ? .white : Color("darkGreenKeepi"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedFilter == filter ? Color("darkGreenKeepi") : .white)
                            .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func openEdit(for entry: TransactionModel) {
        guard let index = interactor.listTransactions.firstIndex(where: { $0.id == entry.id }) else {
            return
        }

        selectedTrade = index
        showEditTrade = true
    }
}

private enum EntryFilter: CaseIterable {
    case all
    case pendingReflection
    case worthIt
    case wouldSkip

    var title: String {
        switch self {
        case .all:
            return "All"
        case .pendingReflection:
            return "Reflect later"
        case .worthIt:
            return "Worth it"
        case .wouldSkip:
            return "Would skip"
        }
    }
}

private struct InsightsTabView: View {
    @EnvironmentObject var interactor: HomeInteractor

    var body: some View {
        PremiumInsightsView()
            .environmentObject(interactor)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

struct SettingsView: View {
    @EnvironmentObject private var interactor: HomeInteractor
    @Environment(\.dismiss) private var dismiss
    @AppStorage("notFirstTime") private var notFirstTime = true

    @State private var showDeleteConfirmation = false
    @State private var isDeleting = false
    @State private var deletionError = ""
    @State private var showDeletionError = false
    @State private var showFileImporter = false
    @State private var selectedCSV: URL?
    @State private var showPaywall = false
    
    @EnvironmentObject private var premiumManager: StoreKitPremiumManager

    private let privacyPolicyURL = URL(string: "https://github.com/DHenrickCandido/keepi/blob/main/PRIVACY.md")!
    private let supportURL = URL(string: "mailto:candidohdiego@gmail.com?subject=Keepi%20Support")!

    var body: some View {
        NavigationView {
            Form {
                Section("Premium Features") {
                    Button {
                        if premiumManager.canUse(.csvImport) {
                            showFileImporter = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        HStack {
                            Label("Import CSV", systemImage: "arrow.down.doc")
                            Spacer()
                            if !premiumManager.canUse(.csvImport) {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                Section("Privacy") {
                    NavigationLink("How Keepi uses your data") {
                        PrivacyDetailsView()
                    }

                    Link(destination: privacyPolicyURL) {
                        Label("Privacy policy", systemImage: "hand.raised")
                    }
                }

                Section("Support") {
                    Link(destination: supportURL) {
                        Label("Contact support", systemImage: "envelope")
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        HStack {
                            Label("Delete my data", systemImage: "trash")
                            Spacer()
                            if isDeleting {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isDeleting)
                } footer: {
                    Text("Deletes your entries, envelopes, reflections, and anonymous Keepi account.")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog("Delete all Keepi data?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete permanently", role: .destructive) {
                    deleteAccountData()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This cannot be undone.")
            }
            .alert("Couldn't delete your data", isPresented: $showDeletionError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(deletionError)
            }
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.commaSeparatedText]) { result in
                switch result {
                case .success(let url):
                    self.selectedCSV = url
                case .failure(let error):
                    print("Failed to select file: \(error)")
                }
            }
            .sheet(isPresented: Binding<Bool>(
                get: { self.selectedCSV != nil },
                set: { if !$0 { self.selectedCSV = nil } }
            )) {
                if let url = selectedCSV {
                    CSVImportFlow(fileURL: url)
                        .environmentObject(interactor)
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private func deleteAccountData() {
        guard !isDeleting else { return }
        isDeleting = true
        interactor.deleteAccountData { error in
            DispatchQueue.main.async {
                isDeleting = false
                if let error {
                    deletionError = error.localizedDescription
                    showDeletionError = true
                    return
                }

                notFirstTime = false
                dismiss()
            }
        }
    }
}

private struct PrivacyDetailsView: View {
    var body: some View {
        List {
            Section("Data stored") {
                Text("Keepi stores an anonymous account identifier, your entries, envelope budgets, reflections, feelings, tags, and journal text in Firebase.")
            }

            Section("Purpose") {
                Text("This data is used only to provide syncing, budgeting, reflection, and reporting features. Keepi does not sell your data or use it for advertising or cross-app tracking.")
            }

            Section("Retention and deletion") {
                Text("Data remains until you delete it from Settings. Deleting your data also removes the anonymous account used to sync it.")
            }
        }
        .navigationTitle("Your data")
        .navigationBarTitleDisplayMode(.inline)
    }
}
