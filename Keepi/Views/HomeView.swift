//
//  HomeView.swift
//  Keepi
//
//  Created by Diego Henrick on 30/08/23.
//

import SwiftUI
import Firebase

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
        NavigationView{
            ZStack {
                
                //Header (logo + mascote)
                VStack {
                    ZStack (alignment: .leading) {
                        Rectangle()
                            .frame(height: 240)
                            .foregroundColor(Color("darkGreenKeepi"))
                            .onChange(of: showEditTrade, perform: { _ in }) // NAO TIRA ISSO
                            .roundedCorner(16, corners: [.bottomLeft, .bottomRight])
                        
                        
                        
                        HStack (alignment: .top) {
                            Image("keepi")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 40)
                            
                            Spacer()
                            
                            Image("keepiMascote")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 120)
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    
                    Spacer()
                }.ignoresSafeArea()
                //Fim do Header
                
                
                
                VStack (spacing: 24) {
                    
                    Spacer()
                        .frame(height: 46)
                    
                    //Início Box Envelope
                    VStack (alignment: .leading, spacing: 8) {
                        HStack {
                            Text("My envelopes")
                                .font(.body)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.gray))
                            
                            Spacer()
                        }
                        
                        ScrollView (.horizontal, showsIndicators: false) {
                            HStack {
                                //Inicio Envelope
                                ListaEnvelope(envelopeListManager: envelopeListManager, tradeListManager: tradeListManager, selectedEnvelope: $selectedEnvelope)
                                Button {
                                    showNewEnvelope.toggle()
                                } label: {
                                    NewEnvelopeButtonView()
                                }
                                //Fim envelope
                                
                                
                                
                            }
                            
                        }
                        
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .padding(.leading, 16)
                    .padding(.trailing, 8)
                    .background(.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
                    //Fim box envelope
                    
                    VStack {
                        //Inicio cabecalho trocas
                        HStack {
                            Text("Last trades")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            //Inicio botao novas trocas
                            Button {
                                showNewTrade.toggle()
                            } label: {
                                HStack (spacing: 8) {
                                    Image(systemName: "plus.app.fill")
                                        .font(.title)
                                        .foregroundColor(Color("lightGreenKeepi"))
                                    
                                    Text("New trade")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color("darkGreenKeepi"))
                                .cornerRadius(16)
                            }
                            
                            
                            //Fim botao novas trocas
                            
                        }
                        //Fim cabeçalho trocas
                        
                        Spacer()
                        
                        VStack (alignment: .center) {
                            if(tradeListManager.lista.count == 0) {
                                Spacer()
                                
                                Image("keepiTrocas")
                                
                                Spacer()
                            }
                            
                            Spacer()
                            
                            ScrollView (showsIndicators: false){
                                VStack {
                                    
                                    ListaCompra(tradeListManager: tradeListManager, showEditView: $showEditTrade, selectedTrade: $selectedTrade)
                                }
                            }
                        }
                        
                        
                        
                    }
                    
                    
                }
                .padding(16)
                
                
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("lightGrayKeepi"))
            //                .onChange(of: selectedTrade, perform: { _ in
            //                    showEditTrade.toggle()
            //                })
            .sheet(isPresented: $showNewTrade){
                NewTradeView(showNewTrade: $showNewTrade, tradeListManager: tradeListManager, envelopeListManager: envelopeListManager)
                    .presentationDetents([.fraction(0.9)])
                    .interactiveDismissDisabled()
            }
            .sheet(isPresented: $showEditTrade){
                let _ = print("AAA - selectedTrade (HomeView) \(selectedTrade)")
                EditTradeView(
                    showEditTrade: $showEditTrade,
                    tradeListManager: tradeListManager,
                    envelopeListManager: envelopeListManager,
                    index: selectedTrade,
                    trade: $tradeListManager.lista[selectedTrade],
                    selectedIndex: $selectedTrade)
                .presentationDetents([.fraction(0.9)])
                .interactiveDismissDisabled()
                //                        .id("\(selectedTrade) - \(showEditTrade)")
            }
            .sheet(isPresented: $showNewEnvelope){
                NewEnvelopeView(envelopeListManager: envelopeListManager, showNewEnvelope: $showNewEnvelope)
                    .presentationDetents([.fraction(0.9)])
                    .interactiveDismissDisabled()
            }
            .onAppear(){
                anonymous()
            }
        }}
        
//    }
    func anonymous() {

        Auth.auth().signInAnonymously { authResult, error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
}

//Estrutura e função para fazer o retangulo ter arredondamento só embaixo
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func roundedCorner(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )

    }
}
//Fim da estrutura e função

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(tradeModel: TradeModel(id: "3", name: "iFood", value: 25, tag: []))
            .environmentObject(EnvelopeListManager())
            .environmentObject(TradeListManager())
            
    }
}
