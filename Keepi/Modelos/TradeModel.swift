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
    @Published var envelopeId: String
    @Published var value: Float
    @Published var date: Date
    @Published var tag: [Tag]
    @Published var feeling: Int // Int de 0 a 4 - vai definir o icon
    
    init(id: String, name: String, value: Float, tag: [Tag], envelopeId: String, feeling: Int, date: Date){
        self.id = id
        self.name = name
        self.value = value
        self.tag = tag
        self.envelopeId = envelopeId
        self.date = date
        self.feeling = feeling
    }
}


