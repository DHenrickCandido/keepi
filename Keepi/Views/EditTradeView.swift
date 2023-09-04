//
//  ExampleEdit.swift
//  Keepi
//
//  Created by Andrea Oquendo on 01/09/23.
//

import SwiftUI

struct ExampleEdit: View {
    @State private var showEditTrade: Bool = false
    @State var compra = TradeModel(id: "34", name: "Hey", value: 23, tag: Tags.getTags())
    
    var body: some View {
        Button("click me") {
            showEditTrade.toggle()
        }
        .sheet(isPresented: $showEditTrade){
            
            EditTradeView(showEditTrade: $showEditTrade, trade: $compra)
                .presentationDetents([.fraction(0.9)])
                .interactiveDismissDisabled()
                
        }
        .onAppear{
            showEditTrade = true
        }
    }
}

struct ExampleEdit_Previews: PreviewProvider {
    static var previews: some View {
        ExampleEdit()
    }
}

struct EditTradeView: View {
    
    @Binding var showEditTrade: Bool // toggle for Modal
    @Binding var trade: TradeModel
    
    var tagManager: Tags = Tags()
    
    
    // Elements of the trade
    @State var tradeTitle: String = ""
    @State var value: String = ""
    @State var emotion: Feeling = FeelingList.getFeelings()[2]
    @State var selectedTags: [Tag] = []
    
//    @State var feeling: Feeling = ""
    
    @State private var selectedEnvelope = "iFood"
    let envelopes = ["iFood", "Social Life", "Others"]
    

    
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
                        /*
                        TO-DO: Colocar o código de deletar
                        */
                    }
                    
                }
                
                
                
                VStack(spacing: 32){
                    
                    
                    // Qual sua Troca + TextField
                    VStack (alignment: .leading) {
                        Text("What's your new trade?")
                            .font(.headline)
                            .bold()
                        
                        TradeField(textPlacer: "Ex. Comidas, Roupas, Transporte", item: $trade.name, keyboardType: .default)
                        
                    }
                    
                    // Envelope + Qual valor
                    HStack(){
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Envelope")
                                .font(.headline)
                                .bold()
                            HStack(alignment: .center){
                                Picker("Select", selection: $selectedEnvelope) {
                                    ForEach(envelopes, id: \.self) {
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
//                            ForEach(FeelingList.getFeelings()) { feeling in
//
//                                let isActive = true
//                                EmotionOption(active: isActive, feeling: feeling)
//                                    .onTapGesture {
//                                        emotion = feeling
//                                    }
//
//                                if index != 4 {
//                                    Spacer()
//                                }
//                            }
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
//                        print(emotion)
                        print(selectedTags)
                        print(selectedEnvelope)
                    }
                
            }
            .padding(10)
            .onAppear{
                print("hi")
            }
        }
    }

    
    func QuestionText(text: String) -> some View {
        Text(text)
            .font(.headline)
            .bold()
    }
    
    func AddTradeButton() -> some View {
        HStack(alignment: .top, spacing: 10) {
            QuestionText(text: "Salvar troca")
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(red: 0.9, green: 0.9, blue: 0.92))
        .cornerRadius(100)
    }
    
    func EmotionOption(active: Bool, feeling: Feeling) -> some View {
        
        Image(feeling.icon)
            .foregroundColor(.clear)
            .frame(width: 40, height: 40)
            .background(active ? .black : Color(red: 0.85, green: 0.85, blue: 0.85) )
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
