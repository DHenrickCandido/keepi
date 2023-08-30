//
//  CompraModelo.swift
//  Keepi
//
//  Created by Kauane Santana on 25/08/23.
//

import SwiftUI

class TradeModel: Identifiable, ObservableObject{
    let id = UUID()
    @Published var name: String
//    @Published var envelope: Int
//    @Published var value: Float
//    @Published var date: Date
//    @Published var tag: [tags]
//    @Published var feeling: Feeling
    
    init(name: String){
        self.name = name
    }
}


