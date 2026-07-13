import Foundation

struct DailyWidgetSnapshot {
    let totalSpent: Float
    let entryCount: Int
    let pendingReflectionCount: Int
    let entries: [DailyWidgetEntry]
}

struct DailyWidgetEntry: Codable, Identifiable {
    let id: String
    let title: String
    let value: Float
    let date: Date
}

enum DailyWidgetDataStore {
    static let appGroupIdentifier = "group.candidohdiego.Keepi"
    static let openAddURL = URL(string: "keepi://add")!

    private static let totalSpentKey = "dailyWidget.totalSpent"
    private static let entryCountKey = "dailyWidget.entryCount"
    private static let pendingReflectionCountKey = "dailyWidget.pendingReflectionCount"
    private static let entriesKey = "dailyWidget.entries"
    private static let updatedAtKey = "dailyWidget.updatedAt"

    private static var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupIdentifier) ?? .standard
    }

    static func save(trades: [TradeModel], calendar: Calendar = .current) {
        let todayTrades = trades
            .filter { calendar.isDateInToday($0.date) }
            .sorted { $0.date > $1.date }
        let totalSpent = todayTrades.reduce(0) { $0 + $1.value }
        let entries = todayTrades.map {
            DailyWidgetEntry(id: $0.id, title: $0.name, value: $0.value, date: $0.date)
        }

        sharedDefaults.set(totalSpent, forKey: totalSpentKey)
        sharedDefaults.set(todayTrades.count, forKey: entryCountKey)
        sharedDefaults.set(trades.filter { !$0.reflectionCompleted }.count, forKey: pendingReflectionCountKey)
        sharedDefaults.set(try? JSONEncoder().encode(entries), forKey: entriesKey)
        sharedDefaults.set(Date(), forKey: updatedAtKey)
    }

    static func loadSnapshot() -> DailyWidgetSnapshot {
        DailyWidgetSnapshot(
            totalSpent: sharedDefaults.float(forKey: totalSpentKey),
            entryCount: sharedDefaults.integer(forKey: entryCountKey),
            pendingReflectionCount: sharedDefaults.integer(forKey: pendingReflectionCountKey),
            entries: loadEntries()
        )
    }

    private static func loadEntries() -> [DailyWidgetEntry] {
        guard let data = sharedDefaults.data(forKey: entriesKey),
              let entries = try? JSONDecoder().decode([DailyWidgetEntry].self, from: data) else {
            return []
        }

        return entries.sorted { $0.date > $1.date }
    }
}
