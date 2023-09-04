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
    
    @State private var showNewTrade: Bool = false
    
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
                                    ForEach(0..<2) {_ in
                                        EnvelopeCardView(icon: "birthday.cake.fill", name: "iFood", budget: 200.0)
                                    }
                                    NewEnvelopeButtonView()
                                    
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
                        
                        ListaCompra(tradeListManager: tradeListManager)
                        }
                    Spacer()
                }
                
            }
            .padding(10)
        }
        .sheet(isPresented: $showNewTrade){
            NewTradeView(showNewTrade: $showNewTrade, tradeListManager: tradeListManager)
                .presentationDetents([.fraction(0.9)])
                .interactiveDismissDisabled()
                
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(tradeModel: TradeModel(name: "iFood", value: 25, tag: []))
            .environmentObject(TradeListManager())
    }
}
