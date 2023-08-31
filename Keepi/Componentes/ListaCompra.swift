//
//  ListaCompra.swift
//  Keepi
//
//  Created by Kauane Santana on 28/08/23.
//

import SwiftUI

struct ListaCompra: View {
    @ObservedObject var tradeListManager: TradeListManager
    
    var body: some View {
        VStack {
            ForEach(Array(tradeListManager.lista.enumerated()), id: \.element.id) { index, item in
                Button(action: {
                    tradeListManager.removeTrade(indexItem: index)
                }) {
                    TradeCardComponent(name: item.name)
//                    Text(item.name)
                }
            }
        }
    }
}

struct ListaCompra_Previews: PreviewProvider {
    static var previews: some View {
        ListaCompra(tradeListManager: TradeListManager())
    }
}
