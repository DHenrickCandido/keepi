import XCTest
@testable import Keepi

final class DateParserTests: XCTestCase {
    
    func testDateDetection() {
        // Test standard ISO
        let dates1 = ["2026-08-01", "2026-12-31"]
        let format1 = DateParserService.detectFormat(from: dates1)
        XCTAssertEqual(format1, "yyyy-MM-dd")
        
        // Test DD/MM/YYYY
        let dates2 = ["15/08/2026", "31/12/2026"]
        let format2 = DateParserService.detectFormat(from: dates2)
        XCTAssertEqual(format2, "dd/MM/yyyy")
        
        // Test MM/DD/YYYY
        let dates3 = ["08/15/2026", "12/31/2026"]
        let format3 = DateParserService.detectFormat(from: dates3)
        XCTAssertEqual(format3, "MM/dd/yyyy")
        
        // Test ambiguous dates - usually defaults to the first matching format when ambiguous,
        // but if mixed, it should refine it.
        let ambiguousDates = ["01/02/2026", "15/02/2026"]
        let formatAmbiguous = DateParserService.detectFormat(from: ambiguousDates)
        XCTAssertEqual(formatAmbiguous, "dd/MM/yyyy")
    }
    
    func testDateParsing() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let dateString = "15/08/2026"
        let parsed = formatter.date(from: dateString)
        XCTAssertNotNil(parsed)
        
        let components = Calendar.current.dateComponents(in: TimeZone(secondsFromGMT: 0)!, from: parsed!)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 8)
        XCTAssertEqual(components.day, 15)
    }
}
