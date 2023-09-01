//
//  EnvelopeCardView.swift
//  Keepi
//
//  Created by Diego Henrick on 30/08/23.
//

import SwiftUI

struct EnvelopeCardView: View {
    @State var icon: String
    @State var name: String
    @State var budget: Float
    var body: some View {
        VStack{
            Image(systemName: icon)
                .foregroundColor(Color(UIColor.systemGray2))
                .font(.system(size: 50))
                .padding(8)
            Text(name)
                .foregroundColor(Color(UIColor.black))
                .font(.title3)
                .bold()
            Text("R$ \(budget.formatted(.number.precision(.fractionLength(2))))")
                .foregroundColor(Color(UIColor.systemGray))
                .fontWeight(.regular)
        }.padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(Color(UIColor.systemGray6))
            .foregroundColor(.white)
            .cornerRadius(16)
            
    }
}

struct EnvelopeCardView_Previews: PreviewProvider {
    static var previews: some View {
        EnvelopeCardView(icon: "birthday.cake.fill", name: "iFood", budget: 200.0)
    }
}
