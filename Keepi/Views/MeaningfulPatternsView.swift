import SwiftUI

struct MeaningfulPatternsView: View {
    @EnvironmentObject var interactor: HomeInteractor
    let transactions: [TransactionModel]

    var body: some View {
        let patterns = generatePatterns(list: transactions)

        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("KEEPI NOTICED")
                        .font(.caption2.bold())
                        .tracking(1.3)
                        .foregroundColor(Color("darkGreenKeepi"))
                    Text("A pattern worth a pause")
                        .font(.title2.bold())
                        .foregroundColor(Color("blackKeepi"))
                }
                Spacer()
                Image(systemName: "sparkles")
                    .font(.headline)
                    .foregroundColor(Color("darkGreenKeepi"))
                    .frame(width: 40, height: 40)
                    .background(.white.opacity(0.6), in: Circle())
            }

            if transactions.isEmpty {
                Text("Add entries to discover meaningful patterns about your spending.")
                    .font(.subheadline)
                    .foregroundColor(Color(.systemGray))
            } else if patterns.isEmpty {
                Text("Keep adding and reflecting on entries. We need a bit more data to find clear patterns.")
                    .font(.subheadline)
                    .foregroundColor(Color(.systemGray))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(patterns.enumerated()), id: \.element) { index, pattern in
                        insightRow(
                            title: pattern,
                            number: index + 1
                        )
                        if index < patterns.count - 1 {
                            Rectangle()
                                .fill(Color("darkGreenKeepi").opacity(0.10))
                                .frame(height: 1)
                                .padding(.leading, 42)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color("lightGreenKeepi").opacity(0.28), Color("lightGreenKeepi").opacity(0.10)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundColor(Color(.systemGray))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func insightRow(title: String, number: Int) -> some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.caption.bold())
                .foregroundColor(Color("darkGreenKeepi"))
                .frame(width: 28, height: 28)
                .background(.white.opacity(0.7))
                .clipShape(Circle())

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color("blackKeepi"))
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(.vertical, 12)
    }
}

private func generatePatterns(list: [TransactionModel]) -> [String] {
    var patterns: [String] = []
    let expenses = list.filter { $0.type == .expense }
    
    // Pattern 1: Unplanned and regretted purchases
    let unplanned = expenses.filter { $0.spendingIntent == .impulsive }
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
    for t in expenses {
        spendingByFeeling[t.feeling, default: 0] += t.spendingAmount
    }
    
    if let highestFeelingIndex = spendingByFeeling.max(by: { $0.value < $1.value })?.key {
        if let feelingName = FeelingList.getFeelings().first(where: { $0.index == highestFeelingIndex })?.name.lowercased() {
            patterns.append("You spend the most when you feel \(feelingName).")
        }
    }
    
    // Pattern 3: Most regretted feeling
    let reflected = expenses.filter { $0.worthIt != nil }
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
    if patterns.isEmpty && !expenses.isEmpty {
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
        MeaningfulPatternsView(transactions: [])
            .environmentObject(HomeInteractor(transactionListManager: TransactionListManager(), envelopeListManager: EnvelopeListManager()))
    }
}
