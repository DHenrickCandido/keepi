//
//  EnvelopeFilterView.swift
//  Keepi
//
//  Created by Kauane Santana on 12/09/23.
//

import SwiftUI

struct EnvelopeFilterView: View {
    @ObservedObject var envelopeListManager: EnvelopeListManager
    @ObservedObject var tradeListManager: TradeListManager
    var envelopeId: String
//    @State var listaFiltroStruct: ListaFiltro = ListaFiltro()
    
    var body: some View {
        ScrollView {
            ForEach(Array(tradeListManager.lista.enumerated()), id: \.element.id){ index, item in
                if(item.envelopeId == envelopeId){
                    Text(item.name)
                }
//
                
            }
        }.onTapGesture {
            print("cheguei")
        }
    }
}

//struct EnvelopeFilterView_Previews: PreviewProvider {
//    static var previews: some View {
//        EnvelopeFilterView()
//    }
//}
