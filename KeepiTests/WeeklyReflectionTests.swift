import XCTest
@testable import Keepi

final class WeeklyReflectionTests: XCTestCase {
    
    func testWeeklyReflectionGeneration() {
        let env1 = Envelope(id: "env1", name: "Food", amount: 0, budget: nil, color: "000000", isDeleted: false)
        let env2 = Envelope(id: "env2", name: "Transport", amount: 0, budget: nil, color: "000000", isDeleted: false)
        
        let tx1 = TransactionModel(id: "1", name: "McDonalds", value: -50, date: Date(), idEnvelope: "env1", intent: .impulsive, feeling: .regret, isReflected: true)
        let tx2 = TransactionModel(id: "2", name: "McDonalds", value: -30, date: Date(), idEnvelope: "env1", intent: .impulsive, feeling: .regret, isReflected: true)
        let tx3 = TransactionModel(id: "3", name: "Uber", value: -20, date: Date(), idEnvelope: "env2", intent: .planned, feeling: .neutral, isReflected: true)
        
        // Unreflected transaction
        let tx4 = TransactionModel(id: "4", name: "Subway", value: -10, date: Date(), idEnvelope: "env1", intent: nil, feeling: nil, isReflected: false)
        
        let reflection = WeeklyReflectionEngine.generateReflection(
            for: [tx1, tx2, tx3, tx4],
            unreviewedDraftsCount: 0,
            envelopes: [env1, env2]
        )
        
        XCTAssertNotNil(reflection)
        
        guard let reflection = reflection else { return }
        
        // Totals
        XCTAssertEqual(reflection.totalSpent, 110) // 50 + 30 + 20 + 10
        XCTAssertEqual(reflection.transactionCount, 4)
        XCTAssertEqual(reflection.reflectedCount, 3)
        XCTAssertEqual(reflection.unreviewedCount, 0)
        
        // Intent totals
        XCTAssertEqual(reflection.plannedTotal, 20)
        XCTAssertEqual(reflection.impulsiveTotal, 80)
        
        // Top Merchants
        XCTAssertEqual(reflection.topMerchants.first?.name, "McDonalds")
        XCTAssertEqual(reflection.topMerchants.first?.total, 80)
        
        // Most Used Envelope
        XCTAssertEqual(reflection.mostUsedEnvelope?.envelope.id, "env1") // 3 transactions
        
        // Highest Spending Envelope
        XCTAssertEqual(reflection.highestSpendingEnvelope?.envelope.id, "env1") // 90 spent
        
        // Most Common Feeling
        XCTAssertEqual(reflection.mostCommonFeeling, .regret)
    }
    
    func testReflectionRules() {
        let env1 = Envelope(id: "env1", name: "Food", amount: 0, budget: nil, color: "000000", isDeleted: false)
        
        let tx1 = TransactionModel(id: "1", name: "McDonalds", value: -50, date: Date(), idEnvelope: "env1", intent: .impulsive, feeling: .regret, isReflected: true)
        let tx2 = TransactionModel(id: "2", name: "Subway", value: -30, date: Date(), idEnvelope: "env1", intent: .impulsive, feeling: .regret, isReflected: true)
        
        let context = ReflectionContext(envelopes: [env1])
        
        let impulsiveRule = TopImpulsiveEnvelopeRule()
        let observation1 = impulsiveRule.evaluate(entries: [tx1, tx2], context: context)
        
        XCTAssertNotNil(observation1)
        XCTAssertTrue(observation1!.text.contains("impulsive"))
        XCTAssertTrue(observation1!.text.contains("Food"))
        
        let regretRule = TopRegretEnvelopeRule()
        let observation2 = regretRule.evaluate(entries: [tx1, tx2], context: context)
        
        XCTAssertNotNil(observation2)
        XCTAssertTrue(observation2!.text.contains("regret"))
        XCTAssertTrue(observation2!.text.contains("Food"))
    }
}
