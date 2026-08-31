import XCTest
@testable import Keepi

final class EnvelopeCalculationsTests: XCTestCase {
    private var service: DefaultEntryAggregationService!
    private var testDate: Date!
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        service = DefaultEntryAggregationService(calendar: calendar)
        testDate = calendar.date(from: DateComponents(year: 2026, month: 8, day: 15, hour: 12))!
    }

    func testCurrentMonthAggregation() {
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: testDate)!
        let entries = [
            transaction("1", value: 50, envelope: "env1", date: testDate),
            transaction("2", value: -20, envelope: "env1", date: testDate),
            transaction("3", value: 100, envelope: "env1", date: nextMonth),
            transaction("4", value: 30, envelope: "env2", date: testDate)
        ]

        XCTAssertEqual(service.total(entries: entries, envelopeID: "env1", period: .month(testDate)), 70)
    }

    func testIncomeAndTransfersDoNotInflateSpending() {
        let entries = [
            transaction("1", value: 50, envelope: "env1", date: testDate, type: .expense),
            transaction("2", value: 50, envelope: "env1", date: testDate, type: .income),
            transaction("3", value: 20, envelope: "env1", date: testDate, type: .transfer)
        ]

        XCTAssertEqual(service.total(entries: entries, envelopeID: "env1", period: .allTime), 50)
        XCTAssertEqual(service.entries(from: entries, envelopeID: "env1", period: .allTime).count, 3)
    }

    func testMonthBoundaryBehavior() {
        let start = calendar.date(from: DateComponents(year: 2026, month: 8, day: 1))!
        let previous = calendar.date(byAdding: .second, value: -1, to: start)!
        let entries = [
            transaction("1", value: 50, envelope: "env1", date: previous),
            transaction("2", value: 20, envelope: "env1", date: start)
        ]

        XCTAssertEqual(service.total(entries: entries, envelopeID: "env1", period: .month(previous)), 50)
        XCTAssertEqual(service.total(entries: entries, envelopeID: "env1", period: .month(start)), 20)
    }

    private func transaction(_ id: String, value: Decimal, envelope: String, date: Date, type: TransactionType = .expense) -> TransactionModel {
        TransactionModel(id: id, name: id, value: value, envelopeId: envelope, date: date, type: type)
    }
}
