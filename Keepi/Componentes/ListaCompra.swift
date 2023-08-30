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
            List{
                ForEach(Array(tradeListManager.lista.enumerated()), id: \.element.id) { index, item in
                    Button(action: {
                        tradeListManager.removeTrade(indexItem: index)
                    }) {
                        Text(item.name)
                    }
                }
//                ForEach(tradeListManager.lista){i in
//                    Button{
//
//                    }label:{
//                        Text(i.name)
//                    }
//
//                }
            }
        }
    }
}

struct ListaCompra_Previews: PreviewProvider {
    static var previews: some View {
        ListaCompra(tradeListManager: TradeListManager())
    }
}
