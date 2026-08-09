import Foundation

struct EnvelopeSummary: Identifiable {
    let id = UUID()
    let envelopeID: String
    let envelopeName: String
    let amount: Decimal
    let transactionCount: Int
}

struct IntentSummary: Identifiable {
    let id = UUID()
    let intent: SpendingIntent
    let amount: Decimal
    let count: Int
}

struct FeelingSummary: Identifiable {
    let id = UUID()
    let feeling: Int // 0, 1, 2, 3, 4
    let amount: Decimal
    let count: Int
}

struct ReflectionObservation: Identifiable {
    let id = UUID()
    let text: String
    let highlight: String? 
}

struct WeeklyReflection {
    let startDate: Date
    let endDate: Date

    let totalSpent: Decimal
    let transactionCount: Int
    let reflectedCount: Int

    let envelopeBreakdown: [EnvelopeSummary]
    let feelingBreakdown: [FeelingSummary]
    let intentBreakdown: [IntentSummary]

    let topMerchants: [(name: String, amount: Decimal)]

    let observations: [ReflectionObservation]
}
