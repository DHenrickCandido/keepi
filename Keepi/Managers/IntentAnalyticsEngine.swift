import Foundation

struct IntentMetric: Identifiable {
    let id = UUID()
    let intent: SpendingIntent
    let totalSpent: Decimal
    let count: Int
    var averageSpent: Decimal {
        return count > 0 ? totalSpent / Decimal(count) : 0
    }
}

struct IntentEnvelopeMetric: Identifiable {
    let id = UUID()
    let envelopeId: String
    let envelopeName: String
    let totalSpent: Decimal
}

struct IntentMonthlyTrend: Identifiable {
    let id = UUID()
    let intent: SpendingIntent
    let previousMonthCount: Int
    let previousMonthSpent: Decimal
    let currentMonthCount: Int
    let currentMonthSpent: Decimal
    let previousMonthName: String
    let currentMonthName: String
}

struct IntentAnalytics {
    let hasEnoughData: Bool
    let totalReflectedCount: Int
    let metrics: [IntentMetric]
    let impulsiveEnvelopes: [IntentEnvelopeMetric]
    let monthlyTrends: [IntentMonthlyTrend]
}

class IntentAnalyticsEngine {
    
    static let minimumReflectionThreshold = 5
    
    static func generateAnalytics(
        from transactions: [TransactionModel],
        envelopes: [Envelope]
    ) -> IntentAnalytics {
        
        // Filter for transactions that have an intent set and are expenses
        let intentTransactions = transactions.filter { $0.spendingIntent != nil && $0.type == .expense }
        let totalReflectedCount = intentTransactions.count
        
        if totalReflectedCount < minimumReflectionThreshold {
            return IntentAnalytics(
                hasEnoughData: false,
                totalReflectedCount: totalReflectedCount,
                metrics: [],
                impulsiveEnvelopes: [],
                monthlyTrends: []
            )
        }
        
        // 1. Amount distribution, counts, averages
        var intentMap: [SpendingIntent: (amount: Decimal, count: Int)] = [
            .planned: (0, 0),
            .impulsive: (0, 0),
            .unsure: (0, 0)
        ]
        
        for tx in intentTransactions {
            if let intent = tx.spendingIntent {
                intentMap[intent]?.amount += tx.value
                intentMap[intent]?.count += 1
            }
        }
        
        let metrics = [SpendingIntent.planned, SpendingIntent.impulsive, SpendingIntent.unsure].compactMap { intent -> IntentMetric? in
            guard let stats = intentMap[intent] else { return nil }
            return IntentMetric(intent: intent, totalSpent: stats.amount, count: stats.count)
        }
        
        // 2. Envelope breakdown (Impulsive spending)
        let impulsiveTx = intentTransactions.filter { $0.spendingIntent == .impulsive }
        var envelopeMap: [String: Decimal] = [:]
        
        for tx in impulsiveTx {
            envelopeMap[tx.envelopeId, default: 0] += tx.value
        }
        
        var impulsiveEnvelopes = envelopeMap.map { kv in
            IntentEnvelopeMetric(
                envelopeId: kv.key,
                envelopeName: envelopes.first(where: { $0.id == kv.key })?.name ?? "Unknown",
                totalSpent: kv.value
            )
        }.sorted { $0.totalSpent > $1.totalSpent }
        
        // If there are many, we could group the rest into "Other", but for now we take the top 5
        if impulsiveEnvelopes.count > 5 {
            let top4 = Array(impulsiveEnvelopes.prefix(4))
            let rest = impulsiveEnvelopes.dropFirst(4)
            let otherTotal = rest.reduce(Decimal(0)) { $0 + $1.totalSpent }
            var grouped = top4
            grouped.append(IntentEnvelopeMetric(envelopeId: "other", envelopeName: "Other", totalSpent: otherTotal))
            impulsiveEnvelopes = grouped
        }
        
        // 3. Time comparison (This month vs Last month)
        var monthlyTrends: [IntentMonthlyTrend] = []
        let now = Date()
        let calendar = Calendar.current
        
        if let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
           let startOfPreviousMonth = calendar.date(byAdding: .month, value: -1, to: startOfCurrentMonth),
           let endOfPreviousMonth = calendar.date(byAdding: .day, value: -1, to: startOfCurrentMonth) {
            
            let previousMonthName = calendar.monthSymbols[calendar.component(.month, from: startOfPreviousMonth) - 1]
            let currentMonthName = calendar.monthSymbols[calendar.component(.month, from: startOfCurrentMonth) - 1]
            
            let intentsToCompare: [SpendingIntent] = [.planned, .impulsive]
            
            for intent in intentsToCompare {
                let currentTx = intentTransactions.filter { $0.spendingIntent == intent && $0.date >= startOfCurrentMonth }
                let previousTx = intentTransactions.filter { $0.spendingIntent == intent && $0.date >= startOfPreviousMonth && $0.date <= endOfPreviousMonth }
                
                let currentTotal = currentTx.reduce(Decimal(0)) { $0 + $1.value }
                let previousTotal = previousTx.reduce(Decimal(0)) { $0 + $1.value }
                
                if currentTx.count > 0 || previousTx.count > 0 {
                    monthlyTrends.append(IntentMonthlyTrend(
                        intent: intent,
                        previousMonthCount: previousTx.count,
                        previousMonthSpent: previousTotal,
                        currentMonthCount: currentTx.count,
                        currentMonthSpent: currentTotal,
                        previousMonthName: previousMonthName,
                        currentMonthName: currentMonthName
                    ))
                }
            }
        }
        
        return IntentAnalytics(
            hasEnoughData: true,
            totalReflectedCount: totalReflectedCount,
            metrics: metrics,
            impulsiveEnvelopes: impulsiveEnvelopes,
            monthlyTrends: monthlyTrends
        )
    }
}
