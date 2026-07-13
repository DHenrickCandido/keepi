import SwiftUI

struct TodayView: View {
    @EnvironmentObject var interactor: HomeInteractor

    @State private var showNewTrade = false
    @State private var showEditTrade = false
    @State private var selectedTrade = 0

    private var todayEntries: [TradeModel] {
        interactor.listTrades
            .filter { Calendar.current.isDateInToday($0.date) }
            .sorted { $0.date > $1.date }
    }

    private var totalSpentToday: Float {
        todayEntries.reduce(0) { $0 + $1.value }
    }


    private var morningEntries: [TradeModel] {
        entries(for: 5..<12)
    }

    private var afternoonEntries: [TradeModel] {
        entries(for: 12..<18)
    }

    private var eveningEntries: [TradeModel] {
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
                NewTradeView(showNewTrade: $showNewTrade, interactor: interactor)
                    .presentationDetents([.fraction(0.9)])
                    .interactiveDismissDisabled()
            }
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

    private var todaySummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(Color(.gray))

                    Text(TradeListManager.date2string(date: Date(), dateFormat: "dd MMM"))
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

            Text("Add one now, then decide whether to reflect right away or later.")
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
    private func timelineSection(title: String, entries: [TradeModel]) -> some View {
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
                        TradeCardComponent(
                            date: entry.date,
                            name: entry.name,
                            value: entry.value,
                            selectedTags: entry.tag,
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

    private func entries(for range: Range<Int>) -> [TradeModel] {
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

    private func openEdit(for entry: TradeModel) {
        guard let index = interactor.listTrades.firstIndex(where: { $0.id == entry.id }) else {
            return
        }

        selectedTrade = index
        showEditTrade = true
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
            .environmentObject(HomeInteractor(tradeListManager: TradeListManager(), envelopeListManager: EnvelopeListManager()))
    }
}
