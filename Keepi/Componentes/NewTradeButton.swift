//
//  NewTradeButton.swift
//  Keepi
//
//  Created by Kauane Santana on 31/08/23.
//

import SwiftUI

struct NewTradeButton: View {
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 16) {
                Image(systemName: "plus.square.fill")
                    .foregroundColor(Color(UIColor.systemGray))
                    .font(.largeTitle)
                    .font(.system(size: 34))
                    .padding()
                
                Text("Nova Troca")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(UIColor.systemGray))
            }
            .padding(0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.5)
                .stroke(Color(red: 0.56, green: 0.56, blue: 0.58), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
        )
    }
}

struct NewTradeButton_Previews: PreviewProvider {
    static var previews: some View {
        NewTradeButton()
    }
}
