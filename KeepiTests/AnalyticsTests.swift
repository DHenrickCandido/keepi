import XCTest
@testable import Keepi

final class AnalyticsTests: XCTestCase {
    
    func testIntentAnalyticsGeneration() {
        let env1 = Envelope(id: "env1", name: "Food", amount: 0, budget: nil, color: "000000", isDeleted: false)
        let env2 = Envelope(id: "env2", name: "Transport", amount: 0, budget: nil, color: "000000", isDeleted: false)
        
        // 5 valid intent transactions to bypass the 5-transaction minimum
        let tx1 = TransactionModel(id: "1", name: "McDonalds", value: -50, date: Date(), idEnvelope: "env1", intent: .impulsive, feeling: .regret, isReflected: true)
        let tx2 = TransactionModel(id: "2", name: "McDonalds", value: -30, date: Date(), idEnvelope: "env1", intent: .impulsive, feeling: .regret, isReflected: true)
        let tx3 = TransactionModel(id: "3", name: "Uber", value: -20, date: Date(), idEnvelope: "env2", intent: .planned, feeling: .neutral, isReflected: true)
        let tx4 = TransactionModel(id: "4", name: "Bus", value: -10, date: Date(), idEnvelope: "env2", intent: .planned, feeling: .good, isReflected: true)
        let tx5 = TransactionModel(id: "5", name: "Snack", value: -5, date: Date(), idEnvelope: "env1", intent: .unsure, feeling: .neutral, isReflected: true)
        
        let analytics = IntentAnalyticsEngine.generateAnalytics(from: [tx1, tx2, tx3, tx4, tx5], envelopes: [env1, env2])
        
        XCTAssertTrue(analytics.hasEnoughData)
        XCTAssertEqual(analytics.plannedTotal, 30) // 20 + 10
        XCTAssertEqual(analytics.impulsiveTotal, 80) // 50 + 30
        XCTAssertEqual(analytics.unsureTotal, 5)
        
        XCTAssertEqual(analytics.plannedCount, 2)
        XCTAssertEqual(analytics.impulsiveCount, 2)
        XCTAssertEqual(analytics.unsureCount, 1)
        
        XCTAssertEqual(analytics.averagePlanned, 15) // 30 / 2
        XCTAssertEqual(analytics.averageImpulsive, 40) // 80 / 2
        XCTAssertEqual(analytics.averageUnsure, 5) // 5 / 1
        
        let foodImpulsive = analytics.impulsiveByEnvelope.first { $0.envelope.id == "env1" }
        XCTAssertNotNil(foodImpulsive)
        XCTAssertEqual(foodImpulsive?.total, 80)
    }
    
    func testEmotionalAnalyticsGeneration() {
        let env1 = Envelope(id: "env1", name: "Food", amount: 0, budget: nil, color: "000000", isDeleted: false)
        
        let tx1 = TransactionModel(id: "1", name: "Dinner", value: -100, date: Date(), idEnvelope: "env1", intent: .planned, feeling: .good, isReflected: true)
        let tx2 = TransactionModel(id: "2", name: "Lunch", value: -40, date: Date(), idEnvelope: "env1", intent: .planned, feeling: .good, isReflected: true)
        let tx3 = TransactionModel(id: "3", name: "Snack", value: -10, date: Date(), idEnvelope: "env1", intent: .unsure, feeling: .neutral, isReflected: true)
        let tx4 = TransactionModel(id: "4", name: "Junk Food", value: -20, date: Date(), idEnvelope: "env1", intent: .impulsive, feeling: .regret, isReflected: true)
        let tx5 = TransactionModel(id: "5", name: "Junk Food 2", value: -30, date: Date(), idEnvelope: "env1", intent: .impulsive, feeling: .regret, isReflected: true)
        
        let analytics = EmotionalAnalyticsEngine.generateAnalytics(from: [tx1, tx2, tx3, tx4, tx5], envelopes: [env1])
        
        XCTAssertTrue(analytics.hasEnoughData)
        XCTAssertEqual(analytics.goodTotal, 140) // 100 + 40
        XCTAssertEqual(analytics.neutralTotal, 10)
        XCTAssertEqual(analytics.regretTotal, 50) // 20 + 30
        
        XCTAssertEqual(analytics.goodCount, 2)
        XCTAssertEqual(analytics.neutralCount, 1)
        XCTAssertEqual(analytics.regretCount, 2)
        
        XCTAssertEqual(analytics.averageGood, 70) // 140 / 2
        XCTAssertEqual(analytics.averageNeutral, 10) // 10 / 1
        XCTAssertEqual(analytics.averageRegret, 25) // 50 / 2
        
        let foodGoodCount = analytics.envelopeBreakdown.first { $0.envelope.id == "env1" }?.goodCount
        XCTAssertEqual(foodGoodCount, 2)
    }
}
