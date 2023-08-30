//
//  Compra.swift
//  Keepi
//
//  Created by Kauane Santana on 25/08/23.
//

import SwiftUI

struct Trade: View {
    @StateObject var tradeModel: TradeModel
    @StateObject var tradeListModel: TradeListManager
    
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
                tradeListModel.addTrade(item: compra)
                })
                ListaCompra(tradeListManager: tradeListModel)
            }
    }
}
struct Compra_Previews: PreviewProvider {
    static var previews: some View {
        Trade(tradeModel: TradeModel(name: "teste"), tradeListModel: TradeListManager())
    }
}
