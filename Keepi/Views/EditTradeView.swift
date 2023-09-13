//
//  ExampleEdit.swift
//  Keepi
//
//  Created by Andrea Oquendo on 01/09/23.
//

import SwiftUI

struct ExampleEdit: View {
    @State private var showEditTrade: Bool = false
    @ObservedObject var tradeListManager: TradeListManager

    @State var compra = TradeModel(id: "34", name: "Hey", value: 23, tag: Tags.getTags())
    
    var body: some View {
        Button("click me") {
            showEditTrade.toggle()
        }
        .sheet(isPresented: $showEditTrade){
            
//            EditTradeView(showEditTrade: $showEditTrade, trade: $compra)
//                .presentationDetents([.fraction(0.9)])
//                .interactiveDismissDisabled()
                
        }
        .onAppear{
            showEditTrade = true
        }
    }
}

struct EditTradeView: View {
    
    @Binding var showEditTrade: Bool // toggle for Modal
    @ObservedObject var tradeListManager: TradeListManager
    @ObservedObject var envelopeListManager: EnvelopeListManager
    var index: Int
    @Binding var trade: TradeModel
    
    var tagManager: Tags = Tags()
    
    
    // Elements of the trade
    @State var tradeTitle: String = ""
    @State var value: String = ""
    @State var selectedFeeling: Int = 2
    @State var selectedTags: [Tag] = []
    @State var selectedEnvelope: EnvelopeModel!
    @State var stepsIndicator: steps = .firstStep
    @Binding var selectedIndex: Int

    init(showEditTrade: Binding<Bool>, tradeListManager: TradeListManager, envelopeListManager: EnvelopeListManager, index: Int, trade: Binding<TradeModel>, selectedIndex: Binding<Int>){
        self._showEditTrade = showEditTrade
        
        self.tradeListManager = tradeListManager
        self.envelopeListManager = envelopeListManager
        self._trade = trade
        self.index = index
        self._selectedIndex = selectedIndex
        
        self.tradeTitle = self.trade.name
        self.value = String(format: "%.2f", self.trade.value)
        self.selectedTags = self.trade.tag
        self.selectedFeeling = self.trade.feeling
        
        
        
        print("AAA - Called init \(index)")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 40){
            let _ = print("AAA - Evaluate \(index)")
            
            if(stepsIndicator == .firstStep){
                FirstStep()
                    
            } else if (stepsIndicator == .secondStep ) {
                SecondStep()
            }
        
        }
        .padding(16)
 
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
                        ForEach(Array(envelopeListManager.listaEnvelope.enumerated()), id: \.element.id) { index, item in
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
            self.value = String(format: "%.2f", self.trade.value)
            self.selectedTags = self.trade.tag
            self.selectedFeeling = self.trade.feeling
            
            for envelope in envelopeListManager.listaEnvelope {
                if envelope.id == trade.envelopeId {
                    selectedEnvelope = envelope
                }
            }
        }
        .onDisappear(){
            selectedIndex = 0
            print("AAA - called disappear")
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
            
            Spacer()
            
            AddTradeButton()
        }
    }
    
    func DeleteIcon() -> some View {
        Image(systemName: "trash")
            .font(.title)
            .foregroundColor(.red)
            .padding(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(lineWidth: 2)
                    .foregroundColor(.red)
                    .frame(width: 60, height: 54)
            
            )
            .onTapGesture {
                tradeListManager.removeTrade(indexItem: index)
                showEditTrade.toggle()
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
                
                Text("$ \(envelope.budget.formatted(.number.precision(.fractionLength(2))))")
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
            print("TO-DO")
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
        func date2string(date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmmss"
            let dateString = dateFormatter.string(from: date)
            
            return dateString
        }
        
        value = value.replacingOccurrences(of: ",", with: ".")
        
        let valueFloat = Float(value)
        let id = trade.id
        let date = trade.date
        let envelopeId = selectedEnvelope.id
        
        let compra = TradeModel(id: id, name: tradeTitle, value: valueFloat ?? 0, tag: selectedTags, envelopeId: envelopeId, feeling: selectedFeeling, date: date)
    
        tradeListManager.updateTrade(trade: compra)

        tradeListManager.fetchTrades()
        
        // Fechar a modal
        showEditTrade.toggle()
    }
    
    func AddTradeButton() -> some View {
        HStack{
            DeleteIcon()
            
            Spacer()
            
            Text("Save trade")
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 150, height: 54)
                .background(Color("darkGreenKeepi"))
                .cornerRadius(16)
                .onTapGesture {
                    saveTrade()
                }
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
