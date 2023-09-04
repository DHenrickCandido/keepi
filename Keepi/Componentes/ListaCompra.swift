//
//  ListaCompra.swift
//  Keepi
//
//  Created by Kauane Santana on 28/08/23.
//

import SwiftUI

struct ListaCompra: View {
    @ObservedObject var tradeListManager: TradeListManager
    @Binding var showEditView : Bool
    @Binding var selectedTrade: Int
    
    var body: some View {
        VStack {
            ForEach(Array(tradeListManager.lista.enumerated()), id: \.element.id) { index, item in
                Button(action: {
                    showEditView.toggle()
                    selectedTrade = index
//                    tradeListManager.removeTrade(indexItem: index)
                }) {
                    TradeCardComponent(name: item.name, value: item.value, selectedTags: item.tag)
                }
            }
        }
    }
}

//struct ListaCompra_Previews: PreviewProvider {
//    static var previews: some View {
////        ListaCompra(tradeListManager: TradeListManager())
//    }
//}
