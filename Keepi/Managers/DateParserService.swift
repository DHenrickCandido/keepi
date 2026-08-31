import Foundation

enum DateFormatAmbiguity: Equatable {
    case unambiguous(String)
    case ambiguous(options: [String], sampleDateString: String)
    case invalid
}

class DateParserService {
    static let possibleFormats = [
        "dd/MM/yyyy", "MM/dd/yyyy", "yyyy-MM-dd",
        "dd-MM-yyyy", "yyyy/MM/dd", "dd/MM/yy", "MM/dd/yy",
        "yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd'T'HH:mm:ssZ"
    ]
    
    static func detectFormat(from dateStrings: [String]) -> DateFormatAmbiguity {
        let validDates = dateStrings.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard !validDates.isEmpty else { return .invalid }
        
        var validFormats = possibleFormats
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.isLenient = false
        
        for dateString in validDates {
            var formatsThatWorkForThisDate = [String]()
            for format in validFormats {
                formatter.dateFormat = format
                if formatter.date(from: dateString) != nil {
                    formatsThatWorkForThisDate.append(format)
                }
            }
            validFormats = formatsThatWorkForThisDate
            
            if validFormats.isEmpty { return .invalid }
        }

        if validFormats.count == 1 { return .unambiguous(validFormats[0]) }
        
        let firstAmbiguousDateString = validDates[0]
        
        var generatedDates = Set<Date>()
        var optionsToPresent = [String]()
        
        for format in validFormats {
            formatter.dateFormat = format
            if let parsed = formatter.date(from: firstAmbiguousDateString) {
                if !generatedDates.contains(parsed) {
                    generatedDates.insert(parsed)
                    optionsToPresent.append(format)
                }
            }
        }
        
        if optionsToPresent.count == 1 {
            return .unambiguous(optionsToPresent[0])
        } else {
            return .ambiguous(options: optionsToPresent, sampleDateString: firstAmbiguousDateString)
        }
    }
}
