import Foundation

enum CRUDValidation {
    static func normalizedDecimal(_ text: String) -> Float? {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")
        guard let value = Float(normalized), value > 0 else { return nil }
        return value
    }

    static func envelopeId(from name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let id = trimmed.replacingOccurrences(of: " ", with: "")
        return id.isEmpty ? nil : id
    }

    static func canDeleteEnvelope(envelopeId: String, trades: [TradeModel]) -> Bool {
        guard !envelopeId.isEmpty else { return true }
        return !trades.contains { $0.envelopeId == envelopeId }
    }
}

enum KeepiFormat {
    static func currency(_ value: Float) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "$%.2f", value)
    }
}
