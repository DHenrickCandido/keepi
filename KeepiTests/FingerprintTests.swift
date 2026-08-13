import XCTest
@testable import Keepi

final class FingerprintTests: XCTestCase {
    
    func testFingerprintConsistency() {
        let date = Date(timeIntervalSince1970: 1600000000)
        let amount = Decimal(string: "-45.00")!
        let title = "Uber Trip"
        
        let hash1 = ImportDuplicateDetector.generateFingerprint(date: date, amount: amount, title: title)
        let hash2 = ImportDuplicateDetector.generateFingerprint(date: date, amount: amount, title: title)
        
        XCTAssertEqual(hash1, hash2, "Identical transactions should have the same fingerprint")
    }
    
    func testFingerprintUniqueness() {
        let date = Date(timeIntervalSince1970: 1600000000)
        let amount = Decimal(string: "-45.00")!
        let title = "Uber Trip"
        
        let hash1 = ImportDuplicateDetector.generateFingerprint(date: date, amount: amount, title: title)
        
        // Different title
        let hash2 = ImportDuplicateDetector.generateFingerprint(date: date, amount: amount, title: "Uber Eats")
        XCTAssertNotEqual(hash1, hash2)
        
        // Different amount
        let hash3 = ImportDuplicateDetector.generateFingerprint(date: date, amount: Decimal(string: "-45.01")!, title: title)
        XCTAssertNotEqual(hash1, hash3)
        
        // Different date (by more than a day - wait, fingerprint drops time)
        let differentDate = Date(timeIntervalSince1970: 1600000000 + 86400) // +1 day
        let hash4 = ImportDuplicateDetector.generateFingerprint(date: differentDate, amount: amount, title: title)
        XCTAssertNotEqual(hash1, hash4)
    }
}
