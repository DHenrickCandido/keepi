import Foundation
import Testing
@testable import Keepi

struct CRUDValidationTests {
    @Test func decimalParsingAcceptsDotAndComma() {
        #expect(CRUDValidation.normalizedDecimal("10.50") == 10.5)
        #expect(CRUDValidation.normalizedDecimal("10,50") == 10.5)
    }

    @Test func decimalParsingRejectsEmptyZeroAndNegativeValues() {
        #expect(CRUDValidation.normalizedDecimal("") == nil)
        #expect(CRUDValidation.normalizedDecimal("0") == nil)
        #expect(CRUDValidation.normalizedDecimal("-1") == nil)
    }

    @Test func moneyRoundsToCurrencyPrecision() {
        #expect(CRUDValidation.normalizedDecimal("10.555") == Decimal(string: "10.56"))
        #expect(Money.rounded(Decimal(string: "0.1")! + Decimal(string: "0.2")!) == Decimal(string: "0.3"))
    }

    @Test func generatedTradeIdsDoNotCollide() {
        #expect(TradeIdentity.make() != TradeIdentity.make())
    }

    @Test func widgetSnapshotExpiresAfterCalendarDayChanges() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let updatedAt = Date(timeIntervalSince1970: 1_700_000_000)
        let sameDay = updatedAt.addingTimeInterval(60)
        let nextDay = updatedAt.addingTimeInterval(86_400)

        #expect(DailyWidgetDataStore.isCurrentDay(updatedAt, now: sameDay, calendar: calendar))
        #expect(!DailyWidgetDataStore.isCurrentDay(updatedAt, now: nextDay, calendar: calendar))
        #expect(!DailyWidgetDataStore.isCurrentDay(nil, now: sameDay, calendar: calendar))
    }

    @Test func envelopeIdTrimsWhitespaceAndRemovesSpaces() {
        #expect(CRUDValidation.envelopeId(from: " Food Budget ") == "FoodBudget")
        #expect(CRUDValidation.envelopeId(from: "   ") == nil)
    }

    @Test func cannotDeleteEnvelopeWithExistingTrades() {
        let trade = TransactionModel(id: "1", name: "Tea", value: 10, envelopeId: "food")
        #expect(CRUDValidation.canDeleteEnvelope(envelopeId: "food", trades: [trade]) == false)
        #expect(CRUDValidation.canDeleteEnvelope(envelopeId: "travel", trades: [trade]) == true)
    }

    @Test func entriesWithoutEnvelopeDoNotBlockEnvelopeDeletion() {
        let trade = TransactionModel(id: "1", name: "Tea", value: 10, envelopeId: "")
        #expect(CRUDValidation.canDeleteEnvelope(envelopeId: "food", trades: [trade]) == true)
    }

    @Test func tradeDataPreservesEmptyEnvelopeId() {
        let trade = TransactionModel(id: "1", name: "Tea", value: 10, envelopeId: "")
        let data = TransactionListManager.makeTransactionData(from: trade)
        #expect(data["envelopeId"] as? String == "")
    }

    @Test func firestoreParserHandlesCommonNumericTypes() {
        #expect(FirestoreValueParser.decimalValue(from: Float(1.25)) == Decimal(string: "1.25"))
        #expect(FirestoreValueParser.decimalValue(from: Double(2.5)) == Decimal(string: "2.5"))
        #expect(FirestoreValueParser.decimalValue(from: 3) == 3)
        #expect(FirestoreValueParser.decimalValue(from: "4,75") == Decimal(string: "4.75"))
        #expect(FirestoreValueParser.decimalValue(from: nil) == 0)
    }
}
