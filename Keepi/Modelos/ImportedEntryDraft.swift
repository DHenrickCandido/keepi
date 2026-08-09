import Foundation

enum ImportReviewStatus: String, Codable {
    case pending
    case reviewed
    case skipped
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
