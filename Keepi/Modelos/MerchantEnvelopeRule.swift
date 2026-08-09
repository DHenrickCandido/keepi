import Foundation

enum MerchantMatchType: String, Codable {
    case exact
    case normalizedExact
    case contains
    case prefix
}

struct MerchantEnvelopeRule: Identifiable, Codable {
    let id: String
    var pattern: String
    var matchType: MerchantMatchType
    var envelopeID: String
    var useCount: Int
    var lastUsedAt: Date
}
