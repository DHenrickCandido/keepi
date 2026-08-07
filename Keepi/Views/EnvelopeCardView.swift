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
    var budget: Decimal

    private var statusText: String {
        if budget < 0 {
            return "Over budget"
        }

        if budget <= 25 {
            return "Low balance"
        }

        return "Remaining"
    }

    private var statusColor: Color {
        if budget < 0 {
            return Color("red")
        }

        if budget <= 25 {
            return Color("yellow")
        }

        return Color("darkGreenKeepi")
    }

    var body: some View {
        VStack(spacing: 8) {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(8)
                .frame(width: 48, height: 48)
                .background(.white)
                .cornerRadius(8)
            VStack(spacing: 2) {
                Text(name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("blackKeepi"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(KeepiFormat.currency(budget))
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.darkGray))

                Text(statusText)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(statusColor)
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
