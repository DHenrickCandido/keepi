//
//  ListaCompra.swift
//  Keepi
//
//  Created by Kauane Santana on 28/08/23.
//

import SwiftUI

struct ListaCompra: View {
    @EnvironmentObject var interactor: HomeInteractor
    
    @Binding var showEditView : Bool
    @Binding var selectedTrade: Int

    private var orderedTrades: [(index: Int, trade: TradeModel)] {
        interactor.listTrades
            .enumerated()
            .map { (index: $0.offset, trade: $0.element) }
            .sorted { $0.trade.date > $1.trade.date }
    }
    
    var body: some View {
        VStack {
            ForEach(orderedTrades, id: \.trade.id) { item in
                Button(action: {
                    selectedTrade = item.index
                    showEditView = true
                }) {
                    TradeCardComponent(
                        date: item.trade.date,
                        name: item.trade.name,
                        value: item.trade.value,
                        selectedTags: item.trade.tag,
                        envelopeName: interactor.getEnvelopeNameById(id: item.trade.envelopeId),
                        feeling: item.trade.feeling,
                        journalEntry: item.trade.journalEntry
                    )
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
