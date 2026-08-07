import SwiftUI

struct EnvelopeDetailSheet: View {
    @EnvironmentObject var interactor: HomeInteractor
    @Binding var envelopeId: String?
    
    @State private var selectedPeriod: EntryPeriodSelection = .month
    @State private var selectedDate: Date = Date()
    @State private var showEditEnvelope = false
    @State private var showEditTrade = false
    @State private var selectedTrade = 0
    
    enum EntryPeriodSelection: String, CaseIterable {
        case day = "Day"
        case month = "Month"
        case allTime = "All Time"
    }
    
    var currentEnvelopeIndex: Int? {
        guard let envelopeId = envelopeId else { return nil }
        return interactor.listEnvelopes.firstIndex(where: { $0.id == envelopeId })
    }
    
    var period: EntryPeriod {
        switch selectedPeriod {
        case .day: return .day(selectedDate)
        case .month: return .month(selectedDate)
        case .allTime: return .allTime
        }
    }
    
    var spent: Decimal {
        guard let id = envelopeId else { return 0 }
        return interactor.spent(forEnvelopeId: id, period: period)
    }
    
    var entries: [TransactionModel] {
        guard let id = envelopeId else { return [] }
        return interactor.entries(forEnvelopeId: id, period: period)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("lightGrayKeepi")
                    .ignoresSafeArea()
                
                if let index = currentEnvelopeIndex {
                    let envelope = interactor.listEnvelopes[index]
                    VStack(spacing: 16) {
                        // Header info
                        VStack(spacing: 8) {
                            HStack {
                                Image(envelope.icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 32, height: 32)
                                Text(envelope.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            .padding(.top, 16)
                            
                            Text(KeepiFormat.currency(spent))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color("blackKeepi"))
                            
                            if let budget = envelope.monthlyBudget, budget > 0 {
                                let doubleSpent = Double(truncating: spent as NSNumber)
                                let doubleBudget = Double(truncating: budget as NSNumber)
                                let percent = Int((doubleSpent / doubleBudget) * 100)
                                Text("Budget: \(KeepiFormat.currency(budget)) · \(percent)% used")
                                    .font(.subheadline)
                                    .foregroundColor(percent > 100 ? Color("red") : Color(UIColor.gray))
                            }
                        }
                        
                        // Picker
                        Picker("Period", selection: $selectedPeriod) {
                            ForEach(EntryPeriodSelection.allCases, id: \.self) { p in
                                Text(p.rawValue).tag(p)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 16)
                        
                        if selectedPeriod != .allTime {
                            DatePicker(
                                selectedPeriod == .day ? "Select Day" : "Select Month",
                                selection: $selectedDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            .padding(.horizontal, 16)
                        }
                        
                        HStack {
                            Text("\(entries.count) \(entries.count == 1 ? "entry" : "entries")")
                                .font(.subheadline)
                                .foregroundColor(Color(UIColor.gray))
                                .padding(.horizontal, 16)
                            Spacer()
                        }
                        
                        // Entries List
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 12) {
                                ForEach(entries) { entry in
                                    Button {
                                        openEdit(for: entry)
                                    } label: {
                                        TransactionCardComponent(
                                            date: entry.date,
                                            name: entry.name,
                                            value: entry.value,
                                            envelopeName: envelope.name,
                                            feeling: entry.feeling,
                                            journalEntry: entry.journalEntry
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                        }
                    }
                } else {
                    Text("Envelope not found")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showEditEnvelope = true
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        envelopeId = nil
                    }
                }
            }
            .sheet(isPresented: $showEditEnvelope) {
                if let index = currentEnvelopeIndex {
                    EditEnvelopeView(envelopeListManager: interactor.envelopeListManager, selectedEnvelopeIndex: index, showNewEnvelope: $showEditEnvelope)
                        .environmentObject(interactor)
                        .presentationDetents([.fraction(0.9)])
                        .interactiveDismissDisabled()
                }
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
        }
    }
    
    private func openEdit(for entry: TransactionModel) {
        guard let index = interactor.listTransactions.firstIndex(where: { $0.id == entry.id }) else { return }
        selectedTrade = index
        showEditTrade = true
    }
}
