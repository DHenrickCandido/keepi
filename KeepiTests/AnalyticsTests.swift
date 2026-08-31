import XCTest
@testable import Keepi

final class AnalyticsTests: XCTestCase {
    func testIntentAnalyticsGeneration() {
        let entries = [
            transaction("1", value: 50, envelope: "food", feeling: 3, intent: .impulsive),
            transaction("2", value: 30, envelope: "food", feeling: 3, intent: .impulsive),
            transaction("3", value: 20, envelope: "transport", feeling: 2, intent: .planned),
            transaction("4", value: 10, envelope: "transport", feeling: 0, intent: .planned),
            transaction("5", value: 5, envelope: "food", feeling: 2, intent: .unsure)
        ]
        let analytics = IntentAnalyticsEngine.generateAnalytics(from: entries, envelopes: [envelope("food", "Food"), envelope("transport", "Transport")])

        XCTAssertTrue(analytics.hasEnoughData)
        XCTAssertEqual(metric(.planned, in: analytics)?.totalSpent, 30)
        XCTAssertEqual(metric(.planned, in: analytics)?.count, 2)
        XCTAssertEqual(metric(.impulsive, in: analytics)?.totalSpent, 80)
        XCTAssertEqual(metric(.unsure, in: analytics)?.averageSpent, 5)
        XCTAssertEqual(analytics.impulsiveEnvelopes.first(where: { $0.envelopeId == "food" })?.totalSpent, 80)
    }

    func testEmotionalAnalyticsGeneration() {
        let entries = [
            transaction("1", value: 100, envelope: "food", feeling: 0, intent: .planned),
            transaction("2", value: 40, envelope: "food", feeling: 0, intent: .planned),
            transaction("3", value: 10, envelope: "food", feeling: 2, intent: .unsure),
            transaction("4", value: 20, envelope: "food", feeling: 3, intent: .impulsive),
            transaction("5", value: 30, envelope: "food", feeling: 3, intent: .impulsive)
        ]
        let analytics = EmotionalAnalyticsEngine.generateAnalytics(from: entries, envelopes: [envelope("food", "Food")])

        XCTAssertTrue(analytics.hasEnoughData)
        XCTAssertEqual(feeling(0, in: analytics)?.totalSpent, 140)
        XCTAssertEqual(feeling(0, in: analytics)?.count, 2)
        XCTAssertEqual(feeling(2, in: analytics)?.totalSpent, 10)
        XCTAssertEqual(feeling(3, in: analytics)?.averageSpent, 25)
        XCTAssertEqual(analytics.topEnvelopesMatrix.first?.feelingCounts[0], 2)
    }

    private func metric(_ intent: SpendingIntent, in analytics: IntentAnalytics) -> IntentMetric? {
        analytics.metrics.first { $0.intent == intent }
    }

    private func feeling(_ index: Int, in analytics: EmotionalAnalytics) -> FeelingMetric? {
        analytics.spendingByFeeling.first { $0.feelingIndex == index }
    }

    private func envelope(_ id: String, _ name: String) -> Envelope {
        Envelope(id: id, name: name, icon: "img1", monthlyBudget: nil, createdAt: .now, updatedAt: .now)
    }

    private func transaction(_ id: String, value: Decimal, envelope: String, feeling: Int, intent: SpendingIntent) -> TransactionModel {
        TransactionModel(id: id, name: id, value: value, envelopeId: envelope, feeling: feeling, reflectionCompleted: true, spendingIntent: intent, type: .expense)
    }
}
