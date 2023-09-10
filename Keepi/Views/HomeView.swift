//
//  HomeView.swift
//  Keepi
//
//  Created by Diego Henrick on 30/08/23.
//

import SwiftUI

struct HomeView: View {
    @StateObject var tradeModel: TradeModel
    @EnvironmentObject var tradeListManager: TradeListManager
    @EnvironmentObject var envelopeListManager: EnvelopeListManager
    
    @State private var showNewTrade: Bool = false
    @State private var showEditTrade: Bool = false
    @State var selectedTrade: Int = 0
    
    @State private var showNewEnvelope: Bool = false
    @State private var selectedEnvelope: Int = 0
    
    @State var compra = TradeModel(id: "34", name: "Hey", value: 23, tag: Tags.getTags())
    
    var userName: String = "Jujuba"
    var body: some View {
        ScrollView {
            VStack (spacing: 16){
                VStack{
                    HStack{
                        Text("Hello, \(userName)!")
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                    }
                    HStack{
                        Text("Any interesting trades today?")
                            .foregroundColor(Color(UIColor.systemGray))
                        Spacer()
                    }
                }
                .padding(.horizontal, 16)
                Divider()
                
                VStack{
                    HStack{
                        VStack {
                            HStack{
                                Text("My envelopes")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            ScrollView (.horizontal, showsIndicators: false){
                                HStack{
                                    ListaEnvelope(envelopeListManager: envelopeListManager, selectedEnvelope: $selectedEnvelope)
                                    Button {
                                        showNewEnvelope.toggle()
                                    } label: {
                                        NewEnvelopeButtonView()
                                    }
                                }
                            }
                        }
                    }
                    
                    
                    
                }
                
                VStack{
                    HStack {
                        Text("Last Trades")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    
                    VStack {
                    Button {
                        
                        showNewTrade.toggle()
                    } label: {
                        NewTradeButton()
                    }
                        
                        ListaCompra(tradeListManager: tradeListManager, showEditView: $showEditTrade, selectedTrade: $selectedTrade)
                        }
                    Spacer()
                }
                
            }
            .padding(10)
        }
        .onChange(of: selectedTrade, perform: {_ in
            showEditTrade.toggle()
        })
        .sheet(isPresented: $showNewTrade){
            NewTradeView(showNewTrade: $showNewTrade, tradeListManager: tradeListManager)
                .presentationDetents([.fraction(0.9)])
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showEditTrade){
            EditTradeView(
                showEditTrade: $showEditTrade,
                tradeListManager: tradeListManager,
                index: selectedTrade,
                trade: $tradeListManager.lista[selectedTrade])
                .presentationDetents([.fraction(0.9)])
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showNewEnvelope){
            NewEnvelopeView(envelopeListManager: envelopeListManager, showNewEnvelope: $showNewEnvelope)
                .presentationDetents([.fraction(0.9)])
                .interactiveDismissDisabled()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(tradeModel: TradeModel(id: "3", name: "iFood", value: 25, tag: []))
            .environmentObject(EnvelopeListManager())
            .environmentObject(TradeListManager())
            
    }
}
