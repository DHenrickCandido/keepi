//
//  SwiftUIView.swift
//  Keepi
//
//  Created by Kauane Santana on 29/08/23.
//

import SwiftUI

class TradeListManager: ObservableObject {
    @Published var lista: [TradeModel] = []
    
    
    func addTrade(item: TradeModel) {
        lista.insert(item, at: 0)
        print(lista)
    }
    
    func removeTrade(indexItem: Int){
        lista.remove(at: indexItem)
    }
    
    
}
