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
    @State var envelopeModelSelected: EnvelopeModel!
    
//    @Binding var listTitleEnvelopeName: String
    
    var body: some View {
        HStack {
            ForEach(Array(interactor.listEnvelopes.enumerated()), id: \.element.id) { index, item in
                NavigationLink {
                    EnvelopeFilterView(selectedEnvelope: index, envelopeId: item.id)
                } label: {
                    EnvelopeCardView(icon: item.icon, name: item.name, budget: item.budget)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    selectedEnvelope = index
                })
            }
        }
    }
}
