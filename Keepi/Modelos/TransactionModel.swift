//
//  CompraModelo.swift
//  Keepi
//
//  Created by Kauane Santana on 25/08/23.
//

import SwiftUI

enum TransactionType: String, CaseIterable, Codable {
    case expense
    case income
    case transfer
}

class TransactionModel: Identifiable, ObservableObject, CustomStringConvertible {
    @Published var id: String
    @Published var name: String
    @Published var envelopeId: String
    @Published var value: Decimal
    @Published var date: Date
    @Published var feeling: Int // Int de 0 a 4 - vai definir o icon
    @Published var reflectionCompleted: Bool
    @Published var worthIt: Bool?
    @Published var isPlanned: Bool?
    @Published var type: TransactionType
    @Published var note: String
    @Published var journalEntry: String
    @Published var sourceFingerprint: String?
    
    var description: String {
        return "id: \(id), name: \(name), value: \(value), envelopeId: \(envelopeId)"
    }
    
    init(
        id: String,
        name: String,
        value: Decimal,
        envelopeId: String = "",
        feeling: Int = 0,
        date: Date = Date(),
        reflectionCompleted: Bool = true,
        worthIt: Bool? = nil,
        isPlanned: Bool? = nil,
        type: TransactionType = .expense,
        note: String = "",
        journalEntry: String = "",
        sourceFingerprint: String? = nil
    ) {
        self.id = id
        self.name = name
        self.value = value
        self.envelopeId = envelopeId
        self.date = date
        self.feeling = feeling
        self.reflectionCompleted = reflectionCompleted
        self.worthIt = worthIt
        self.isPlanned = isPlanned
        self.type = type
        self.note = note
        self.journalEntry = journalEntry
        self.sourceFingerprint = sourceFingerprint
    }
}
