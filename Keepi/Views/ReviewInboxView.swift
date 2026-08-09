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
    
    init(draft: ImportedEntryDraft, interactor: HomeInteractor, onComplete: @escaping (ReviewAction) -> Void) {
        self.draft = draft
        self.interactor = interactor
        self.onComplete = onComplete
        
        _title = State(initialValue: draft.originalTitle)
        _selectedEnvelopeId = State(initialValue: draft.suggestedEnvelopeID ?? (interactor.listEnvelopes.first?.id ?? ""))
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
                    Text("Envelope")
                        .font(.headline)
                    
                    Picker("Envelope", selection: $selectedEnvelopeId) {
                        ForEach(interactor.listEnvelopes) { env in
                            Text(env.name).tag(env.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
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
                        intentButton(title: "Planned", value: .needs)
                        intentButton(title: "Impulsive", value: .unplanned)
                        intentButton(title: "Not sure", value: .wants)
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
                            sourceFingerprint: draft.sourceFingerprint
                        )
                        
                        if intent == .needs || intent == .wants { transaction.isPlanned = true }
                        if intent == .unplanned { transaction.isPlanned = false }
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
