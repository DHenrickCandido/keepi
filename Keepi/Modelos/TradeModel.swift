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
    @Published var value: Decimal
    @Published var date: Date
    @Published var tag: [Tag]
    @Published var feeling: Int // Int de 0 a 4 - vai definir o icon
    @Published var reflectionCompleted: Bool
    @Published var worthIt: Bool?
    @Published var note: String
    @Published var journalEntry: String
    
    var description: String {
        return "id: \(id), name: \(name), value: \(value), envelopeId: \(envelopeId)"
    }
    
    init(
        id: String,
        name: String,
        value: Decimal,
        tag: [Tag],
        envelopeId: String = "",
        feeling: Int = 0,
        date: Date = Date(),
        reflectionCompleted: Bool = true,
        worthIt: Bool? = nil,
        note: String = "",
        journalEntry: String = ""
    ) {
        self.id = id
        self.name = name
        self.value = value
        self.tag = tag
        self.envelopeId = envelopeId
        self.date = date
        self.feeling = feeling
        self.reflectionCompleted = reflectionCompleted
        self.worthIt = worthIt
        self.note = note
        self.journalEntry = journalEntry
    }
}
