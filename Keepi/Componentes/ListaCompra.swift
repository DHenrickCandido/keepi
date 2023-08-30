//
//  ListaCompra.swift
//  Keepi
//
//  Created by Kauane Santana on 28/08/23.
//

import SwiftUI

struct ListaCompra: View {
    var compraModel: CompraModel
    
    var body: some View {
        
        //lista as compras (essa parte do codigo vai depois na view de lista)
        VStack {
            ForEach(compraModel.lista) { i in
                Text(i.titulo)
            }
        }
        
//        for i in compraModel.lista{
//            print(i.titulo)
//        }
    }
}

struct ListaCompra_Previews: PreviewProvider {
    static var previews: some View {
        ListaCompra(compraModel: CompraModel(titulo: "teste"))
    }
}
