import Foundation

enum SpendingIntent: String, Codable, CaseIterable {
    case planned
    case impulsive
    case unsure
}
