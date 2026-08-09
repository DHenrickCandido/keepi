import Foundation

struct ImportMetadata: Codable {
    var sourceType: String
    var sourceFingerprint: String
    var originalTitle: String
    var importedAt: Date
}
