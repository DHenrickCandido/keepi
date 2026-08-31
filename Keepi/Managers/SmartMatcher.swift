import Foundation

struct SmartMatchResult {
    let envelopeID: String
    let reason: String
}

struct SmartMatcher {
    
    static func suggestEnvelope(
        for draft: ImportedEntryDraft,
        history: [TransactionModel],
        merchantRules: [MerchantEnvelopeRule],
        categoryMappings: [ExternalCategoryMapping]
    ) -> SmartMatchResult? {
        let originalTitle = draft.originalTitle
        let normalizedIncoming = MerchantNormalizer.normalize(originalTitle)
        
        // 1. Explicit learned rules
        if let rule = merchantRules.first(where: { $0.matchType == .exact && $0.pattern.caseInsensitiveCompare(originalTitle) == .orderedSame }) {
            return SmartMatchResult(envelopeID: rule.envelopeID, reason: "\(originalTitle) is being suggested because you explicitly classified it that way before.")
        }

        if let rule = merchantRules.first(where: { $0.pattern == normalizedIncoming && $0.matchType == .normalizedExact }) {
            return SmartMatchResult(envelopeID: rule.envelopeID, reason: "\(originalTitle) is being suggested because you explicitly classified it that way before.")
        }

        if let rule = merchantRules.first(where: {
            let pattern = MerchantNormalizer.normalize($0.pattern)
            switch $0.matchType {
            case .prefix: return normalizedIncoming.hasPrefix(pattern)
            case .contains: return normalizedIncoming.contains(pattern)
            default: return false
            }
        }) {
            return SmartMatchResult(envelopeID: rule.envelopeID, reason: "\(originalTitle) is being suggested because it matches a categorization rule.")
        }
        
        // 2. Exact normalized merchant match in history
        var envelopeFrequencies: [String: Int] = [:]
        for tx in history {
            let normalizedHistorical = MerchantNormalizer.normalize(tx.name)
            if normalizedIncoming == normalizedHistorical {
                envelopeFrequencies[tx.envelopeId, default: 0] += 1
            }
        }
        if let bestMatch = envelopeFrequencies.max(by: { $0.value < $1.value }) {
            return SmartMatchResult(envelopeID: bestMatch.key, reason: "\(originalTitle) is being suggested based on your past identical transactions.")
        }
        
        // 3. Stable prefix/contains rule learned from user history
        var containsFrequencies: [String: Int] = [:]
        for tx in history {
            let normalizedHistorical = MerchantNormalizer.normalize(tx.name)
            if normalizedIncoming.contains(normalizedHistorical) || normalizedHistorical.contains(normalizedIncoming) {
                if normalizedHistorical.count > 3 {
                    containsFrequencies[tx.envelopeId, default: 0] += 1
                }
            }
        }
        if let bestMatch = containsFrequencies.max(by: { $0.value < $1.value }) {
            return SmartMatchResult(envelopeID: bestMatch.key, reason: "\(originalTitle) is being suggested because it matches a pattern from your past transactions.")
        }
        
        // 4. Existing CSV category mapping
        if let category = draft.originalCategory {
            if let mapping = categoryMappings.first(where: { $0.sourceCategory == category }) {
                return SmartMatchResult(envelopeID: mapping.envelopeID, reason: "Suggested based on the imported category '\(category)'.")
            }
        }
        
        return nil
    }
}
