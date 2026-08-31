import SwiftUI

enum ReflectionItem: Identifiable, Equatable {
    case draft(ImportedEntryDraft)
    case transaction(TransactionModel)
    
    var id: String {
        switch self {
        case .draft(let draft): return draft.id.uuidString
        case .transaction(let transaction): return transaction.id
        }
    }
    
    static func == (lhs: ReflectionItem, rhs: ReflectionItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    var date: Date {
        switch self {
        case .draft(let draft): return draft.date
        case .transaction(let transaction): return transaction.date
        }
    }
}

struct ReflectView: View {
    @EnvironmentObject var interactor: HomeInteractor
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ObservedObject var draftManager = DraftManager.shared
    @EnvironmentObject var premiumManager: StoreKitPremiumManager

    @State private var selectedPendingIndex = 0
    
    // Form State
    @State private var draftTitle = ""
    @State private var selectedEnvelopeId = ""
    @State private var selectedFeeling = 2
    @State private var worthIt = true
    @State private var spendingIntent: SpendingIntent? = nil
    @State private var journalEntry = ""
    
    // Smart Match State
    @State private var smartMatchId: String?
    @State private var smartMatchReason: String?
    
    @State private var isSaving = false
    @State private var showSaveError = false
    @State private var saveErrorMessage = ""
    @State private var showPaywall = false

    private var pendingItems: [ReflectionItem] {
        let drafts = premiumManager.canUse(.reviewInbox)
            ? draftManager.drafts.map { ReflectionItem.draft($0) }
            : []
        let transactions = interactor.listTransactions
            .filter { !$0.reflectionCompleted }
            .sorted { $0.date > $1.date }
            .map { ReflectionItem.transaction($0) }
        return drafts + transactions
    }

    private var currentItem: ReflectionItem? {
        guard pendingItems.indices.contains(selectedPendingIndex) else {
            return pendingItems.first
        }
        return pendingItems[selectedPendingIndex]
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color("lightGrayKeepi")
                    .ignoresSafeArea()
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
                    if !premiumManager.canUse(.reviewInbox), !draftManager.drafts.isEmpty {
                        lockedImportsBanner
                    }
                    if let item = currentItem {
                        reflectionForm(for: item)
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                            .id(item.id)
                    } else {
                        emptyState
                    }
                }
                .padding(.horizontal, 12)
            }
            .navigationBarHidden(true)
            .onAppear {
                loadCurrentItem()
            }
            .onChange(of: selectedPendingIndex) { _ in
                loadCurrentItem()
            }
            .onChange(of: pendingItems.count) { _ in
                if selectedPendingIndex >= pendingItems.count {
                    selectedPendingIndex = max(pendingItems.count - 1, 0)
                }
                loadCurrentItem()
            }
            .alert("Couldn't save reflection", isPresented: $showSaveError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(saveErrorMessage)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var lockedImportsBanner: some View {
        Button {
            showPaywall = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .foregroundColor(Color("darkGreenKeepi"))
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(draftManager.drafts.count) imported entries waiting")
                        .font(.headline)
                        .foregroundColor(Color("blackKeepi"))
                    Text("Restore Premium to continue reviewing them.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }

    private func reflectionForm(for item: ReflectionItem) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            
            // Header / Title & Amount
            switch item {
            case .draft(let draft):
                draftHeader(draft: draft)
            case .transaction(let transaction):
                entrySummary(transaction)
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    feelingSection
                    plannedSection
                    if case .transaction = item {
                        worthItSection
                    }
                    journalSection
                }
                .padding(.bottom, 12)
            }

            HStack(spacing: 12) {
                secondaryButton(title: "Skip for now") {
                    withAnimation {
                        skipItem()
                    }
                }

                primaryButton(title: "Save") {
                    saveReflection(for: item)
                }
            }
        }
    }

    private func draftHeader(draft: ImportedEntryDraft) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Title", text: $draftTitle)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("blackKeepi"))
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    Text(KeepiFormat.currency(draft.amount < 0 ? -draft.amount : draft.amount))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("darkGreenKeepi"))
                }
                
                Text(TransactionListManager.date2string(date: draft.date, dateFormat: "dd MMM"))
                    .font(.footnote)
                    .foregroundColor(Color(.systemGray))
            }
            
            Divider()
            
            envelopeSection(draft: draft)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
    }

    private func entrySummary(_ entry: TransactionModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("blackKeepi"))

                    Text(interactor.getEnvelopeNameById(id: entry.envelopeId))
                        .font(.subheadline)
                        .foregroundColor(Color(.systemGray))
                }

                Spacer()

                Text(KeepiFormat.currency(entry.value))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("darkGreenKeepi"))
            }

            Text(TransactionListManager.date2string(date: entry.date, dateFormat: "dd MMM"))
                .font(.footnote)
                .foregroundColor(Color(.systemGray))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
    }
    
    private func envelopeSection(draft: ImportedEntryDraft) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let smartMatchId = smartMatchId, draft.suggestedEnvelopeID == nil, selectedEnvelopeId == smartMatchId {
                Text("Suggested:")
                    .font(.headline)
                    .fontWeight(.bold)
                if let reason = smartMatchReason {
                    Text(reason)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            } else {
                Text("Envelope")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            Menu {
                Picker("Envelope", selection: $selectedEnvelopeId) {
                    ForEach(interactor.listEnvelopes) { env in
                        Text(env.name).tag(env.id)
                    }
                }
            } label: {
                HStack {
                    if let envName = interactor.listEnvelopes.first(where: { $0.id == selectedEnvelopeId })?.name {
                        Text(envName)
                    } else {
                        Text("Select Envelope")
                    }
                    Spacer()
                    Text("Change")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
            }
            .foregroundColor(.primary)
        }
    }

    private var feelingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How did this purchase feel?")
                .font(.headline)
                .fontWeight(.bold)

            adaptiveChoiceLayout {
                feelingButton(title: "🙂 Good", value: 0)
                feelingButton(title: "😐 Neutral", value: 2)
                feelingButton(title: "😕 Regret", value: 3)
            }
        }
    }
    
    @ViewBuilder
    private func feelingButton(title: String, value: Int) -> some View {
        Button(action: { selectedFeeling = value }) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(selectedFeeling == value ? Color("lightGreenKeepi").opacity(0.2) : .white)
                .foregroundColor(selectedFeeling == value ? Color("darkGreenKeepi") : Color("darkGreenKeepi"))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selectedFeeling == value ? Color("lightGreenKeepi") : Color.clear, lineWidth: 2)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
        }
    }

    private var plannedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Was it planned?")
                .font(.headline)
                .fontWeight(.bold)

            adaptiveChoiceLayout {
                choiceButton(title: "Planned", isSelected: spendingIntent == .planned) {
                    spendingIntent = .planned
                }
                
                choiceButton(title: "Impulsive", isSelected: spendingIntent == .impulsive) {
                    spendingIntent = .impulsive
                }
                
                choiceButton(title: "Not sure", isSelected: spendingIntent == .unsure) {
                    spendingIntent = .unsure
                }
            }
        }
    }

    private var worthItSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Would you make this purchase again?")
                .font(.headline)
                .fontWeight(.bold)

            adaptiveChoiceLayout {
                choiceButton(title: "Yes", isSelected: worthIt) {
                    worthIt = true
                }

                choiceButton(title: "No", isSelected: !worthIt) {
                    worthIt = false
                }
            }
        }
    }

    private var journalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Note (optional)")
                .font(.headline)
                .fontWeight(.bold)

            TextField("What do you want to remember?", text: $journalEntry, axis: .vertical)
                .lineLimit(3...6)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .background(.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()

            Image("keepiTrocas")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 160)

            Text("No pending reflections")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color("blackKeepi"))

            Text("Entries you save for later will appear here.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(.systemGray))

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func choiceButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color("darkGreenKeepi") : .white)
                .foregroundColor(isSelected ? .white : Color("darkGreenKeepi"))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
        }
    }

    private func adaptiveChoiceLayout<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 12))
            : AnyLayout(HStackLayout(spacing: 12))
        return layout { content() }
    }

    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isSaving {
                    ProgressView()
                        .tint(.white)
                }
                Text(isSaving ? "Saving..." : title)
                    .font(.body)
                    .fontWeight(.bold)
            }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(Color("darkGreenKeepi"))
                .cornerRadius(16)
        }
        .disabled(isSaving)
    }

    private func secondaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(Color("darkGreenKeepi"))
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
        }
    }

    private func loadCurrentItem() {
        guard let item = currentItem else {
            selectedFeeling = 2
            worthIt = true
            spendingIntent = nil
            journalEntry = ""
            draftTitle = ""
            selectedEnvelopeId = interactor.listEnvelopes.first?.id ?? ""
            smartMatchId = nil
            smartMatchReason = nil
            return
        }

        switch item {
        case .draft(let draft):
            draftTitle = draft.originalTitle
            selectedFeeling = 2 // Neutral default
            worthIt = true
            spendingIntent = draft.spendingIntent
            journalEntry = draft.description ?? ""
            
            // Smart Match
            if premiumManager.canUse(.smartCategorization) {
                let matchResult = SmartMatcher.suggestEnvelope(
                    for: draft,
                    history: interactor.listTransactions,
                    merchantRules: interactor.merchantRules,
                    categoryMappings: interactor.categoryMappings
                )
                self.smartMatchId = matchResult?.envelopeID
                self.smartMatchReason = matchResult?.reason
            } else {
                self.smartMatchId = nil
                self.smartMatchReason = nil
            }
            selectedEnvelopeId = draft.suggestedEnvelopeID ?? self.smartMatchId ?? (interactor.listEnvelopes.first?.id ?? "")
            
        case .transaction(let entry):
            selectedFeeling = entry.feeling
            worthIt = entry.worthIt ?? true
            spendingIntent = entry.spendingIntent
            journalEntry = entry.journalEntry.isEmpty ? entry.note : entry.journalEntry
            draftTitle = entry.name
            selectedEnvelopeId = entry.envelopeId
            smartMatchId = nil
            smartMatchReason = nil
        }
    }

    private func saveReflection(for item: ReflectionItem) {
        guard !isSaving else { return }
        isSaving = true
        
        switch item {
        case .draft(let draft):
            guard !draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                isSaving = false
                saveErrorMessage = "Enter a title before saving."
                showSaveError = true
                return
            }
            let isExpense = draft.amount < 0
            let transaction = TransactionModel(
                id: TradeIdentity.make(),
                name: draftTitle,
                value: isExpense ? draft.amount * -1 : draft.amount,
                envelopeId: selectedEnvelopeId,
                feeling: selectedFeeling,
                date: draft.date,
                reflectionCompleted: true,
                worthIt: selectedFeeling == 0 ? true : (selectedFeeling == 3 ? false : true),
                spendingIntent: spendingIntent,
                type: isExpense ? .expense : .income,
                journalEntry: journalEntry.trimmingCharacters(in: .whitespacesAndNewlines),
                importMetadata: ImportMetadata(
                    sourceType: "csv",
                    sourceFingerprint: draft.sourceFingerprint,
                    originalTitle: draft.originalTitle,
                    importedAt: Date()
                )
            )
            
            interactor.addTransaction(transaction: transaction) { error in
                DispatchQueue.main.async {
                    if let error {
                        isSaving = false
                        saveErrorMessage = error.localizedDescription
                        showSaveError = true
                        return
                    }

                    saveLearnedCategorization(for: draft)
                    do {
                        try withAnimation {
                            try draftManager.removeDraft(id: draft.id)
                        }
                        isSaving = false
                    } catch {
                        isSaving = false
                        saveErrorMessage = "The entry was saved, but Keepi couldn't remove its local import draft. It will be ignored as a duplicate next time."
                        showSaveError = true
                    }
                }
            }
            
        case .transaction(let entry):
            let updatedEntry = TransactionModel(
                id: entry.id,
                name: entry.name,
                value: entry.value,
                envelopeId: entry.envelopeId,
                feeling: selectedFeeling,
                date: entry.date,
                reflectionCompleted: true,
                worthIt: worthIt,
                spendingIntent: spendingIntent,
                type: entry.type,
                note: entry.note,
                journalEntry: journalEntry.trimmingCharacters(in: .whitespacesAndNewlines),
                importMetadata: entry.importMetadata
            )

            interactor.updateTransaction(transaction: updatedEntry) { error in
                DispatchQueue.main.async {
                    isSaving = false
                    if let error {
                        saveErrorMessage = error.localizedDescription
                        showSaveError = true
                        return
                    }
                }
            }
        }
    }

    private func skipItem() {
        guard pendingItems.count > 1 else { return }
        selectedPendingIndex = (selectedPendingIndex + 1) % pendingItems.count
    }

    private func saveLearnedCategorization(for draft: ImportedEntryDraft) {
        guard !selectedEnvelopeId.isEmpty else { return }
        let normalizedTitle = MerchantNormalizer.normalize(draft.originalTitle)
        if let existingRule = interactor.merchantRules.first(where: { $0.pattern == normalizedTitle && $0.matchType == .normalizedExact }) {
            var updatedRule = existingRule
            updatedRule.envelopeID = selectedEnvelopeId
            updatedRule.useCount += 1
            updatedRule.lastUsedAt = Date()
            interactor.rulesListManager.saveRule(updatedRule)
        } else {
            interactor.rulesListManager.saveRule(MerchantEnvelopeRule(
                id: UUID().uuidString,
                pattern: normalizedTitle,
                matchType: .normalizedExact,
                envelopeID: selectedEnvelopeId,
                useCount: 1,
                lastUsedAt: Date()
            ))
        }

        if let category = draft.originalCategory?.trimmingCharacters(in: .whitespacesAndNewlines), !category.isEmpty {
            interactor.rulesListManager.saveMapping(
                ExternalCategoryMapping(sourceCategory: category, envelopeID: selectedEnvelopeId)
            )
        }
    }
}

struct ReflectView_Previews: PreviewProvider {
    static var previews: some View {
        ReflectView()
            .environmentObject(HomeInteractor(transactionListManager: TransactionListManager(), envelopeListManager: EnvelopeListManager()))
            .environmentObject(StoreKitPremiumManager())
    }
}

extension View {
    func roundedCorner(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
