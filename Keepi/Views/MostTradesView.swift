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
        let totalValueSpent = totalValueSpend(list: interactor.listTrades)
        
        
        VStack{
            Text("Most of your trades")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            if totalValueSpent <= 0 {
                Text("Add entries to see spending patterns.")
                    .font(.subheadline)
                    .foregroundColor(Color(.systemGray))
            } else {
                ForEach(valueSpentByEnvelope(list: interactor.listTrades).sorted(by: { $0.key < $1.key }), id: \.key) { envelopeID, value in
                    HStack(){
                        Text("\(envelopeID.isEmpty ? "No envelope" : envelopeID)")
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(width: 150, alignment: .leading)

                        Rectangle()
                            .fill(Color("graph3"))
                            .frame(width: CGFloat(value / totalValueSpent) * 200, height: 20, alignment: .leading)
                            .cornerRadius(10)
                    }
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
