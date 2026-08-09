import Foundation

struct MerchantNormalizer {
    
    static func normalize(_ title: String) -> String {
        var normalized = title.lowercased()
        
        // Remove common transaction identifiers and processing prefixes safely
        let prefixesToRemove = ["pgto ", "pix ", "ted ", "doc ", "compra ", "pagamento ", "transferencia "]
        for prefix in prefixesToRemove {
            if normalized.hasPrefix(prefix) {
                normalized.removeFirst(prefix.count)
            }
        }
        
        // Remove card suffixes like '*1234' or just ' 1234' at the end
        // Pattern: space/asterisk followed by 3-4 digits at the end of the string
        let suffixPattern = "(\\s|\\*)+[0-9]{3,4}$"
        if let regex = try? NSRegularExpression(pattern: suffixPattern, options: .caseInsensitive) {
            normalized = regex.stringByReplacingMatches(in: normalized, options: [], range: NSRange(location: 0, length: normalized.utf16.count), withTemplate: "")
        }
        
        // Replace punctuation (asterisks, hyphens, etc.) with spaces, except when it's part of a known brand name (but safely, we just replace with spaces)
        let punctuationPattern = "[*\\-/_]"
        if let regex = try? NSRegularExpression(pattern: punctuationPattern, options: []) {
            normalized = regex.stringByReplacingMatches(in: normalized, options: [], range: NSRange(location: 0, length: normalized.utf16.count), withTemplate: " ")
        }
        
        // Remove extra spaces
        normalized = normalized.trimmingCharacters(in: .whitespacesAndNewlines)
        let extraSpacesPattern = "\\s+"
        if let regex = try? NSRegularExpression(pattern: extraSpacesPattern, options: []) {
            normalized = regex.stringByReplacingMatches(in: normalized, options: [], range: NSRange(location: 0, length: normalized.utf16.count), withTemplate: " ")
        }
        
        return normalized.isEmpty ? title.lowercased() : normalized
    }
}
