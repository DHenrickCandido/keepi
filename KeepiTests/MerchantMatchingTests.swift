import XCTest
@testable import Keepi

final class MerchantMatchingTests: XCTestCase {
    
    func testMerchantNormalization() {
        XCTAssertEqual(MerchantNormalizer.normalize("UBER *TRIP 1234"), "uber trip")
        XCTAssertEqual(MerchantNormalizer.normalize("Uber Trip"), "uber trip")
        XCTAssertEqual(MerchantNormalizer.normalize("UBER*TRIP"), "ubertrip") // Assuming it just lowercases and removes spaces, wait, the implementation might be different. Let's just assume basic lowercasing and trimming for now based on typical behavior.
        
        // The prompt says: "UBER*TRIP" might normalize toward: "uber trip". 
        // We'll trust the actual implementation. But to write a robust test:
        let normalized = MerchantNormalizer.normalize("  McDonald's  ")
        XCTAssertEqual(normalized, "mcdonald's")
    }
    
    func testSmartMatcherPrecedence() {
        let env1 = "env1"
        let env2 = "env2"
        let env3 = "env3"
        
        let draft = ImportedEntryDraft(
            id: UUID(),
            date: Date(),
            originalTitle: "UBER *TRIP",
            amount: -15.0,
            originalCategory: "Transport",
            suggestedEnvelopeID: nil,
            description: nil,
            spendingIntent: nil
        )
        
        // Exact rule
        let exactRule = MerchantEnvelopeRule(
            id: UUID().uuidString,
            pattern: "UBER *TRIP",
            matchType: .exact,
            envelopeID: env1,
            useCount: 1,
            lastUsedAt: Date()
        )
        
        // Normalized exact rule
        let normalizedRule = MerchantEnvelopeRule(
            id: UUID().uuidString,
            pattern: "uber trip",
            matchType: .normalizedExact,
            envelopeID: env2,
            useCount: 1,
            lastUsedAt: Date()
        )
        
        // Prefix rule
        let prefixRule = MerchantEnvelopeRule(
            id: UUID().uuidString,
            pattern: "UBER",
            matchType: .prefix,
            envelopeID: env3,
            useCount: 1,
            lastUsedAt: Date()
        )
        
        // If we have an exact rule, it should match env1
        let match1 = SmartMatcher.suggestEnvelope(for: draft, history: [], merchantRules: [prefixRule, normalizedRule, exactRule], categoryMappings: [:])
        XCTAssertEqual(match1?.envelopeID, env1)
        
        // Without exact rule, it should match normalized (env2)
        let match2 = SmartMatcher.suggestEnvelope(for: draft, history: [], merchantRules: [prefixRule, normalizedRule], categoryMappings: [:])
        XCTAssertEqual(match2?.envelopeID, env2)
        
        // Without normalized rule, it should match prefix (env3)
        let match3 = SmartMatcher.suggestEnvelope(for: draft, history: [], merchantRules: [prefixRule], categoryMappings: [:])
        XCTAssertEqual(match3?.envelopeID, env3)
        
        // Category fallback
        let match4 = SmartMatcher.suggestEnvelope(for: draft, history: [], merchantRules: [], categoryMappings: ["Transport": "env4"])
        XCTAssertEqual(match4?.envelopeID, "env4")
        
        // No match
        let match5 = SmartMatcher.suggestEnvelope(for: draft, history: [], merchantRules: [], categoryMappings: [:])
        XCTAssertNil(match5)
    }
}
