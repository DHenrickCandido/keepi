import SwiftUI
import Firebase
import WidgetKit

struct MainTabView: View {
    @StateObject private var interactor = HomeInteractor(
        tradeListManager: TradeListManager(),
        envelopeListManager: EnvelopeListManager()
    )
    @State private var selectedTab: MainTab = .today

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }
                .tag(MainTab.today)

            EntriesTabView()
                .tabItem {
                    Label("Entries", systemImage: "list.bullet.rectangle")
                }
                .tag(MainTab.entries)

            AddEntryView()
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }
                .tag(MainTab.add)

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
    }

    private var widgetSnapshotRefreshKey: String {
        interactor.listTrades
            .map { "\($0.id)-\($0.value)-\($0.date.timeIntervalSince1970)" }
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
            selectedTab = .add
        }
    }

    private func updateWidgetSnapshot() {
        DailyWidgetDataStore.save(trades: interactor.listTrades)
        WidgetCenter.shared.reloadTimelines(ofKind: "KeepiDailyWidget")
    }
}

private enum MainTab {
    case today
    case entries
    case add
    case reflect
    case insights
}

private struct EntriesTabView: View {
    @EnvironmentObject var interactor: HomeInteractor

    @State private var showEditTrade = false
    @State private var selectedTrade = 0

    var body: some View {
        NavigationView {
            ZStack {
                Color("lightGrayKeepi")
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    Text("Entries")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("blackKeepi"))

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            if interactor.listTrades.isEmpty {
                                emptyEntriesState
                            } else {
                                ListaCompra(showEditView: $showEditTrade, selectedTrade: $selectedTrade)
                            }
                        }
                        .padding(.bottom, 24)
                    }
                }
                .padding(16)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showEditTrade) {
                if interactor.listTrades.indices.contains(selectedTrade) {
                    EditTradeView(
                        showEditTrade: $showEditTrade,
                        index: selectedTrade,
                        trade: $interactor.listTrades[selectedTrade],
                        selectedIndex: $selectedTrade
                    )
                    .environmentObject(interactor)
                    .presentationDetents([.fraction(0.9)])
                    .interactiveDismissDisabled()
                }
            }
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
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

private struct InsightsTabView: View {
    @EnvironmentObject var interactor: HomeInteractor

    var body: some View {
        NavigationView {
            ZStack {
                Color("lightGrayKeepi")
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Insights")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color("blackKeepi"))

                        // MostTradesView expects non-empty spending totals, so show a stable empty state first.
                        if interactor.listTrades.isEmpty {
                            Text("Add entries to see spending patterns.")
                                .font(.headline)
                                .foregroundColor(Color(.systemGray))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .background(.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
                        } else {
                            MostTradesView()
                        }
                    }
                    .padding(16)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
