//
//  EnvelopeModel.swift
//  Keepi
//
//  Created by Kauane Santana on 05/09/23.
//

import SwiftUI

class EnvelopeModel: Identifiable, ObservableObject{
//    let id = UUID()
    @Published var id: String
    @Published var name: String
    @Published var budget: Float
    @Published var icon: String
    
    init(id: String, name: String, budget: Float, icon: String){
        self.id = id
        self.name = name
        self.budget = budget
        self.icon = icon
    }
}

