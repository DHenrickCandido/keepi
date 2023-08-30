//
//  CompraModelo.swift
//  Keepi
//
//  Created by Kauane Santana on 25/08/23.
//

import SwiftUI

class CompraModel: Identifiable, ObservableObject{
    let id = UUID()
    @Published var lista: [CompraModel] = []
    @Published var name: String
//    @Published var envelope: Int
//    @Published var value: Float
//    @Published var date: Date
//    @Published var tag: [tags]
//    @Published var feeling: Feeling
    
    init(name: String){
        self.name = name
    }
    
        //criar classe de compraLista p add as compras
    func addCompra(item: CompraModel) {
        lista.insert(item, at: 0)
//        lista.append(item)
        print(lista)
    }
}


