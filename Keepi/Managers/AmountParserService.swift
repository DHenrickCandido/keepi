import Foundation

class AmountParserService {
    static func parseAmount(_ amountString: String) -> Double? {
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789.,-")
        let cleanString = String(amountString.unicodeScalars.filter { allowedCharacterSet.contains($0) })
        
        guard !cleanString.isEmpty else { return nil }
        
        let hasMinus = cleanString.contains("-")
        let stringWithoutMinus = cleanString.replacingOccurrences(of: "-", with: "")
        
        let lastPeriod = stringWithoutMinus.lastIndex(of: ".")
        let lastComma = stringWithoutMinus.lastIndex(of: ",")
        
        var normalizedString = stringWithoutMinus
        
        if let period = lastPeriod, let comma = lastComma {
            if period > comma {
                normalizedString = stringWithoutMinus.replacingOccurrences(of: ",", with: "")
            } else {
                normalizedString = stringWithoutMinus.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: ".")
            }
        } else if let comma = lastComma {
            let charsAfterComma = stringWithoutMinus.distance(from: comma, to: stringWithoutMinus.endIndex) - 1
            if charsAfterComma == 3 && stringWithoutMinus.count > 4 {
                normalizedString = stringWithoutMinus.replacingOccurrences(of: ",", with: "")
            } else {
                normalizedString = stringWithoutMinus.replacingOccurrences(of: ",", with: ".")
            }
        } else {
            let periods = stringWithoutMinus.filter { $0 == "." }.count
            if periods > 1 {
                if let last = stringWithoutMinus.lastIndex(of: ".") {
                    let beforeLast = stringWithoutMinus[..<last].replacingOccurrences(of: ".", with: "")
                    let afterLast = stringWithoutMinus[last...]
                    normalizedString = beforeLast + String(afterLast)
                }
            }
        }
        
        guard let finalAmount = Double(normalizedString) else { return nil }
        return hasMinus ? -finalAmount : finalAmount
    }
}
