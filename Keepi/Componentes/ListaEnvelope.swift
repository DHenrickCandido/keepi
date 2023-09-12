//
//  ListaEnvelope.swift
//  Keepi
//
//  Created by Kauane Santana on 05/09/23.
//

import SwiftUI

struct ListaEnvelope: View {
    @ObservedObject var envelopeListManager: EnvelopeListManager
    @ObservedObject var tradeListManager: TradeListManager
    @Binding var selectedEnvelope: Int
    
    var body: some View {
        HStack {
            ForEach(Array(envelopeListManager.listaEnvelope.enumerated()), id: \.element.id) { index, item in
                Button(action: {
                    selectedEnvelope = index
                    
                    let filtro = tradeListManager.lista.filter { trade in
                        if  trade.envelopeId == item.id{
                            print("Compras do envelope \(item.name)")
                            return true

                        } else {
                            // 2
                            print("Compras do envelope \(item.name)")
                            return false

                        }
                    }
                    
//                    tradeListManager.removeTrade(indexItem: index)
                }) {
                    EnvelopeCardView(icon: item.icon, name: item.name, budget: item.budget)
                }
            }
        }
    }
}
