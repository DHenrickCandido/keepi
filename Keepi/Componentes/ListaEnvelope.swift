//
//  ListaEnvelope.swift
//  Keepi
//
//  Created by Kauane Santana on 05/09/23.
//

import SwiftUI

// View
// @State var lista: ListaFiltro
// ListaEnvelope(listaFiltroStruct: $lista
//

struct ListaEnvelope: View {
    @ObservedObject var envelopeListManager: EnvelopeListManager
    @ObservedObject var tradeListManager: TradeListManager
//    @State var listaFiltroStruct: ListaFiltro = ListaFiltro()
    @Binding var selectedEnvelope: Int
    @State var envelopeModelSelected: EnvelopeModel!
    
    var body: some View {
        HStack {
            ForEach(Array(envelopeListManager.listaEnvelope.enumerated()), id: \.element.id) { index, item in
                
                
                NavigationLink {
                    EnvelopeFilterView(envelopeListManager: envelopeListManager, tradeListManager: tradeListManager, envelopeId: item.id)
                } label: {
                    EnvelopeCardView(icon: item.icon, name: item.name, budget: item.budget)
                    
                }
                
                
                
                //                Button(action: {
                //                    envelopeModelSelected = item
                //                    goToFilter.toggle()
                //                    print("É nulo?")
                //                    print(envelopeModelSelected == nil)
                //                    print(goToFilter)
                //
                //                }) {
                //                    EnvelopeCardView(icon: item.icon, name: item.name, budget: item.budget)
                //                }
            }
        }
    }
}
