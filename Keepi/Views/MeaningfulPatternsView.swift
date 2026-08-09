import SwiftUI

struct MeaningfulPatternsView: View {
    @EnvironmentObject var interactor: HomeInteractor

    var body: some View {
        let patterns = generatePatterns(list: interactor.listTransactions)

        VStack(alignment: .leading, spacing: 18) {
            Text("Meaningful patterns")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)

            if interactor.listTransactions.isEmpty {
                Text("Add entries to discover meaningful patterns about your spending.")
                    .font(.subheadline)
                    .foregroundColor(Color(.systemGray))
            } else if patterns.isEmpty {
                Text("Keep adding and reflecting on entries. We need a bit more data to find clear patterns.")
                    .font(.subheadline)
                    .foregroundColor(Color(.systemGray))
            } else {
                VStack(spacing: 12) {
                    ForEach(patterns, id: \.self) { pattern in
                        insightRow(
                            title: pattern,
                            systemImage: "sparkles"
                        )
                    }
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

    private func insightRow(title: String, systemImage: String) -> some View {
        HStack(spacing: 12) {
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
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Spacer()
        }
    }
}

private func generatePatterns(list: [TransactionModel]) -> [String] {
    var patterns: [String] = []
    
    // Pattern 1: Unplanned and regretted purchases
    let unplanned = list.filter { $0.spendingIntent == .impulsive }
    let unplannedReflected = unplanned.filter { $0.worthIt != nil }
    if !unplannedReflected.isEmpty {
        let regretted = unplannedReflected.filter { $0.worthIt == false }.count
        let percentage = Int((Double(regretted) / Double(unplannedReflected.count)) * 100)
        if percentage > 40 {
            patterns.append("\(percentage)% of your unplanned purchases were regretted.")
        }
    }
    
    // Pattern 2: Feeling and spending
    var spendingByFeeling: [Int: Decimal] = [:]
    for t in list {
        spendingByFeeling[t.feeling, default: 0] += t.value
    }
    
    if let highestFeelingIndex = spendingByFeeling.max(by: { $0.value < $1.value })?.key {
        if let feelingName = FeelingList.getFeelings().first(where: { $0.index == highestFeelingIndex })?.name.lowercased() {
            patterns.append("You spend the most when you feel \(feelingName).")
        }
    }
    
    // Pattern 3: Most regretted feeling
    let reflected = list.filter { $0.worthIt != nil }
    var regretsByFeeling: [Int: Int] = [:]
    for t in reflected where t.worthIt == false {
        regretsByFeeling[t.feeling, default: 0] += 1
    }
    if let worstFeelingIndex = regretsByFeeling.max(by: { $0.value < $1.value })?.key {
        if let feelingName = FeelingList.getFeelings().first(where: { $0.index == worstFeelingIndex })?.name.lowercased() {
            patterns.append("Purchases made while \(feelingName) are often regretted.")
        }
    }
    
    // Fallback if patterns is empty but we have some data
    if patterns.isEmpty && !list.isEmpty {
        let worthItCount = reflected.filter { $0.worthIt == true }.count
        if !reflected.isEmpty {
            let percentage = Int((Double(worthItCount) / Double(reflected.count)) * 100)
            patterns.append("\(percentage)% of your reflected purchases were worth it.")
        }
    }
    
    // Limit to top 3 patterns
    return Array(patterns.prefix(3))
}

struct MeaningfulPatternsView_Previews: PreviewProvider {
    static var previews: some View {
        MeaningfulPatternsView()
            .environmentObject(HomeInteractor(transactionListManager: TransactionListManager(), envelopeListManager: EnvelopeListManager()))
    }
}
