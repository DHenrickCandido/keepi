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
    var monthlyBudget: Decimal?
    var spent: Decimal

    private var remaining: Decimal? {
        if let monthlyBudget = monthlyBudget {
            return monthlyBudget - spent
        }
        return nil
    }

    private var statusText: String {
        guard let remaining = remaining else { return "Spent" }
        if remaining < 0 {
            return "Over budget"
        }
        if remaining <= 25 {
            return "Low balance"
        }
        return "Remaining"
    }

    private var statusColor: Color {
        guard let remaining = remaining else { return Color(.systemGray) }
        if remaining < 0 {
            return Color("red")
        }
        if remaining <= 25 {
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

                Text(KeepiFormat.currency(remaining ?? spent))
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
        EnvelopeCardView(icon: "birthday.cake.fill", name: "iFood", monthlyBudget: 200.0, spent: 50.0)
    }
}
