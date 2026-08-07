//
//  EditTradeView.swift
//  Keepi
//
//  Created by Andrea Oquendo on 01/09/23.
//

import SwiftUI

struct EditTradeView: View {
    
    @Binding var showEditTrade: Bool // toggle for Modal
    @EnvironmentObject var interactor: HomeInteractor
    var index: Int
    @Binding var trade: TradeModel
    
    var tagManager: Tags = Tags()
    
    
    // Elements of the trade
    @State var tradeTitle: String = ""
    @State var value: String = ""
    @State var selectedFeeling: Int = 2
    @State var selectedTags: [Tag] = []
    @State var selectedEnvelope: EnvelopeModel!
    @State var journalEntry: String = ""
    @State var stepsIndicator: steps = .firstStep
    @State private var showAlert = false
    @State private var showNewEnvelope = false
    @State private var alertMessage = "Enter a valid title and amount before continuing."
    @State private var isSaving = false
    @State private var showDeleteConfirmation = false
    @Binding var selectedIndex: Int

    init(showEditTrade: Binding<Bool>, index: Int, trade: Binding<TradeModel>, selectedIndex: Binding<Int>){
        self._showEditTrade = showEditTrade
        
        self._trade = trade
        self.index = index
        self._selectedIndex = selectedIndex
        
        self.tradeTitle = self.trade.name
        self.value = KeepiFormat.editableAmount(self.trade.value)
        self.selectedTags = self.trade.tag
        self.selectedFeeling = self.trade.feeling
        self.journalEntry = self.trade.journalEntry
        
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
                deleteTrade()
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
                    Image(systemName: "xmark")
                        .fontWeight(.bold)
                        .onTapGesture {
                            
                            showEditTrade.toggle()
                        }

                    Spacer()

                    Text("Step 1 of 2")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                }

                Text("Edit trade")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("blackKeepi"))

            }
            
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
                question: "What's your new trade?",
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
            self.tradeTitle = self.trade.name
            self.value = KeepiFormat.editableAmount(self.trade.value)
            self.selectedTags = self.trade.tag
            self.selectedFeeling = self.trade.feeling
            self.journalEntry = self.trade.journalEntry
            
            selectedEnvelope = nil
            interactor.listEnvelopes.forEach({ envelope in
                if envelope.id == trade.envelopeId {
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
                    Image(systemName: "xmark")
                        .fontWeight(.bold)
                        .onTapGesture {
                            showEditTrade.toggle()
                        }
                    
                    Spacer()
                    
                    Text("Step 2 of 2")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                }
                
                Text("New trade")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("blackKeepi"))
                
            }
            
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
                TagCloudView(selectedTags: $selectedTags)
            }

            VStack(alignment: .leading) {
                QuestionText(text: "Journal")
                TextField("What do you want to remember about this purchase?", text: $journalEntry, axis: .vertical)
                    .lineLimit(3...6)
                    .font(.callout)
                    .foregroundColor(.black)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .background(Color("lightGrayKeepi"))
                    .cornerRadius(16)
            }
            
            Spacer()
            
            AddTradeButton()
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

    private func deleteTrade() {
        guard !isSaving else { return }
        isSaving = true
        interactor.removeTrade(indexItem: index) { error in
            DispatchQueue.main.async {
                isSaving = false
                if let error {
                    alertMessage = error.localizedDescription
                    showAlert = true
                    return
                }
                showEditTrade = false
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
        .frame(width: 142, height: 119)
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

    func EnvelopeCard(envelope: EnvelopeModel) -> some View {
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
                
                Text(KeepiFormat.currency(envelope.budget))
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.darkGray))
            }
        }
        .padding(8)
        .frame(width: 142, height: 119)
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
        .frame(width: 142, height: 119)
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
    
    
    func saveTrade(){
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

        let id = trade.id
        let date = trade.date
        let envelopeId = selectedEnvelope?.id ?? ""

        let compra = TradeModel(
            id: id,
            name: tradeTitle,
            value: valueFloat,
            tag: selectedTags,
            envelopeId: envelopeId,
            feeling: selectedFeeling,
            date: date,
            reflectionCompleted: trade.reflectionCompleted,
            worthIt: trade.worthIt,
            note: trade.note,
            journalEntry: journalEntry.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        isSaving = true
        interactor.updateTrade(trade: compra) { error in
            DispatchQueue.main.async {
                isSaving = false
                if let error {
                    alertMessage = error.localizedDescription
                    showAlert = true
                    return
                }
                showEditTrade = false
            }
        }
    }
    
    func AddTradeButton() -> some View {
        HStack{
            DeleteIcon()
            
            Spacer()
            
            Button(action: saveTrade) {
                HStack(spacing: 8) {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(isSaving ? "Saving..." : "Save trade")
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
    
}
