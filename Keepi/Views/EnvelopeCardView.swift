//
//  EnvelopeCardView.swift
//  Keepi
//
//  Created by Diego Henrick on 30/08/23.
//

import SwiftUI

struct EnvelopeCardView: View {
    var icon: String
    var name: String
    var budget: Float
    var body: some View {
        VStack{
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(8)
                .frame(width: 48, height: 48)
                .background(.white)
                .cornerRadius(8)
            VStack{
                Text(name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("blackKeepi"))
                Text("$ \(budget.formatted(.number.precision(.fractionLength(2))))")
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.darkGray))
            }
        }
        .padding(8)
        .frame(width: 142, height: 119)
        .background(Color("lightGrayKeepi"))
        .cornerRadius(16)
            
    }
}

struct EnvelopeCardView_Previews: PreviewProvider {
    static var previews: some View {
        EnvelopeCardView(icon: "birthday.cake.fill", name: "iFood", budget: 200.0)
    }
}
