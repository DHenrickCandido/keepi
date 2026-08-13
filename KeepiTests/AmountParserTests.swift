import XCTest
@testable import Keepi

final class AmountParserTests: XCTestCase {
    
    func testAmountParsing() {
        // Standard formats
        XCTAssertEqual(AmountParserService.parseAmount("123.45"), Decimal(string: "123.45"))
        XCTAssertEqual(AmountParserService.parseAmount("123,45"), Decimal(string: "123.45"))
        
        // Thousands separators
        XCTAssertEqual(AmountParserService.parseAmount("1,234.56"), Decimal(string: "1234.56"))
        XCTAssertEqual(AmountParserService.parseAmount("1.234,56"), Decimal(string: "1234.56"))
        
        // Negative values
        XCTAssertEqual(AmountParserService.parseAmount("-123.45"), Decimal(string: "-123.45"))
        XCTAssertEqual(AmountParserService.parseAmount("-1,234.56"), Decimal(string: "-1234.56"))
        
        // Currency prefixes
        XCTAssertEqual(AmountParserService.parseAmount("-R$123,45"), Decimal(string: "-123.45"))
        XCTAssertEqual(AmountParserService.parseAmount("$123.45"), Decimal(string: "123.45"))
        XCTAssertEqual(AmountParserService.parseAmount("€ 1.234,56"), Decimal(string: "1234.56"))
        
        // Edge cases
        XCTAssertEqual(AmountParserService.parseAmount("0"), Decimal(string: "0"))
        XCTAssertEqual(AmountParserService.parseAmount("0.0"), Decimal(string: "0"))
        XCTAssertNil(AmountParserService.parseAmount("invalid"))
    }
}
