//
//  CompraModelo.swift
//  Keepi
//
//  Created by Kauane Santana on 25/08/23.
//

import SwiftUI

class TradeModel: Identifiable, ObservableObject{
//    let id = UUID()
    @Published var id: String
    @Published var name: String
//    @Published var envelope: Int
    @Published var value: Float
//    @Published var date: Date
    @Published var tag: [Tag]
//    @Published var feeling: Feeling
    
    init(id: String, name: String, value: Float, tag: [Tag]){
        self.id = id
        self.name = name
        self.value = value
        self.tag = tag
    }
}


