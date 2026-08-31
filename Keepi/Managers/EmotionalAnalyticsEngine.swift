import Foundation

struct FeelingMetric: Identifiable {
    let id = UUID()
    let feelingIndex: Int
    let totalSpent: Decimal
    let count: Int
    var averageSpent: Decimal {
        return count > 0 ? totalSpent / Decimal(count) : 0
    }
}

struct EnvelopeFeelingMatrix: Identifiable {
    let id = UUID()
    let envelopeId: String
    let envelopeName: String
    let feelingCounts: [Int: Int] // feelingIndex: count
}

struct MonthlyFeelingTrend: Identifiable {
    let id = UUID()
    let feelingIndex: Int
    let previousMonthCount: Int
    let currentMonthCount: Int
    let previousMonthName: String
    let currentMonthName: String
}

struct EmotionalAnalytics {
    let hasEnoughData: Bool
    let totalReflectedCount: Int
    let spendingByFeeling: [FeelingMetric]
    let topEnvelopesMatrix: [EnvelopeFeelingMatrix]
    let monthlyTrends: [MonthlyFeelingTrend]
}

class EmotionalAnalyticsEngine {
    
    static let minimumReflectionThreshold = 5
    
    static func generateAnalytics(
        from transactions: [TransactionModel],
        envelopes: [Envelope]
    ) -> EmotionalAnalytics {
        
        let reflectedTransactions = transactions.filter { $0.reflectionCompleted && $0.type == .expense }
        let totalReflectedCount = reflectedTransactions.count
        
        if totalReflectedCount < minimumReflectionThreshold {
            return EmotionalAnalytics(
                hasEnoughData: false,
                totalReflectedCount: totalReflectedCount,
                spendingByFeeling: [],
                topEnvelopesMatrix: [],
                monthlyTrends: []
            )
        }
        
        // 1. Spending by feeling
        var feelingMap: [Int: (amount: Decimal, count: Int)] = [:]
        for tx in reflectedTransactions {
            feelingMap[tx.feeling, default: (0, 0)].amount += tx.spendingAmount
            feelingMap[tx.feeling, default: (0, 0)].count += 1
        }
        
        let spendingByFeeling = feelingMap.map { key, value in
            FeelingMetric(feelingIndex: key, totalSpent: value.amount, count: value.count)
        }.sorted { $0.count > $1.count }
        
        // 2. Envelope × Feeling Matrix (Top 5 envelopes by count)
        var envelopeFeelingMap: [String: [Int: Int]] = [:]
        var envelopeTotalCounts: [String: Int] = [:]
        
        for tx in reflectedTransactions {
            envelopeFeelingMap[tx.envelopeId, default: [:]][tx.feeling, default: 0] += 1
            envelopeTotalCounts[tx.envelopeId, default: 0] += 1
        }
        
        let topEnvelopes = envelopeTotalCounts.sorted { $0.value > $1.value }.prefix(5)
        
        let topEnvelopesMatrix = topEnvelopes.map { kv in
            EnvelopeFeelingMatrix(
                envelopeId: kv.key,
                envelopeName: envelopes.first(where: { $0.id == kv.key })?.name ?? "Unknown",
                feelingCounts: envelopeFeelingMap[kv.key] ?? [:]
            )
        }
        
        // 3. Monthly Change (Regret -> feeling 3)
        var monthlyTrends: [MonthlyFeelingTrend] = []
        let now = Date()
        let calendar = Calendar.current
        
        // Determine start/end of current month and previous month
        if let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
           let startOfPreviousMonth = calendar.date(byAdding: .month, value: -1, to: startOfCurrentMonth),
           let endOfPreviousMonth = calendar.date(byAdding: .day, value: -1, to: startOfCurrentMonth) {
            
            let previousMonthName = calendar.monthSymbols[calendar.component(.month, from: startOfPreviousMonth) - 1]
            let currentMonthName = calendar.monthSymbols[calendar.component(.month, from: startOfCurrentMonth) - 1]
            
            // We'll track feeling == 3 (Regret)
            let regretCurrent = reflectedTransactions.filter { $0.feeling == 3 && $0.date >= startOfCurrentMonth }.count
            let regretPrevious = reflectedTransactions.filter { $0.feeling == 3 && $0.date >= startOfPreviousMonth && $0.date <= endOfPreviousMonth }.count
            
            if regretCurrent > 0 || regretPrevious > 0 {
                monthlyTrends.append(MonthlyFeelingTrend(
                    feelingIndex: 3,
                    previousMonthCount: regretPrevious,
                    currentMonthCount: regretCurrent,
                    previousMonthName: previousMonthName,
                    currentMonthName: currentMonthName
                ))
            }
        }
        
        return EmotionalAnalytics(
            hasEnoughData: true,
            totalReflectedCount: totalReflectedCount,
            spendingByFeeling: spendingByFeeling,
            topEnvelopesMatrix: topEnvelopesMatrix,
            monthlyTrends: monthlyTrends
        )
    }
}
