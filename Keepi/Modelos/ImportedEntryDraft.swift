import Foundation

enum ImportReviewStatus: String, Codable {
    case pending
    case reviewed
    case skipped
}

enum SpendingIntent: String, Codable {
    case needs
    case wants
    case savings
    case unplanned
}

struct ImportedEntryDraft: Identifiable, Codable {
    let id: UUID
    var originalTitle: String
    var normalizedMerchant: String?
    var amount: Decimal
    var date: Date
    var originalCategory: String?
    var description: String?
    var suggestedEnvelopeID: String?
    var feeling: Feeling?
    var spendingIntent: SpendingIntent?
    var reviewStatus: ImportReviewStatus
    var sourceFingerprint: String
}
