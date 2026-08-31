import SwiftUI

struct TodayView: View {
    @EnvironmentObject var interactor: HomeInteractor

    @State private var showNewTrade = false
    @State private var showEditTrade = false
    @State private var selectedTrade = 0
    @State private var showSettings = false
    @State private var showPaywall = false
    @AppStorage("didDismissCSVImportDiscovery") private var didDismissCSVImportDiscovery = false
    @Binding var selectedTab: MainTab
    let addEntryRequest: UUID

    @EnvironmentObject var premiumManager: StoreKitPremiumManager
    @ObservedObject var draftManager = DraftManager.shared

    private var todayEntries: [TransactionModel] {
        interactor.listTransactions
            .filter { Calendar.current.isDateInToday($0.date) }
            .sorted { $0.date > $1.date }
    }

    private var totalSpentToday: Decimal {
        todayEntries.reduce(0) { $0 + $1.spendingAmount }
    }


    private var morningEntries: [TransactionModel] {
        entries(for: 5..<12)
    }

    private var afternoonEntries: [TransactionModel] {
        entries(for: 12..<18)
    }

    private var eveningEntries: [TransactionModel] {
        todayEntries.filter { entry in
            let hour = Calendar.current.component(.hour, from: entry.date)
            return hour >= 18 || hour < 5
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(height: 240)
                            .foregroundColor(Color("darkGreenKeepi"))
                            .roundedCorner(16, corners: [.bottomLeft, .bottomRight])

                        HStack(alignment: .top) {
                            Image("keepi")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 40)

                            Spacer()

                            Button {
                                showSettings = true
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .font(.title3)
                                    .foregroundColor(Color("darkGreenKeepi"))
                                    .frame(width: 44, height: 44)
                                    .background(.white)
                                    .clipShape(Circle())
                            }
                            .accessibilityLabel("Settings")

                            Image("keepiMascote")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 120)
                        }
                        .padding(.horizontal, 16)
                    }

                    Spacer()
                }
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 46)

                    todaySummaryCard



                    VStack(spacing: 16) {
                        HStack {
                            Text("Today's entries")
                                .font(.title2)
                                .fontWeight(.semibold)

                            Spacer()

                            CSVImportLauncherButton {
                                Image(systemName: "arrow.down.doc.fill")
                                    .font(.headline)
                                    .foregroundColor(Color("darkGreenKeepi"))
                                    .frame(width: 44, height: 44)
                                    .background(Color("lightGreenKeepi").opacity(0.28))
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Import statement")

                            Button {
                                showNewTrade.toggle()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.app.fill")
                                        .font(.title)
                                        .foregroundColor(Color("lightGreenKeepi"))

                                    Text("New Entry")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color("darkGreenKeepi"))
                                .cornerRadius(16)
                            }
                        }

                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 16) {
                                if interactor.listTransactions.count < 5 && !didDismissCSVImportDiscovery {
                                    importDiscoveryCard
                                }

                                if draftManager.drafts.count > 0 {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("\(draftManager.drafts.count) purchases")
                                                .font(.headline)
                                            Text("need reflection")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Button("Review") {
                                            if premiumManager.canUse(.reviewInbox) {
                                                selectedTab = .reflect
                                            } else {
                                                showPaywall = true
                                            }
                                        }
                                        .font(.headline)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color("darkGreenKeepi"))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
                                    .padding(.bottom, 8)
                                }
                                
                                if let reflection = WeeklyReflectionEngine.generateReflection(
                                    for: interactor.listTransactions,
                                    unreviewedDraftsCount: draftManager.drafts.count,
                                    envelopes: interactor.listEnvelopes
                                ) {
                                    if premiumManager.canUse(.weeklyReflection) {
                                        NavigationLink(destination: WeeklyReflectionView(reflection: reflection)) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("Your weekly reflection is ready")
                                                        .font(.headline)
                                                        .foregroundColor(Color("blackKeepi"))
                                                    Text("See your week")
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray)
                                                }
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(.gray)
                                            }
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(16)
                                            .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.bottom, 8)
                                    } else {
                                        Button {
                                            showPaywall = true
                                        } label: {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("Your weekly reflection is ready")
                                                        .font(.headline)
                                                        .foregroundColor(Color("blackKeepi"))
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "lock.fill")
                                                            .font(.caption)
                                                        Text("Premium")
                                                    }
                                                    .font(.subheadline)
                                                    .foregroundColor(Color("darkGreenKeepi"))
                                                }
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(.gray)
                                            }
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(16)
                                            .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.bottom, 8)
                                    }
                                }

                                if todayEntries.isEmpty {
                                    emptyTodayState
                                } else {
                                    timelineSection(title: "Morning", entries: morningEntries)
                                    timelineSection(title: "Afternoon", entries: afternoonEntries)
                                    timelineSection(title: "Evening", entries: eveningEntries)
                                }
                            }
                            .padding(.bottom, 24)
                        }
                    }
                }
                .padding(16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("lightGrayKeepi"))
            .navigationBarHidden(true)
            .sheet(isPresented: $showNewTrade) {
                NewTransactionView(showNewTrade: $showNewTrade, interactor: interactor)
                    .presentationDetents([.fraction(0.9)])
                    .interactiveDismissDisabled()
            }
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
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(interactor)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .onChange(of: addEntryRequest) { _ in
                showNewTrade = true
            }
        }
    }

    private var todaySummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(Color(.gray))

                    Text(TransactionListManager.date2string(date: Date(), dateFormat: "dd MMM"))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("blackKeepi"))
                }

                Spacer()

                Image(systemName: "sun.max.fill")
                    .font(.title2)
                    .foregroundColor(Color("darkGreenKeepi"))
                    .frame(width: 44, height: 44)
                    .background(Color("lightGrayKeepi"))
                    .clipShape(Circle())
            }

            HStack(spacing: 12) {
                summaryMetric(title: "Spent today", value: KeepiFormat.currency(totalSpentToday))
                summaryMetric(title: "Entries", value: "\(todayEntries.count)")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
    }

    private var emptyTodayState: some View {
        VStack(spacing: 12) {
            Image("keepiTrocas")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 160)

            Text("No entries today")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color("blackKeepi"))

            Text("Add one now, then reflect right away or save it for later.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(.systemGray))

            Button {
                showNewTrade = true
            } label: {
                Text("Add today's first entry")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color("darkGreenKeepi"))
                    .cornerRadius(16)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private var importDiscoveryCard: some View {
        HStack(alignment: .top, spacing: 8) {
            CSVImportLauncherButton {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.white.opacity(0.72))
                            .frame(width: 64, height: 64)

                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 27, weight: .semibold))
                            .foregroundColor(Color("darkGreenKeepi"))

                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color("darkGreenKeepi"))
                            .background(.white, in: Circle())
                            .offset(x: 22, y: 22)
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Bring your spending into Keepi")
                            .font(.headline)
                            .foregroundColor(Color("blackKeepi"))

                        Text("Import a CSV statement, review it, then reflect at your own pace.")
                            .font(.footnote)
                            .foregroundColor(Color("blackKeepi").opacity(0.66))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityHint("Choose a CSV file from your bank or finance app")

            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    didDismissCSVImportDiscovery = true
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.caption.bold())
                    .foregroundColor(Color("blackKeepi").opacity(0.62))
                    .frame(width: 32, height: 32)
                    .background(.white.opacity(0.72), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss import suggestion")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color("lightGreenKeepi").opacity(0.36),
                    Color("lightGreenKeepi").opacity(0.16)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func summaryMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote)
                .foregroundColor(Color(.systemGray))

            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color("blackKeepi"))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color("lightGrayKeepi"))
        .cornerRadius(12)
    }

    @ViewBuilder
    private func timelineSection(title: String, entries: [TransactionModel]) -> some View {
        if !entries.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(Color(.gray))

                ForEach(entries) { entry in
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
                            journalEntry: entry.journalEntry
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func entries(for range: Range<Int>) -> [TransactionModel] {
        todayEntries.filter { entry in
            let hour = Calendar.current.component(.hour, from: entry.date)
            return range.contains(hour)
        }
    }

    private func mostFrequentValue<Value: Hashable>(_ values: [Value]) -> Value? {
        Dictionary(grouping: values) { $0 }
            .max { lhs, rhs in lhs.value.count < rhs.value.count }?
            .key
    }

    private func openEdit(for entry: TransactionModel) {
        guard let index = interactor.listTransactions.firstIndex(where: { $0.id == entry.id }) else {
            return
        }

        selectedTrade = index
        showEditTrade = true
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView(selectedTab: .constant(.today), addEntryRequest: UUID())
            .environmentObject(HomeInteractor(transactionListManager: TransactionListManager(), envelopeListManager: EnvelopeListManager()))
            .environmentObject(StoreKitPremiumManager())
    }
}
