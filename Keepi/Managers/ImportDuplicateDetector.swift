import Foundation
import CryptoKit

struct ProcessedImportRow {
    let draft: ImportedEntryDraft
    let isDuplicate: Bool
}

class ImportDuplicateDetector {
    static func generateFingerprint(date: Date, amount: Decimal, title: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        let normalizedDate = formatter.string(from: date)
        
        let normalizedAmount = NSDecimalNumber(decimal: amount).stringValue
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        let payload = "\(normalizedDate)|\(normalizedAmount)|\(normalizedTitle)"
        let data = Data(payload.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    static func filterDuplicates(drafts: [ImportedEntryDraft], existingTransactions: [TransactionModel], existingDrafts: [ImportedEntryDraft]) -> [ProcessedImportRow] {
        var existingFingerprints = Set<String>()
        
        for tx in existingTransactions {
            if let fp = tx.sourceFingerprint {
                existingFingerprints.insert(fp)
            }
        }
        
        for draft in existingDrafts {
            existingFingerprints.insert(draft.sourceFingerprint)
        }
        
        var results = [ProcessedImportRow]()
        
        for draft in drafts {
            if existingFingerprints.contains(draft.sourceFingerprint) {
                results.append(ProcessedImportRow(draft: draft, isDuplicate: true))
            } else {
                existingFingerprints.insert(draft.sourceFingerprint)
                results.append(ProcessedImportRow(draft: draft, isDuplicate: false))
            }
        }
        
        return results
    }
}
