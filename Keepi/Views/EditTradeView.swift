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
    
    @State var selectedEnvelope = ""
    var envelopes: [Keepi.EnvelopeModel] = []
    var envelopeNames: [String] = []
    


    init(showEditTrade: Binding<Bool>, tradeListManager: TradeListManager, envelopeListManager: EnvelopeListManager, index: Int, trade: Binding<TradeModel>){
        self._showEditTrade = showEditTrade
        self.tradeListManager = tradeListManager
        self.envelopeListManager = envelopeListManager
        self._trade = trade
        self.index = index
        
//        self.value = "\(trade.value)"

        self.value = "\(trade.value)"
        print(self.value)
        
        self.envelopes = envelopeListManager.listaEnvelope
        for envelope in self.envelopes {
            self.envelopeNames.append(envelope.name) // Assuming "name" is the property holding the envelope name
        }
        
        if !self.envelopes.isEmpty {
            self.selectedEnvelope = self.envelopeNames[0]
        } else {
            envelopeNames = ["Any envelope"]
        }
    }
    
    var body: some View {
        ScrollView{
            VStack(spacing:10){
                
                ZStack(){
                    
                    VStack(alignment: .center, spacing: 0) {
                        Text("Edit Trade")
                            .font(.title2)
                            .bold()

                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 15)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .bold()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 15)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .onTapGesture {
                        showEditTrade.toggle()
                    }
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        Text("Delete")
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 15)
                    .frame(maxWidth: .infinity, alignment: .topTrailing)
                    .onTapGesture {
                        tradeListManager.removeTrade(indexItem: index)
                        showEditTrade.toggle()
                    }
                    
                }
                
                
                
                VStack(spacing: 32){
                    
                    
                    // Qual sua Troca + TextField
                    VStack (alignment: .leading) {
                        Text("What's your new trade?")
                            .font(.headline)
                            .bold()
                        
                        TradeField(textPlacer: "Ex. Food, Clothes, Transport", item: $tradeTitle, keyboardType: .default)
                        
                    }
                    
                    // Envelope + Qual valor
                    HStack(){
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Envelope")
                                .font(.headline)
                                .bold()
                            HStack(alignment: .center){
                                Picker("Select", selection: $selectedEnvelope) {
                                    ForEach(envelopeNames, id: \.self) {
                                        Text("\($0)                      ")
                                    }
                                }
                                .pickerStyle(.menu)
                                .accentColor(.black)
                
                                
                                
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .cornerRadius(54)
                            .overlay(
                                RoundedRectangle(cornerRadius: 54)
                                .inset(by: 0.5)
                                .stroke(Color(red: 0.56, green: 0.56, blue: 0.58), lineWidth: 1)
                            )
                        }
                        .padding(0)
                        .frame(width: 171, alignment: .topLeading)
                        
                        Spacer()
                        VStack(alignment: .leading, spacing:16){
                            
                            QuestionText(text: "What's the value?")
                            TradeField(textPlacer: "Ex.25.00", item: $value, keyboardType: .default)
                                
                            
                        }
                    }
                    
                    // Divider
                    Divider()
                    
                    // Feelings section
                    VStack(alignment: .leading, spacing:24){
                        QuestionText(text: "How you felt with the trade?")
                        HStack{
                            ForEach(FeelingList.getFeelings(), id:\.self) { feeling in

                                let isActive = (feeling.index == selectedFeeling)
                                EmotionOption(active: isActive, feeling: feeling)
                                    .onTapGesture {
                                        selectedFeeling = feeling.index
                                    }

                                if feeling.index != 4 {
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 24){
                        QuestionText(text: "What was your main motivation?")
                        TagCloudView(selectedTags: $selectedTags)
            
                    }
                }
                .padding(10)
                
                AddTradeButton()
                    .onTapGesture {
                        showEditTrade.toggle()
                        print(tradeTitle)
                        print(value)
                        print(selectedFeeling)
                        print(selectedTags)
                        print(selectedEnvelope)
                    }
                
            }
            .padding(10)
            .onAppear{
                print("TESTE \(trade.name)")
                self.value = String(format: "%.2f", trade.value)
                self.tradeTitle = "\(trade.name)"
                self.selectedEnvelope = "\(trade.envelopeId)"
                self.selectedTags = trade.tag
                self.selectedFeeling = trade.feeling
            }
        }
    }

    
    func QuestionText(text: String) -> some View {
        Text(text)
            .font(.headline)
            .bold()
    }
    
    func getEnvelopeId() -> String {
        for envelope in envelopes {
            if  selectedEnvelope == envelope.name{
                return envelope.id
            }
        }
        
        return "0"
    }
    
    
    func saveTrade(){
        func date2string(date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmmss"
            let dateString = dateFormatter.string(from: date)
            
            return dateString
        }
        
        let valueFloat = Float(value)
        let id = tradeListManager.lista[index].id
        let date = tradeListManager.lista[index].date
        let envelopeId = getEnvelopeId()
        
        let compra = TradeModel(id: id, name: tradeTitle, value: valueFloat ?? 0, tag: selectedTags, envelopeId: selectedEnvelope, feeling: selectedFeeling, date: date)
        print("teste")
        print(compra.name)
        tradeListManager.updateTrade(trade: compra)

        tradeListManager.fetchTrades()
        
        // Fechar a modal
        showEditTrade.toggle()
    }
    
    func AddTradeButton() -> some View {
        HStack(alignment: .top, spacing: 10) {
            QuestionText(text: "Save Trade")
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(red: 0.9, green: 0.9, blue: 0.92))
        .cornerRadius(100)
        .onTapGesture {
            saveTrade()
        }
    }
    
    func EmotionOption(active: Bool, feeling: Feeling) -> some View {
        
        Image(feeling.icon)
            .resizable()
            .foregroundColor(.clear)
            .frame(width: 40, height: 40)
            .opacity(active ? 1 : 0.5)
            .cornerRadius(100)
            
    }
    
    func Divider() -> some View {
        VStack(){}
        .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
        .background(Color(red: 0.56, green: 0.56, blue: 0.58))
    }
    
    func TradeField(textPlacer: String, item: Binding<String>, keyboardType: UIKeyboardType) -> some View {
        HStack(alignment: .top, spacing: 10) {
            TextField(textPlacer, text: item)
                .keyboardType(keyboardType)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .cornerRadius(54)
        .overlay(
            RoundedRectangle(cornerRadius: 54)
                .inset(by: 0.5)
                .stroke(Color(red: 0.56, green: 0.56, blue: 0.58), lineWidth: 1)
        )
    }
    
}
