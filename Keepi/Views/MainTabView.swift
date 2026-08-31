import SwiftUI
import FirebaseAuth
import WidgetKit

struct MainTabView: View {
    @StateObject private var interactor = HomeInteractor(
        transactionListManager: TransactionListManager(),
        envelopeListManager: EnvelopeListManager()
    )
    @State private var selectedTab: MainTab = .today
    @State private var addEntryRequest = UUID()
    @ObservedObject private var draftManager = DraftManager.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(selectedTab: $selectedTab, addEntryRequest: addEntryRequest)
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
                .badge(draftManager.drafts.count)
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
            addEntryRequest = UUID()
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
    @State private var showNewEntry = false
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

                    entryActions

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
                                            type: entry.type,
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
            .sheet(isPresented: $showNewEntry) {
                NewTransactionView(showNewTrade: $showNewEntry, interactor: interactor)
                    .presentationDetents([.fraction(0.9)])
                    .interactiveDismissDisabled()
            }
        }
    }

    private var entryActions: some View {
        HStack(spacing: 10) {
            CSVImportLauncherButton {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.down.doc.fill")
                    Text("Import statement")
                        .lineLimit(1)
                }
                .font(.subheadline.bold())
                .foregroundColor(Color("darkGreenKeepi"))
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(Color("lightGreenKeepi").opacity(0.24))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)

            Button {
                showNewEntry = true
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "plus")
                    Text("New entry")
                        .lineLimit(1)
                }
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(Color("darkGreenKeepi"))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
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
                    .frame(width: 140)
                    .frame(minHeight: 170)
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

            Text("Add one entry or import a statement to bring in several purchases at once.")
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

    @EnvironmentObject private var premiumManager: StoreKitPremiumManager

    private let privacyPolicyURL = URL(string: "https://github.com/mashiruwu/keepi/blob/main/PRIVACY.md")!
    private let supportURL = URL(string: "mailto:candidohdiego@gmail.com?subject=Keepi%20Support")!

    var body: some View {
        NavigationView {
            ZStack {
                Color("lightGrayKeepi").ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Text("Settings")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("blackKeepi"))
                        Spacer()
                    }
                    .overlay(
                        HStack {
                            Spacer()
                            Button("Done") { dismiss() }
                                .font(.headline)
                                .foregroundColor(Color("darkGreenKeepi"))
                        }
                    )
                    .padding()

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Premium Features")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.systemGray))
                                    .padding(.horizontal, 8)

                                CSVImportLauncherButton {
                                    HStack {
                                        Label("Import statement", systemImage: "arrow.down.doc")
                                        Spacer()
                                        if !premiumManager.canUse(.csvImport) {
                                            Image(systemName: "lock.fill")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
                                }
                                .buttonStyle(.plain)
                                .foregroundColor(Color("blackKeepi"))
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Privacy")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.systemGray))
                                    .padding(.horizontal, 8)

                                VStack(spacing: 0) {
                                    NavigationLink {
                                        PrivacyDetailsView()
                                    } label: {
                                        HStack {
                                            Text("How Keepi uses your data")
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                                .font(.footnote)
                                        }
                                        .padding()
                                        .foregroundColor(Color("blackKeepi"))
                                    }

                                    Divider()
                                        .padding(.horizontal)

                                    Link(destination: privacyPolicyURL) {
                                        HStack {
                                            Label("Privacy policy", systemImage: "hand.raised.fill")
                                            Spacer()
                                            Image(systemName: "arrow.up.right")
                                                .foregroundColor(.gray)
                                                .font(.footnote)
                                        }
                                        .padding()
                                        .foregroundColor(Color("blackKeepi"))
                                    }
                                }
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Support")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.systemGray))
                                    .padding(.horizontal, 8)

                                Link(destination: supportURL) {
                                    HStack {
                                        Label("Contact support", systemImage: "envelope.fill")
                                        Spacer()
                                        Image(systemName: "arrow.up.right")
                                            .foregroundColor(.gray)
                                            .font(.footnote)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
                                    .foregroundColor(Color("blackKeepi"))
                                }
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Button(role: .destructive) {
                                    showDeleteConfirmation = true
                                } label: {
                                    HStack {
                                        Label("Delete my data", systemImage: "trash.fill")
                                        Spacer()
                                        if isDeleting {
                                            ProgressView()
                                        }
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
                                }
                                .disabled(isDeleting)

                                Text("Deletes your entries, envelopes, reflections, and anonymous Keepi account.")
                                    .font(.footnote)
                                    .foregroundColor(Color(.systemGray))
                                    .padding(.horizontal, 8)
                            }

                        }
                        .padding(16)
                    }
                }
            }
            .navigationBarHidden(true)
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
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color("lightGrayKeepi").ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(Color("darkGreenKeepi"))
                    }
                    Spacer()
                    Text("Your data")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("blackKeepi"))
                    Spacer()
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .opacity(0)
                }
                .padding()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        PrivacySection(title: "Data stored", text: "Keepi stores your anonymous account identifier, entries, envelope budgets, reflections, feelings, and journal text in Firebase. Pending CSV imports are stored locally on this device, and a limited daily snapshot is shared with the Keepi widget.")

                        PrivacySection(title: "Purpose", text: "This data is used only to provide syncing, budgeting, reflection, and reporting features. Keepi does not sell your data or use it for advertising or cross-app tracking.")

                        PrivacySection(title: "Retention and deletion", text: "Data remains until you delete it from Settings. Deleting your data removes the anonymous sync account, imported drafts, learned categorization rules, and widget snapshot.")
                    }
                    .padding(16)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

private struct PrivacySection: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color("blackKeepi"))

            Text(text)
                .font(.body)
                .foregroundColor(Color(.darkGray))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
    }
}
