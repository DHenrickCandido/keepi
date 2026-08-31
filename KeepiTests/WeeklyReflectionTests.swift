import XCTest
@testable import Keepi

final class WeeklyReflectionTests: XCTestCase {
    private var calendar: Calendar {
        var value = Calendar(identifier: .gregorian)
        value.timeZone = TimeZone(secondsFromGMT: 0)!
        value.firstWeekday = 1
        return value
    }

    func testWeeklyReflectionIncludesAllOfSaturday() {
        let now = calendar.date(from: DateComponents(year: 2026, month: 8, day: 12, hour: 12))!
        let monday = calendar.date(from: DateComponents(year: 2026, month: 8, day: 3, hour: 12))!
        let saturday = calendar.date(from: DateComponents(year: 2026, month: 8, day: 8, hour: 23, minute: 59))!
        let entries = [
            transaction("1", "McDonalds", 50, monday, "food", .impulsive, 3, true),
            transaction("2", "McDonalds", 30, saturday, "food", .impulsive, 3, true),
            transaction("3", "Uber", 20, monday, "transport", .planned, 2, true),
            transaction("4", "Subway", 10, monday, "food", nil, 2, false)
        ]

        let reflection = WeeklyReflectionEngine.generateReflection(
            for: entries,
            unreviewedDraftsCount: 0,
            envelopes: [envelope("food", "Food"), envelope("transport", "Transport")],
            now: now,
            calendar: calendar
        )

        XCTAssertEqual(reflection?.totalSpent, 110)
        XCTAssertEqual(reflection?.transactionCount, 4)
        XCTAssertEqual(reflection?.reflectedCount, 3)
        XCTAssertEqual(reflection?.topMerchants.first?.name, "McDonalds")
        XCTAssertEqual(reflection?.topMerchants.first?.amount, 80)
        XCTAssertEqual(reflection?.envelopeBreakdown.first?.envelopeID, "food")
    }

    func testReflectionRules() {
        let entries = [
            transaction("1", "McDonalds", 50, .now, "food", .impulsive, 3, true),
            transaction("2", "Subway", 30, .now, "food", .impulsive, 3, true)
        ]
        let context = ReflectionContext(envelopes: [envelope("food", "Food")])

        XCTAssertTrue(HighImpulseEnvelopeRule().evaluate(entries: entries, context: context)?.text.contains("Food") == true)
        XCTAssertTrue(MostRegrettedEnvelopeRule().evaluate(entries: entries, context: context)?.text.contains("regret") == true)
    }

    private func envelope(_ id: String, _ name: String) -> Envelope {
        Envelope(id: id, name: name, icon: "img1", monthlyBudget: nil, createdAt: .now, updatedAt: .now)
    }

    private func transaction(_ id: String, _ name: String, _ value: Decimal, _ date: Date, _ envelope: String, _ intent: SpendingIntent?, _ feeling: Int, _ reflected: Bool) -> TransactionModel {
        TransactionModel(id: id, name: name, value: value, envelopeId: envelope, feeling: feeling, date: date, reflectionCompleted: reflected, spendingIntent: intent, type: .expense)
    }
}
