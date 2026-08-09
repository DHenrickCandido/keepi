import Foundation

struct ExternalCategoryMapping: Identifiable, Codable {
    var id: String { sourceCategory }
    var sourceCategory: String
    var envelopeID: String
}
