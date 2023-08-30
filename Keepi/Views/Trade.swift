//
//  Compra.swift
//  Keepi
//
//  Created by Kauane Santana on 25/08/23.
//

import SwiftUI

struct Compra: View {
    @StateObject var tradeModel: TradeModel
    
    //str do campo que vai ir para o titulo
    @State var compraTitulo: String = ""
    
    var body: some View {
        VStack {
            Text("card da visualização da compra aqui:")
            VStack{
                TextField("textooo: ", text: $compraTitulo)
            }
            
            //add as instancias das compras em uma lista
            Button("adicionar compra", action: {
                let compra = TradeModel(name: compraTitulo)
                tradeModel.addCompra(item: compra)
                })
            ListaCompra(tradeModel: tradeModel)
            }
    }
}
struct Compra_Previews: PreviewProvider {
    static var previews: some View {
        Compra(tradeModel: TradeModel(name: "teste"))
    }
}
