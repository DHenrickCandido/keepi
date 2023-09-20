//
//  MostTradesView.swift
//  Keepi
//
//  Created by Diego Henrick on 14/09/23.
//

import SwiftUI


struct MostTradesView: View {
    @EnvironmentObject var interactor: HomeInteractor
    
    var body: some View {
        var totalValueSpent: Float = totalValueSpend(list: interactor.listTrades)
        
        
        VStack{
            Text("Most of your trades")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            ForEach(valueSpentByEnvelope(list: interactor.listTrades).sorted(by: { $0.key < $1.key }), id: \.key) { envelopeID, value in
                HStack(){
                    Text("\(envelopeID)")
//                        .frame(maxWidth: 100, alignment: .leading) // Alinhe o texto à esquerda
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(width: 150, alignment: .leading)

                    Rectangle()
                        .fill(Color("graph3")) // Seleciona a cor com base no índice atual
                        .frame(width: CGFloat(value / totalValueSpent) * 200, height: 20, alignment: .leading) // Ajuste a altura e outros estilos conforme necessário
                        .cornerRadius(10) // Adjust the corner radius to your desired value
//                        .frame(alignment: .leading)
                }
                
            }
            
            
            
        }
        .frame(maxWidth: 300, alignment: .leading)
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(Color(.white))
        .foregroundColor(Color(.systemGray))
        
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
        
        
    }
}

func valueSpentByEnvelope(list: [TradeModel] ) -> [String: Float] {
    var valoresTotaisPorEnvelope: [String: Float] = [:]

    // Iterar pela array de objetos e somar os valores por idEnvelope
    for trade in list {
        if let valorExistente = valoresTotaisPorEnvelope[trade.envelopeId] {
            // Se já houver um valor para este idEnvelope, adicione o valor do objeto a ele
            valoresTotaisPorEnvelope[trade.envelopeId] = valorExistente + trade.value
        } else {
            // Caso contrário, crie uma entrada no dicionário com o valor do objeto
            valoresTotaisPorEnvelope[trade.envelopeId] = trade.value
        }
    }
    
    return valoresTotaisPorEnvelope
}

func totalValueSpend(list: [TradeModel]) -> Float {
    var total: Float = 0.0
    
    for trade in list {
        total += trade.value
    }
    
    return total
}


struct MostTradesView_Previews: PreviewProvider {
    static var previews: some View {
        MostTradesView()
            .environmentObject(HomeInteractor(tradeListManager: TradeListManager(), envelopeListManager: EnvelopeListManager()))
    }
}
