import XCTest
@testable import Keepi

final class CSVParserTests: XCTestCase {
    
    func testCommaDelimiter() {
        let csv = """
        Date,Title,Amount
        2026-08-01,Uber,-15.50
        2026-08-02,Lunch,-20.00
        """
        
        let delimiter = CSVParser.detectDelimiter(in: csv)
        XCTAssertEqual(delimiter, ",")
        
        let dicts = CSVParser.parseToDictionaries(content: csv)
        XCTAssertEqual(dicts.count, 2)
        XCTAssertEqual(dicts[0]["Title"], "Uber")
        XCTAssertEqual(dicts[1]["Amount"], "-20.00")
    }
    
    func testSemicolonDelimiter() {
        let csv = """
        Date;Title;Amount
        2026-08-01;Uber;-15,50
        2026-08-02;Lunch;-20,00
        """
        
        let delimiter = CSVParser.detectDelimiter(in: csv)
        XCTAssertEqual(delimiter, ";")
        
        let dicts = CSVParser.parseToDictionaries(content: csv)
        XCTAssertEqual(dicts.count, 2)
        XCTAssertEqual(dicts[0]["Title"], "Uber")
        XCTAssertEqual(dicts[1]["Amount"], "-20,00")
    }
    
    func testQuotesAndCommasInsideQuotes() {
        let csv = "Date,Title,Amount\n2026-08-01,\"Uber, Trip\",-15.50\n2026-08-02,\"Lunch \"\"Special\"\"\",-20.00"
        
        let dicts = CSVParser.parseToDictionaries(content: csv)
        XCTAssertEqual(dicts.count, 2)
        XCTAssertEqual(dicts[0]["Title"], "Uber, Trip")
        XCTAssertEqual(dicts[1]["Title"], "Lunch \"Special\"")
    }
    
    func testEmptyColumns() {
        let csv = "Date,Title,Category,Amount\n2026-08-01,Uber,,-15.50\n2026-08-02,,Food,-20.00"
        
        let dicts = CSVParser.parseToDictionaries(content: csv)
        XCTAssertEqual(dicts.count, 2)
        XCTAssertEqual(dicts[0]["Category"], "")
        XCTAssertEqual(dicts[1]["Title"], "")
    }
    
    func testCRLF() {
        let csv = "Date,Title,Amount\r\n2026-08-01,Uber,-15.50\r\n2026-08-02,Lunch,-20.00"
        
        let dicts = CSVParser.parseToDictionaries(content: csv)
        XCTAssertEqual(dicts.count, 2)
        XCTAssertEqual(dicts[0]["Title"], "Uber")
    }
    
    func testInvalidRows() {
        let csv = "Date,Title,Amount\n2026-08-01,Uber,-15.50\nInvalid Row Missing Columns\n2026-08-02,Lunch,-20.00"
        
        let dicts = CSVParser.parseToDictionaries(content: csv)
        // Should parse 2 valid rows, skipping the invalid one or truncating it
        // Depending on parser logic, it might produce an incomplete dict for the invalid row
        // But let's check that the valid rows are correctly mapped.
        XCTAssertEqual(dicts[0]["Title"], "Uber")
        XCTAssertEqual(dicts.last?["Title"], "Lunch")
    }
}
