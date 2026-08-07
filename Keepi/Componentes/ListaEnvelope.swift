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
    @EnvironmentObject var interactor: HomeInteractor
//    @State var listaFiltroStruct: ListaFiltro = ListaFiltro()
    @Binding var selectedEnvelope: Int
    @State var envelopeModelSelected: Envelope!
    
//    @Binding var listTitleEnvelopeName: String
    
    var body: some View {
        HStack {
            ForEach(Array(interactor.listEnvelopes.enumerated()), id: \.element.id) { index, item in
                NavigationLink {
                    EnvelopeFilterView(selectedEnvelope: index, envelopeId: item.id)
                } label: {
                    EnvelopeCardView(
                        icon: item.icon, 
                        name: item.name, 
                        monthlyBudget: item.monthlyBudget,
                        spent: interactor.spent(forEnvelopeId: item.id),
                        entryCount: interactor.entryCount(forEnvelopeId: item.id)
                    )
                }
                .simultaneousGesture(TapGesture().onEnded {
                    selectedEnvelope = index
                })
            }
        }
    }
}
