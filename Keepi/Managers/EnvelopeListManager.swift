//
//  EnvelopeListManager.swift
//  Keepi
//
//  Created by Kauane Santana on 05/09/23.
//

import SwiftUI

class EnvelopeListManager: ObservableObject {
    @Published var listaEnvelope: [EnvelopeModel] = []
    
    func addEnvelope(item: EnvelopeModel) {
            listaEnvelope.insert(item, at: 0)
            print(listaEnvelope)
        }
}
