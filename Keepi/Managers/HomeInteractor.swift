//
//  HomeInteractor.swift
//  Keepi
//
//  Created by Diego Henrick on 13/09/23.
//

import Foundation
import Combine

class HomeInteractor : ObservableObject {
    private let tradeListManager: TradeListManager
    private let envelopeListManager: EnvelopeListManager
    
    @Published var listTrades: [TradeModel] = []
    @Published var listEnvelopes: [EnvelopeModel] = []
    
    private var cancellables: [AnyCancellable] = []
    
    init(tradeListManager: TradeListManager, envelopeListManager: EnvelopeListManager) {
        self.tradeListManager = tradeListManager
        self.envelopeListManager = envelopeListManager
        
        cancellables.append(contentsOf: [
            tradeListManager.publisher.sink(receiveCompletion: { error in
                fatalError("\(error)")
            }, receiveValue: { list in
                self.listTrades = list
                print("aaaa - listTrades: \(list)")
                envelopeListManager.fetchEnvelopes()

            }),
            
            envelopeListManager.publisher.sink(receiveCompletion: { error in
                fatalError("\(error)")
            }, receiveValue: { list in
                self.listEnvelopes = list
                print("aaaa - listEnvelopes: \(list)")
            })
        ])
        
        tradeListManager.fetchTrades()
    }
    
    func removeTrade(indexItem: Int) {
        tradeListManager.removeTrade(indexItem: indexItem)
    }
    
    func removeEnvelope(indexItem: Int) {
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
