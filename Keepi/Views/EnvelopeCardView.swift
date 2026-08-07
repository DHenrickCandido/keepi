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

    private var percentUsed: Int? {
        guard let budget = monthlyBudget, budget > 0 else { return nil }
        let doubleSpent = Double(truncating: spent as NSNumber)
        let doubleBudget = Double(truncating: budget as NSNumber)
        return Int((doubleSpent / doubleBudget) * 100)
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

                Text(KeepiFormat.currency(spent))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color("blackKeepi"))
                    .padding(.top, 2)

                Text("this month")
                    .font(.caption)
                    .foregroundColor(Color(UIColor.darkGray))

                if let budget = monthlyBudget, let percent = percentUsed {
                    Text("Budget: \(KeepiFormat.currency(budget))")
                        .font(.caption2)
                        .foregroundColor(Color(UIColor.gray))
                        .padding(.top, 4)
                    
                    Text("\(percent)% used")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(percent > 100 ? Color("red") : Color(UIColor.gray))
                }
            }
        }
        .padding(8)
        .frame(width: 142, height: 160)
        .background(Color("lightGrayKeepi"))
        .cornerRadius(16)
            
    }
}

struct EnvelopeCardView_Previews: PreviewProvider {
    static var previews: some View {
        EnvelopeCardView(icon: "birthday.cake.fill", name: "iFood", monthlyBudget: 200.0, spent: 50.0)
    }
}
