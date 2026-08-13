import XCTest
@testable import Keepi

final class EnvelopeCalculationsTests: XCTestCase {
    
    private var service: EntryAggregationService!
    private var testDate: Date!
    
    override func setUp() {
        super.setUp()
        service = EntryAggregationService()
        // Set a fixed date for reliable testing: 2026-08-15 12:00:00 UTC
        var components = DateComponents()
        components.year = 2026
        components.month = 8
        components.day = 15
        components.hour = 12
        testDate = Calendar.current.date(from: components)!
    }
    
    override func tearDown() {
        service = nil
        testDate = nil
        super.tearDown()
    }
    
    func testCurrentMonthAggregation() {
        let env1 = "env1"
        let env2 = "env2"
        
        let tx1 = TransactionModel(id: "1", name: "Lunch", value: -50, date: testDate, idEnvelope: env1)
        let tx2 = TransactionModel(id: "2", name: "Uber", value: -20, date: testDate, idEnvelope: env1)
        
        // Next month
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: testDate)!
        let tx3 = TransactionModel(id: "3", name: "Dinner", value: -100, date: nextMonth, idEnvelope: env1)
        
        // Different envelope
        let tx4 = TransactionModel(id: "4", name: "Movie", value: -30, date: testDate, idEnvelope: env2)
        
        let transactions = [tx1, tx2, tx3, tx4]
        
        let total = service.total(forEnvelopeId: env1, in: transactions, period: .month(testDate))
        
        // Only tx1 and tx2 should be counted. (-50 + -20) = -70.
        XCTAssertEqual(total, -70)
    }
    
    func testIncomeDoesNotInflateSpending() {
        let env1 = "env1"
        
        let tx1 = TransactionModel(id: "1", name: "Lunch", value: -50, date: testDate, idEnvelope: env1)
        let tx2 = TransactionModel(id: "2", name: "Refund", value: 50, date: testDate, idEnvelope: env1) // Income/Refund
        let tx3 = TransactionModel(id: "3", name: "Uber", value: -20, date: testDate, idEnvelope: env1)
        
        let transactions = [tx1, tx2, tx3]
        
        let total = service.total(forEnvelopeId: env1, in: transactions, period: .allTime)
        
        // Since spending is negative, summing them gives the net total.
        // -50 + 50 - 20 = -20
        XCTAssertEqual(total, -20)
    }
    
    func testBoundaryBehavior() {
        let env1 = "env1"
        
        // Last second of previous month
        var comp1 = Calendar.current.dateComponents([.year, .month], from: testDate)
        comp1.second = -1
        let endOfPrevMonth = Calendar.current.date(from: comp1)!
        
        // First second of current month
        let startOfCurrentMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: testDate))!
        
        let tx1 = TransactionModel(id: "1", name: "Prev Month", value: -50, date: endOfPrevMonth, idEnvelope: env1)
        let tx2 = TransactionModel(id: "2", name: "Current Month", value: -20, date: startOfCurrentMonth, idEnvelope: env1)
        
        let transactions = [tx1, tx2]
        
        let prevMonthTotal = service.total(forEnvelopeId: env1, in: transactions, period: .month(endOfPrevMonth))
        let currMonthTotal = service.total(forEnvelopeId: env1, in: transactions, period: .month(startOfCurrentMonth))
        
        XCTAssertEqual(prevMonthTotal, -50)
        XCTAssertEqual(currMonthTotal, -20)
    }
}
