//
//  EditTransactionView.swift
//  Keepi
//
//  Created by Andrea Oquendo on 01/09/23.
//

import SwiftUI

struct EditTransactionView: View {
    
    @Binding var showEditTransaction: Bool // toggle for Modal
    @EnvironmentObject var interactor: HomeInteractor
    var index: Int
    @Binding var transaction: TransactionModel
    
        
    
    @Binding var selectedIndex: Int
    @State var selectedEnvelope: Envelope!
    
    // Elements of the transaction
    @State var tradeTitle: String = ""
    @State var value: String = ""
    @State var selectedFeeling: Int = 2
    @State var transactionType: TransactionType = .expense
    @State var spendingIntent: SpendingIntent? = nil
    @State var todayDate: Date = Date()
    @State var stepsIndicator: steps = .firstStep
    @State var showAlert = false
    @State var alertMessage = ""
    @State var showNewEnvelope = false
    @State var showDeleteConfirmation = false
    @State var journalEntry = ""
    @State var isSaving = false
    init(showEditTransaction: Binding<Bool>, index: Int, trade: Binding<TransactionModel>, selectedIndex: Binding<Int>) {
        self._showEditTransaction = showEditTransaction
        
        self._transaction = trade
        self.index = index
        self._selectedIndex = selectedIndex
        
        self.tradeTitle = self.transaction.name
        self.value = KeepiFormat.editableAmount(self.transaction.value)
                self.selectedFeeling = self.transaction.feeling
        self.journalEntry = self.transaction.journalEntry
        
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 40) {
                if stepsIndicator == .firstStep {
                    FirstStep()
                } else if stepsIndicator == .secondStep {
                    SecondStep()
                }
            }
            .padding(16)
        }
        .scrollDismissesKeyboard(.interactively)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Entry incomplete"), message: Text(alertMessage), dismissButton: .default(Text("Got it!")))
        }
        .sheet(isPresented: $showNewEnvelope) {
            NewEnvelopeView(showNewEnvelope: $showNewEnvelope)
                .environmentObject(interactor)
                .presentationDetents([.fraction(0.9)])
                .interactiveDismissDisabled()
        }
        .confirmationDialog("Delete this entry?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete entry", role: .destructive) {
                deleteTransaction()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This cannot be undone, and its amount will be returned to the envelope.")
        }
 
    }

    func FirstStep() -> some View {
        Group{
            // Cabeçalho
            ZStack {

                HStack {
                    Button {
                        showEditTransaction = false
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.bold)
                    }
                    .accessibilityLabel("Close")

                    Spacer()

                    Text("Step 1 of 2")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                }

                Text("Edit entry")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("blackKeepi"))

            }
            
            // Transaction Type
            Picker("Type", selection: $transactionType) {
                Text("Expense").tag(TransactionType.expense)
                Text("Income").tag(TransactionType.income)
                Text("Transfer").tag(TransactionType.transfer)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom, 10)

            //inicio Qual envelope?
            VStack (alignment: .leading) {
                QuestionText(text: "Which envelope?")
                ScrollView (.horizontal) {
                    HStack {
                        NoEnvelopeCard()

                        ForEach(Array(interactor.listEnvelopes.enumerated()), id: \.element.id) { index, item in
                            EnvelopeCard(envelope: item)
                        }

                        AddEnvelopeButton()

                    }

                }.scrollIndicators(.hidden)


            }
            //Fim qual envelope?
        
            TradeField(
                question: "What's this entry?",
                textPlacer: "Ex. Tea, new shoes...",
                item: $tradeTitle,
                keyboardType: .default
            )
            
            TradeField(
                question: "What's the value?",
                textPlacer: "Ex.20,00",
                item: $value,
                keyboardType: .decimalPad
            )
            
            Spacer()
            
            NextButton()
        }
        .onAppear{
            self.tradeTitle = self.transaction.name
            self.value = KeepiFormat.editableAmount(self.transaction.value)
                        self.selectedFeeling = self.transaction.feeling
            self.journalEntry = self.transaction.journalEntry
            self.transactionType = self.transaction.type
            self.spendingIntent = self.transaction.spendingIntent
            
            selectedEnvelope = nil
            interactor.listEnvelopes.forEach({ envelope in
                if envelope.id == transaction.envelopeId {
                    selectedEnvelope = envelope
                }
            })
        }
    }
    
    func SecondStep() -> some View {
        Group{
            // Cabeçalho
            ZStack {
                
                HStack {
                    Button {
                        showEditTransaction = false
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.bold)
                    }
                    .accessibilityLabel("Close")
                    
                    Spacer()
                    
                    Text("Step 2 of 2")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                }
                
                Text("Edit entry")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("blackKeepi"))
                
            }
            
            // Planned?
            VStack (alignment: .leading) {
                Text("Was it planned?")
                    .font(.headline)
                    .fontWeight(.bold)
                
                HStack(spacing: 8) {
                    intentButton(title: "Planned", value: .planned)
                    intentButton(title: "Impulsive", value: .impulsive)
                    intentButton(title: "Not sure", value: .unsure)
                }
            }
            .padding(.bottom, 16)

            //Inicio como voce se sentiu?
            VStack (alignment: .leading) {
                Text("How did you feel?")
                    .font(.headline)
                .fontWeight(.bold)
                
                HStack {
                    ForEach(FeelingList.getFeelings(), id:\.self) { feeling in

                        EmotionOption(active: (feeling.index == selectedFeeling) , feeling: feeling)
                            .onTapGesture {
                                selectedFeeling = feeling.index
                            }

                        if feeling.index != 4 {
                            Spacer()
                        }
                    }
                }
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(Color("lightGrayKeepi"))
                .cornerRadius(16)
            }
            //Fim como voce se sentiu?
            VStack(alignment: .leading){
                QuestionText(text: "What's your main motivation?")
                TextField("Type your journal entry...", text: $journalEntry, axis: .vertical)
                    .lineLimit(3...6)
                    .font(.callout)
                    .foregroundColor(.black)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .background(Color("lightGrayKeepi"))
                    .cornerRadius(16)
            }
            
            Spacer()
            
            AddTransactionButton()
        }
    }
    
    func DeleteIcon() -> some View {
        Button {
            showDeleteConfirmation = true
        } label: {
            Image(systemName: "trash")
                .font(.title)
                .foregroundColor(.red)
                .frame(width: 60, height: 54)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.red)
                )
        }
        .disabled(isSaving)
    }

    private func deleteTransaction() {
        guard !isSaving else { return }
        isSaving = true
        interactor.removeTransaction(indexItem: index) { error in
            DispatchQueue.main.async {
                isSaving = false
                if let error {
                    alertMessage = error.localizedDescription
                    showAlert = true
                    return
                }
                showEditTransaction = false
            }
        }
    }
    
    func NoEnvelopeCard() -> some View {
        VStack {
            Image(systemName: "tray")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(12)
                .frame(width: 48, height: 48)
                .foregroundColor(Color("darkGreenKeepi"))
                .background(.white)
                .cornerRadius(8)
            
            VStack {
                Text("No envelope")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("blackKeepi"))
                
                Text("Attach later")
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.darkGray))
            }
        }
        .padding(8)
        .frame(width: 142)
        .frame(minHeight: 130)
        .background(Color("lightGrayKeepi"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
            .inset(by: 1)
            .stroke(selectedEnvelope == nil ? Color("lightGreenKeepi") : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            selectedEnvelope = nil
        }
    }

    func EnvelopeCard(envelope: Envelope) -> some View {
        VStack {
            Image(envelope.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(8)
                .frame(width: 48, height: 48)
                .background(.white)
                .cornerRadius(8)
            
            VStack {
                Text(envelope.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("blackKeepi"))
                
                Text(KeepiFormat.currency(interactor.spent(forEnvelopeId: envelope.id)))
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.darkGray))
                
                Text("this month")
                    .font(.caption2)
                    .foregroundColor(Color(UIColor.darkGray))
                    
                if let budget = envelope.monthlyBudget, budget > 0 {
                    Text("Budget \(KeepiFormat.currency(budget))")
                        .font(.caption2)
                        .foregroundColor(Color(UIColor.gray))
                }
            }
        }
        .padding(8)
        .frame(width: 142)
        .frame(minHeight: 130)
        .background(Color("lightGrayKeepi"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
            .inset(by: 1)
            .stroke(selectedEnvelope == envelope ? Color("lightGreenKeepi") : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            selectedEnvelope = envelope
        }
    }

    func AddEnvelopeButton() -> some View {
        VStack {
            Image(systemName: "plus.app.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(8)
                .frame(width: 48, height: 48)
                .foregroundColor(Color("darkGreenKeepi"))
                .cornerRadius(8)
            
            VStack {
                Text("Add\nenvelope")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("darkGreenKeepi"))
                
            }
        }
        .padding(8)
        .frame(width: 142)
        .frame(minHeight: 130)
        .background(Color("lightGrayKeepi"))
        .cornerRadius(16)
        .onTapGesture {
            showNewEnvelope = true
        }
    }
    
    func NextButton() -> some View {
        HStack {
            
            DeleteIcon()
            
            Spacer()
            
            Text("Continue")
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 150, height: 54)
                .background(Color("darkGreenKeepi"))
                .cornerRadius(16)
                .onTapGesture {
                    guard CRUDValidation.normalizedDecimal(value) != nil,
                          CRUDValidation.envelopeId(from: tradeTitle) != nil else {
                        alertMessage = "Enter a valid title and amount before continuing."
                        showAlert = true
                        return
                    }

                    stepsIndicator = .secondStep
                }
            
            
        }
    }
    func QuestionText(text: String) -> some View {
        Text(text)
            .font(.headline)
            .bold()
    }
    
    
    func saveTransaction(){
        guard !isSaving else { return }
        func date2string(date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmmss"
            let dateString = dateFormatter.string(from: date)
            
            return dateString
        }
        
        guard let valueFloat = CRUDValidation.normalizedDecimal(value),
              CRUDValidation.envelopeId(from: tradeTitle) != nil else {
            alertMessage = "Enter a valid title and amount before saving."
            showAlert = true
            return
        }

        let id = transaction.id
        let date = transaction.date
        let envelopeId = selectedEnvelope?.id ?? ""

        let compra = TransactionModel(
            id: id,
            name: tradeTitle,
            value: valueFloat,
            envelopeId: envelopeId,
            feeling: selectedFeeling,
            date: date,
            reflectionCompleted: transaction.reflectionCompleted,
            worthIt: transaction.worthIt,
            spendingIntent: spendingIntent,
            type: transactionType,
            note: transaction.note,
            journalEntry: journalEntry.trimmingCharacters(in: .whitespacesAndNewlines),
            importMetadata: transaction.importMetadata
        )
        
        isSaving = true
        interactor.updateTransaction(transaction: compra) { error in
            DispatchQueue.main.async {
                isSaving = false
                if let error {
                    alertMessage = error.localizedDescription
                    showAlert = true
                    return
                }
                showEditTransaction = false
            }
        }
    }
    
    func AddTransactionButton() -> some View {
        HStack{
            DeleteIcon()
            
            Spacer()
            
            Button(action: saveTransaction) {
                HStack(spacing: 8) {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(isSaving ? "Saving..." : "Save entry")
                        .font(.body)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(width: 150, height: 54)
                .background(Color("darkGreenKeepi"))
                .cornerRadius(16)
            }
            .disabled(isSaving)
        }
        
    }
    
    func EmotionOption(active: Bool, feeling: Feeling) -> some View {
            
        Image(feeling.icon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 50, height: 50)
            .saturation(active ? 1 : 0)
            .opacity(active ? 1 : 0.5)
        
    }
    
    func Divider() -> some View {
        VStack(){}
        .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
        .background(Color(red: 0.56, green: 0.56, blue: 0.58))
    }
    
    func converter(textInput: String) -> String {
        let textDouble = Double(textInput.replacingOccurrences(of: ",", with: ".")) ?? 0
        // If the Textfield is empty, 0 will be returned
        return String(format: "%.2f", textDouble)
    }
    
    func TradeField(question: String, textPlacer: String, item: Binding<String>, keyboardType: UIKeyboardType) -> some View {
        
        VStack (alignment: .leading) {
            Text(question)
                .font(.headline)
                .bold()
            
            HStack(alignment: .top, spacing: 10) {
                TextField(textPlacer, text: item)
                    .keyboardType(keyboardType)
                    .font(.callout)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(Color("lightGrayKeepi"))
                    .cornerRadius(16)
//                    .onChange(of: item.wrappedValue){
//                        item.wrappedValue = converter(textInput: <#T##String#>)
//                    }
                
            }
            
            
        }
        
        
        
    }
    
    @ViewBuilder
    private func intentButton(title: String, value: SpendingIntent) -> some View {
        Button(action: { spendingIntent = value }) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(spendingIntent == value ? Color("darkGreenKeepi") : Color.white)
                .foregroundColor(spendingIntent == value ? .white : Color("darkGreenKeepi"))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
        }
    }
}
