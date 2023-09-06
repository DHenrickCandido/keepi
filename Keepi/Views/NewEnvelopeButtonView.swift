//
//  NewEnvelopeButtonView.swift
//  Keepi
//
//  Created by Diego Henrick on 30/08/23.
//

import SwiftUI

struct NewEnvelopeButtonView: View {
    var body: some View {
        VStack{
            Image(systemName: "plus.square.fill")
                .foregroundColor(Color(UIColor.systemGray2))
                .font(.system(size: 50))
                .padding()
            Text("Novo")
                .foregroundColor(Color(UIColor.systemGray))
                .fontWeight(.semibold)
                .font(.headline)
            Text("Envelope")
                .foregroundColor(Color(UIColor.systemGray))
                .fontWeight(.semibold)
                .font(.headline)

        }
        .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .frame(width: 160, height: 160, alignment: .center)
//            .background(Color(UIColor.systemGray6))
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .inset(by: 0.5)
                    .stroke(Color(red: 0.56, green: 0.56, blue: 0.58), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
            )
            
            
        
    }
}

struct NewEnvelopeButtonView_Previews: PreviewProvider {
    static var previews: some View {
        NewEnvelopeButtonView()
    }
}
