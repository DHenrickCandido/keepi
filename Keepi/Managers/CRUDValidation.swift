import Foundation

enum CRUDValidation {
    static func normalizedDecimal(_ text: String) -> Decimal? {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")
        guard let value = Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX")), value > 0 else { return nil }
        return Money.rounded(value)
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
    static func currency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "$\(editableAmount(value))"
    }

    static func editableAmount(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? NSDecimalNumber(decimal: value).stringValue
    }
}

enum Money {
    static func rounded(_ value: Decimal) -> Decimal {
        var input = value
        var result = Decimal()
        NSDecimalRound(&result, &input, 2, .plain)
        return result
    }

    static func firestoreNumber(_ value: Decimal) -> NSDecimalNumber {
        NSDecimalNumber(decimal: rounded(value))
    }
}

enum TradeIdentity {
    static func make() -> String {
        UUID().uuidString
    }
}
