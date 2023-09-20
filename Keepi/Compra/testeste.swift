//
//  CompraModelo.swift
//  Keepi
//
//  Created by Kauane Santana on 25/08/23.
//

import SwiftUI

class CompraModel: Identifiable{
    let id = UUID()
    @Published var titulo: String
    
    init(titulo: String){
        self.titulo = titulo
    }
    
        
    func addCompra() {
        print("adicionado")
    }
}

let compraTeste = CompraModel(titulo: "bota")
compraTeste.addCompra()
