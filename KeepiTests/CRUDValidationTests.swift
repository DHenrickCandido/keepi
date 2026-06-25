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

    @Test func envelopeIdTrimsWhitespaceAndRemovesSpaces() {
        #expect(CRUDValidation.envelopeId(from: " Food Budget ") == "FoodBudget")
        #expect(CRUDValidation.envelopeId(from: "   ") == nil)
    }

    @Test func cannotDeleteEnvelopeWithExistingTrades() {
        let trade = TradeModel(id: "1", name: "Tea", value: 10, tag: [], envelopeId: "food")
        #expect(CRUDValidation.canDeleteEnvelope(envelopeId: "food", trades: [trade]) == false)
        #expect(CRUDValidation.canDeleteEnvelope(envelopeId: "travel", trades: [trade]) == true)
    }

    @Test func entriesWithoutEnvelopeDoNotBlockEnvelopeDeletion() {
        let trade = TradeModel(id: "1", name: "Tea", value: 10, tag: [], envelopeId: "")
        #expect(CRUDValidation.canDeleteEnvelope(envelopeId: "food", trades: [trade]) == true)
    }

    @Test func tradeDataPreservesEmptyEnvelopeId() {
        let trade = TradeModel(id: "1", name: "Tea", value: 10, tag: [], envelopeId: "")
        let data = TradeListManager.makeTradeData(from: trade)
        #expect(data["envelopeId"] as? String == "")
    }

    @Test func firestoreParserHandlesCommonNumericTypes() {
        #expect(FirestoreValueParser.floatValue(from: Float(1.25)) == 1.25)
        #expect(FirestoreValueParser.floatValue(from: Double(2.5)) == 2.5)
        #expect(FirestoreValueParser.floatValue(from: 3) == 3)
        #expect(FirestoreValueParser.floatValue(from: "4,75") == 4.75)
        #expect(FirestoreValueParser.floatValue(from: nil) == 0)
    }
}
