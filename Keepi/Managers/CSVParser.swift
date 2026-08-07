import Foundation

class CSVParser {
    static func parseToDictionaries(content: String) -> [[String: String]] {
        let rows = parse(content: content)
        guard let headers = rows.first, rows.count > 1 else { return [] }
        
        var result: [[String: String]] = []
        for row in rows.dropFirst() {
            var dict: [String: String] = [:]
            for (index, header) in headers.enumerated() {
                if index < row.count {
                    dict[header] = row[index]
                } else {
                    dict[header] = ""
                }
            }
            if !dict.values.allSatisfy({ $0.isEmpty }) {
                result.append(dict)
            }
        }
        return result
    }
    
    static func parse(content: String) -> [[String]] {
        var result: [[String]] = []
        var currentRow: [String] = []
        var currentField = ""
        var inQuotes = false
        
        let chars = Array(content)
        var i = 0
        
        let delimiter = detectDelimiter(in: content)
        
        while i < chars.count {
            let c = chars[i]
            
            if inQuotes {
                if c == "\"" {
                    if i + 1 < chars.count && chars[i + 1] == "\"" {
                        currentField.append("\"")
                        i += 1
                    } else {
                        inQuotes = false
                    }
                } else {
                    currentField.append(c)
                }
            } else {
                if c == "\"" {
                    inQuotes = true
                } else if c == delimiter {
                    currentRow.append(currentField.trimmingCharacters(in: .whitespaces))
                    currentField = ""
                } else if c == "\r" {
                    if i + 1 < chars.count && chars[i + 1] == "\n" {
                        i += 1
                    }
                    currentRow.append(currentField.trimmingCharacters(in: .whitespaces))
                    result.append(currentRow)
                    currentRow = []
                    currentField = ""
                } else if c == "\n" {
                    currentRow.append(currentField.trimmingCharacters(in: .whitespaces))
                    result.append(currentRow)
                    currentRow = []
                    currentField = ""
                } else {
                    currentField.append(c)
                }
            }
            i += 1
        }
        
        if !currentField.isEmpty || !currentRow.isEmpty {
            currentRow.append(currentField.trimmingCharacters(in: .whitespaces))
            result.append(currentRow)
        }
        
        return result
    }
    
    static func detectDelimiter(in content: String) -> Character {
        let firstLine = content.components(separatedBy: .newlines).first ?? ""
        var inQuotes = false
        var commaCount = 0
        var semiCount = 0
        
        for c in firstLine {
            if c == "\"" {
                inQuotes.toggle()
            } else if !inQuotes {
                if c == "," { commaCount += 1 }
                else if c == ";" { semiCount += 1 }
            }
        }
        
        return semiCount > commaCount ? ";" : ","
    }
}
