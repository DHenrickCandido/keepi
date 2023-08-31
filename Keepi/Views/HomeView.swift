//
//  HomeView.swift
//  Keepi
//
//  Created by Diego Henrick on 30/08/23.
//

import SwiftUI

struct HomeView: View {
    @StateObject var tradeModel: TradeModel
    @StateObject var tradeListManager: TradeListManager
    
    //str do campo que vai ir para o titulo
    @State var compraTitulo: String = ""
    
    
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
                        VStack{
                            TextField("textooo: ", text: $compraTitulo)
                        }
                    Button {
                        let compra = TradeModel(name: compraTitulo)
                        tradeListManager.addTrade(item: compra)
                        
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
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(tradeModel: TradeModel(name: "iFood"), tradeListManager: TradeListManager())
    }
}
