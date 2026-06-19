//
//  HomeInteractor.swift
//  Keepi
//
//  Created by Diego Henrick on 13/09/23.
//

import Foundation
import Combine

class HomeInteractor: ObservableObject {
    private let tradeListManager: TradeListManager
    private let envelopeListManager: EnvelopeListManager

    @Published var listTrades: [TradeModel] = []
    @Published var listEnvelopes: [EnvelopeModel] = []
    @Published var errorMessage: String?

    private var cancellables: [AnyCancellable] = []

    init(tradeListManager: TradeListManager, envelopeListManager: EnvelopeListManager) {
        self.tradeListManager = tradeListManager
        self.envelopeListManager = envelopeListManager

        cancellables.append(contentsOf: [
            tradeListManager.publisher.sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { list in
                self.listTrades = list
                envelopeListManager.fetchEnvelopes()
            }),

            envelopeListManager.publisher.sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { list in
                self.listEnvelopes = list
            })
        ])

        loadData()
    }

    func loadData() {
        tradeListManager.fetchTrades()
        envelopeListManager.fetchEnvelopes()
    }

    func removeTrade(indexItem: Int) {
        guard listTrades.indices.contains(indexItem) else {
            errorMessage = "Selected entry no longer exists."
            return
        }

        tradeListManager.removeTrade(indexItem: indexItem)
    }

    func removeEnvelope(indexItem: Int) {
        guard listEnvelopes.indices.contains(indexItem) else {
            errorMessage = "Selected envelope no longer exists."
            return
        }

        let envelope = listEnvelopes[indexItem]
        guard CRUDValidation.canDeleteEnvelope(envelopeId: envelope.id, trades: listTrades) else {
            errorMessage = "Move or delete entries before removing this envelope."
            return
        }

        envelopeListManager.removeEnvelope(indexItem: indexItem)
    }

    func updateTrade(trade: TradeModel) {
        tradeListManager.updateTrade(trade: trade)
    }

    func updateEnvelope(envelope: EnvelopeModel) {
        envelopeListManager.updateEnvelope(envelope: envelope)
    }

    func addTrade(trade: TradeModel) {
        tradeListManager.addTrade(trade: trade)
    }

    func addEnvelope(envelope: EnvelopeModel) {
        envelopeListManager.addEnvelope(envelope: envelope)
    }

    func getEnvelopeNameById(id: String) -> String {
        envelopeListManager.getEnvelopeNameById(id: id)
    }
}
