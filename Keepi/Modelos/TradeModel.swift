//
//  CompraModelo.swift
//  Keepi
//
//  Created by Kauane Santana on 25/08/23.
//

import SwiftUI

class TradeModel: Identifiable, ObservableObject, CustomStringConvertible {
//    let id = UUID()
    @Published var id: String
    @Published var name: String
    @Published var envelopeId: String
    @Published var value: Float
    @Published var date: Date
    @Published var tag: [Tag]
    @Published var feeling: Int // Int de 0 a 4 - vai definir o icon
    
    var description: String {
        return "id: \(id), name: \(name), value: \(value), envelopeId: \(envelopeId)"
    }
    
    init(id: String, name: String, value: Float, tag: [Tag], envelopeId: String = "", feeling: Int = 0, date: Date = Date()){
        self.id = id
        self.name = name
        self.value = value
        self.tag = tag
        self.envelopeId = envelopeId
        self.date = date
        self.feeling = feeling
    }
}


