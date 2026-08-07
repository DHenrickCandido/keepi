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

    private var orderedTrades: [(index: Int, transaction: TransactionModel)] {
        interactor.listTransactions
            .enumerated()
            .map { (index: $0.offset, transaction: $0.element) }
            .sorted { $0.transaction.date > $1.transaction.date }
    }
    
    var body: some View {
        VStack {
            ForEach(orderedTrades, id: \.transaction.id) { item in
                Button(action: {
                    selectedTrade = item.index
                    showEditView = true
                }) {
                    TransactionCardComponent(
                        date: item.transaction.date,
                        name: item.transaction.name,
                        value: item.transaction.value,
                        envelopeName: interactor.getEnvelopeNameById(id: item.transaction.envelopeId),
                        feeling: item.transaction.feeling,
                        journalEntry: item.transaction.journalEntry
                    )
                }
            }
        }
    }
}

//struct ListaCompra_Previews: PreviewProvider {
//    static var previews: some View {
////        ListaCompra(transactionListManager: TransactionListManager())
//    }
//}
