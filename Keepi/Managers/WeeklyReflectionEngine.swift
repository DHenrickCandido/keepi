import Foundation

class WeeklyReflectionEngine {
    
    static func generateReflection(
        for entries: [TransactionModel],
        unreviewedDraftsCount: Int,
        envelopes: [Envelope],
        now: Date = Date(),
        calendar baseCalendar: Calendar = .current
    ) -> WeeklyReflection? {

        var calendar = baseCalendar
        calendar.firstWeekday = 1 // Sunday
        
        // Find previous completed week (Sunday to Saturday)
        guard let startOfThisWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
              let startOfLastWeek = calendar.date(byAdding: .day, value: -7, to: startOfThisWeek) else {
            return nil
        }
        
        let weekEntries = entries.filter { $0.date >= startOfLastWeek && $0.date < startOfThisWeek && $0.type == .expense }
        
        guard !weekEntries.isEmpty else { return nil }
        
        let totalSpent = weekEntries.reduce(Decimal(0)) { $0 + $1.spendingAmount }
        let transactionCount = weekEntries.count
        let reflectedCount = weekEntries.filter { $0.reflectionCompleted }.count
        
        // Breakdowns
        var envelopeMap: [String: (amount: Decimal, count: Int)] = [:]
        var feelingMap: [Int: (amount: Decimal, count: Int)] = [:]
        var intentMap: [SpendingIntent: (amount: Decimal, count: Int)] = [:]
        var merchantMap: [String: Decimal] = [:]
        
        for tx in weekEntries {
            envelopeMap[tx.envelopeId, default: (0, 0)].amount += tx.spendingAmount
            envelopeMap[tx.envelopeId, default: (0, 0)].count += 1
            
            feelingMap[tx.feeling, default: (0, 0)].amount += tx.spendingAmount
            feelingMap[tx.feeling, default: (0, 0)].count += 1
            
            if let intent = tx.spendingIntent {
                intentMap[intent, default: (0, 0)].amount += tx.spendingAmount
                intentMap[intent, default: (0, 0)].count += 1
            }
            
            merchantMap[tx.name, default: 0] += tx.spendingAmount
        }
        
        let envelopeBreakdown = envelopeMap.map { key, value in
            EnvelopeSummary(
                envelopeID: key,
                envelopeName: envelopes.first(where: { $0.id == key })?.name ?? "Unknown",
                amount: value.amount,
                transactionCount: value.count
            )
        }.sorted(by: { $0.amount > $1.amount })
        
        let feelingBreakdown = feelingMap.map { key, value in
            FeelingSummary(feeling: key, amount: value.amount, count: value.count)
        }.sorted(by: { $0.amount > $1.amount })
        
        let intentBreakdown = intentMap.map { key, value in
            IntentSummary(intent: key, amount: value.amount, count: value.count)
        }.sorted(by: { $0.amount > $1.amount })
        
        let topMerchants = merchantMap.map { (name: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
            .prefix(5)
            .map { $0 }
        
        // Evaluate Rules
        let context = ReflectionContext(envelopes: envelopes)
        let rules: [ReflectionRule] = [
            HighImpulseEnvelopeRule(),
            MostRegrettedEnvelopeRule(),
            UnreviewedCountRule(unreviewedCount: unreviewedDraftsCount)
        ]
        
        var observations: [ReflectionObservation] = []
        for rule in rules {
            if let obs = rule.evaluate(entries: weekEntries, context: context) {
                observations.append(obs)
            }
        }
        
        return WeeklyReflection(
            startDate: startOfLastWeek,
            endDate: calendar.date(byAdding: .second, value: -1, to: startOfThisWeek) ?? startOfThisWeek,
            totalSpent: totalSpent,
            transactionCount: transactionCount,
            reflectedCount: reflectedCount,
            envelopeBreakdown: envelopeBreakdown,
            feelingBreakdown: feelingBreakdown,
            intentBreakdown: intentBreakdown,
            topMerchants: topMerchants,
            observations: observations
        )
    }
}
