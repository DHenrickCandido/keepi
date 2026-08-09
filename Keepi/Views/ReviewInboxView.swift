import SwiftUI

struct ReviewInboxView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var draftManager = DraftManager.shared
    @ObservedObject var interactor: HomeInteractor
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("lightGrayKeepi").ignoresSafeArea()
                
                if let currentDraft = draftManager.drafts.first {
                    ReviewCardView(draft: currentDraft, interactor: interactor) { action in
                        switch action {
                        case .save(let finalizedModel):
                            interactor.addTransaction(transaction: finalizedModel)
                            withAnimation {
                                draftManager.removeDraft(id: currentDraft.id)
                            }
                        case .skip:
                            withAnimation {
                                draftManager.removeDraft(id: currentDraft.id)
                            }
                        }
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    .id(currentDraft.id)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(Color("lightGreenKeepi"))
                        Text("You're all caught up.")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Button("Done") {
                            dismiss()
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(Color("darkGreenKeepi"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
            }
            .navigationTitle("\(draftManager.drafts.count) pending")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

enum ReviewAction {
    case save(TransactionModel)
    case skip
}

struct ReviewCardView: View {
    let draft: ImportedEntryDraft
    let interactor: HomeInteractor
    let onComplete: (ReviewAction) -> Void
    
    @State private var title: String
    @State private var selectedEnvelopeId: String
    @State private var feeling: Int
    @State private var intent: SpendingIntent?
    @State private var note: String
    
    private let smartMatchId: String?
    private let smartMatchReason: String?
    
    init(draft: ImportedEntryDraft, interactor: HomeInteractor, onComplete: @escaping (ReviewAction) -> Void) {
        self.draft = draft
        self.interactor = interactor
        self.onComplete = onComplete
        
        let matchResult = SmartMatcher.suggestEnvelope(
            for: draft,
            history: interactor.listTransactions,
            merchantRules: interactor.merchantRules,
            categoryMappings: interactor.categoryMappings
        )
        self.smartMatchId = matchResult?.envelopeID
        self.smartMatchReason = matchResult?.reason
        
        _title = State(initialValue: draft.originalTitle)
        _selectedEnvelopeId = State(initialValue: draft.suggestedEnvelopeID ?? matchResult?.envelopeID ?? (interactor.listEnvelopes.first?.id ?? ""))
        _feeling = State(initialValue: 0)
        _intent = State(initialValue: draft.spendingIntent)
        _note = State(initialValue: draft.description ?? "")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    TextField("Title", text: $title)
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                    
                    Text(KeepiFormat.currency(draft.amount))
                        .font(.title2)
                        .foregroundColor(draft.amount < 0 ? .red : .green)
                    
                    Text(draft.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 16)
                
                // Envelope
                VStack(alignment: .leading, spacing: 12) {
                    if let smartMatchId = smartMatchId, draft.suggestedEnvelopeID == nil, selectedEnvelopeId == smartMatchId {
                        Text("Suggested:")
                            .font(.headline)
                        if let reason = smartMatchReason {
                            Text(reason)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    } else {
                        Text("Envelope")
                            .font(.headline)
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
                        .cornerRadius(8)
                    }
                    .foregroundColor(.primary)
                }
                
                // Feeling
                VStack(alignment: .leading, spacing: 12) {
                    Text("How did this purchase feel?")
                        .font(.headline)
                    
                    HStack {
                        feelingButton(title: "🙂 Good", value: 0)
                        feelingButton(title: "😐 Neutral", value: 2)
                        feelingButton(title: "😕 Regret", value: 3)
                    }
                }
                
                // Intent
                VStack(alignment: .leading, spacing: 12) {
                    Text("Was this purchase planned?")
                        .font(.headline)
                    
                    HStack {
                        intentButton(title: "Planned", value: .planned)
                        intentButton(title: "Impulsive", value: .impulsive)
                        intentButton(title: "Not sure", value: .unsure)
                    }
                }
                
                // Note
                VStack(alignment: .leading, spacing: 12) {
                    Text("Note (optional)")
                        .font(.headline)
                    
                    TextField("Add a note...", text: $note)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                }
                
                Spacer(minLength: 16)
                
                // Actions
                HStack(spacing: 16) {
                    Button(action: {
                        onComplete(.skip)
                    }) {
                        Text("Skip")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        let isExpense = draft.amount < 0
                        let transaction = TransactionModel(
                            id: TradeIdentity.make(),
                            name: title,
                            value: isExpense ? draft.amount * -1 : draft.amount,
                            envelopeId: selectedEnvelopeId,
                            feeling: feeling,
                            date: draft.date,
                            type: isExpense ? .expense : .income,
                            note: note,
                            importMetadata: ImportMetadata(
                                sourceType: "csv",
                                sourceFingerprint: draft.sourceFingerprint,
                                originalTitle: draft.originalTitle,
                                importedAt: Date()
                            )
                        )
                        
                        // Create/Update Merchant Rule
                        let normalizedTitle = MerchantNormalizer.normalize(draft.originalTitle)
                        if let existingRule = interactor.merchantRules.first(where: { $0.pattern == normalizedTitle && $0.matchType == .normalizedExact }) {
                            var updatedRule = existingRule
                            updatedRule.envelopeID = selectedEnvelopeId
                            updatedRule.useCount += 1
                            updatedRule.lastUsedAt = Date()
                            interactor.rulesListManager.saveRule(updatedRule)
                        } else {
                            let newRule = MerchantEnvelopeRule(
                                id: UUID().uuidString,
                                pattern: normalizedTitle,
                                matchType: .normalizedExact,
                                envelopeID: selectedEnvelopeId,
                                useCount: 1,
                                lastUsedAt: Date()
                            )
                            interactor.rulesListManager.saveRule(newRule)
                        }
                        
                        // Create Category Mapping if there was an original category
                        if let category = draft.originalCategory {
                            if !interactor.categoryMappings.contains(where: { $0.sourceCategory == category }) {
                                let mapping = ExternalCategoryMapping(sourceCategory: category, envelopeID: selectedEnvelopeId)
                                interactor.rulesListManager.saveMapping(mapping)
                            }
                        }
                        
                        transaction.spendingIntent = intent
                        if feeling == 0 { transaction.worthIt = true }
                        if feeling == 3 { transaction.worthIt = false }
                        
                        onComplete(.save(transaction))
                    }) {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("darkGreenKeepi"))
                            .cornerRadius(12)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(24)
            .padding()
            .shadow(color: Color.black.opacity(0.08), radius: 10, y: 4)
        }
    }
    
    @ViewBuilder
    private func feelingButton(title: String, value: Int) -> some View {
        Button(action: { feeling = value }) {
            Text(title)
                .font(.subheadline)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(feeling == value ? Color("lightGreenKeepi").opacity(0.2) : Color(UIColor.systemGray6))
                .foregroundColor(feeling == value ? Color("darkGreenKeepi") : .primary)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(feeling == value ? Color("lightGreenKeepi") : Color.clear, lineWidth: 2)
                )
        }
    }
    
    @ViewBuilder
    private func intentButton(title: String, value: SpendingIntent) -> some View {
        Button(action: { intent = value }) {
            Text(title)
                .font(.subheadline)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(intent == value ? Color("lightGreenKeepi").opacity(0.2) : Color(UIColor.systemGray6))
                .foregroundColor(intent == value ? Color("darkGreenKeepi") : .primary)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(intent == value ? Color("lightGreenKeepi") : Color.clear, lineWidth: 2)
                )
        }
    }
}
