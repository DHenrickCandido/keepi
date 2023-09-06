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
        VStack(alignment: .center, spacing: 8){
            Image(icon)
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundColor(Color(UIColor.systemGray2))
                .padding(8)
            VStack(alignment: .center){
                Text(name)
                    .foregroundColor(Color(UIColor.black))
                    .font(.headline)
                    .bold()
                Text("R$ \(budget.formatted(.number.precision(.fractionLength(2))))")
                    .foregroundColor(Color(UIColor.systemGray))
                    .fontWeight(.regular)
            }
            .padding(0)
            .frame(width: 120, height: 42, alignment: .top)
            
        }
//            .padding(.horizontal, 34)
            .padding(.vertical, 16)
            .frame(width: 160, height: 160, alignment: .center)
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
