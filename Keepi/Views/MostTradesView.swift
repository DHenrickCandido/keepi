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

        VStack(alignment: .leading, spacing: 18) {
            Text("Spending patterns")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)

            if totalValueSpent <= 0 {
                Text("Add entries to see spending patterns.")
                    .font(.subheadline)
                    .foregroundColor(Color(.systemGray))
            } else {
                envelopeBars(totalValueSpent: totalValueSpent)

                Divider()

                VStack(spacing: 10) {
                    insightRow(
                        title: "Top feeling",
                        value: mostFrequentFeeling(in: interactor.listTrades) ?? "Not enough data",
                        systemImage: "face.smiling"
                    )

                    insightRow(
                        title: "Top motivation",
                        value: mostFrequentTag(in: interactor.listTrades) ?? "Not enough data",
                        systemImage: "sparkles"
                    )

                    insightRow(
                        title: "Worth-it rate",
                        value: worthItRate(in: interactor.listTrades),
                        systemImage: "checkmark.seal.fill"
                    )

                    insightRow(
                        title: "Needs reflection",
                        value: "\(interactor.listTrades.filter { !$0.reflectionCompleted }.count)",
                        systemImage: "clock.fill"
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(Color(.white))
        .foregroundColor(Color(.systemGray))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
    }

    private func envelopeBars(totalValueSpent: Float) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(valueSpentByEnvelope(list: interactor.listTrades).sorted(by: { $0.value > $1.value }), id: \.key) { envelopeID, value in
                HStack(spacing: 10) {
                    Text(interactor.getEnvelopeNameById(id: envelopeID))
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("blackKeepi"))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(width: 112, alignment: .leading)

                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color("graph3"))
                            .frame(width: max(CGFloat(value / totalValueSpent) * geometry.size.width, 8), height: 20)
                            .cornerRadius(10)
                    }
                    .frame(height: 20)

                    Text(KeepiFormat.currency(value))
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(.systemGray))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(width: 76, alignment: .trailing)
                }
            }
        }
    }

    private func insightRow(title: String, value: String, systemImage: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.footnote)
                .foregroundColor(Color("darkGreenKeepi"))
                .frame(width: 26, height: 26)
                .background(Color("lightGrayKeepi"))
                .clipShape(Circle())

            Text(title)
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundColor(Color("blackKeepi"))

            Spacer()

            Text(value)
                .font(.footnote)
                .foregroundColor(Color(.systemGray))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }
}

private func mostFrequentFeeling(in list: [TradeModel]) -> String? {
    guard let index = mostFrequentValue(list.map(\.feeling)) else { return nil }
    return FeelingList.getFeelings().first(where: { $0.index == index })?.name.capitalized
}

private func mostFrequentTag(in list: [TradeModel]) -> String? {
    let tags = list.flatMap(\.tag)
    return mostFrequentValue(tags.map(\.name))
}

private func worthItRate(in list: [TradeModel]) -> String {
    let reflectedEntries = list.filter { $0.worthIt != nil }
    guard !reflectedEntries.isEmpty else { return "No reflections yet" }
    let worthItCount = reflectedEntries.filter { $0.worthIt == true }.count
    let percentage = Double(worthItCount) / Double(reflectedEntries.count) * 100
    return "\(Int(percentage.rounded()))%"
}

private func mostFrequentValue<Value: Hashable>(_ values: [Value]) -> Value? {
    Dictionary(grouping: values) { $0 }
        .max { lhs, rhs in lhs.value.count < rhs.value.count }?
        .key
}

func valueSpentByEnvelope(list: [TradeModel]) -> [String: Float] {
    var totalByEnvelope: [String: Float] = [:]

    for trade in list {
        totalByEnvelope[trade.envelopeId, default: 0] += trade.value
    }

    return totalByEnvelope
}

func totalValueSpend(list: [TradeModel]) -> Float {
    list.reduce(0) { $0 + $1.value }
}

struct MostTradesView_Previews: PreviewProvider {
    static var previews: some View {
        MostTradesView()
            .environmentObject(HomeInteractor(tradeListManager: TradeListManager(), envelopeListManager: EnvelopeListManager()))
    }
}
