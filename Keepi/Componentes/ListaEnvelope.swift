//
//  ListaEnvelope.swift
//  Keepi
//
//  Created by Kauane Santana on 05/09/23.
//

import SwiftUI

struct ListaEnvelope: View {
    @ObservedObject var envelopeListManager: EnvelopeListManager
    @Binding var selectedEnvelope: Int
    
    var body: some View {
        HStack {
            ForEach(Array(envelopeListManager.listaEnvelope.enumerated()), id: \.element.id) { index, item in
                Button(action: {
                    selectedEnvelope = index
//                    tradeListManager.removeTrade(indexItem: index)
                }) {
                    EnvelopeCardView(icon: item.icon, name: item.name, budget: item.budget)
                }
            }
        }
    }
}
