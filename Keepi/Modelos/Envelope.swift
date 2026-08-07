import Foundation

struct Envelope: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var icon: String

    var monthlyBudget: Decimal?

    var createdAt: Date
    var updatedAt: Date
}
