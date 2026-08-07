import Foundation

struct DailyWidgetSnapshot {
    let totalSpent: Double
    let entryCount: Int
    let pendingReflectionCount: Int
    let entries: [DailyWidgetEntry]
}

struct DailyWidgetEntry: Codable, Identifiable {
    let id: String
    let title: String
    let value: Double
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

    static func save(trades: [TransactionModel], calendar: Calendar = .current) {
        let todayTrades = trades
            .filter { calendar.isDateInToday($0.date) }
            .sorted { $0.date > $1.date }
        let totalSpent = todayTrades.reduce(Decimal.zero) { $0 + $1.value }
        let entries = todayTrades.map {
            DailyWidgetEntry(id: $0.id, title: $0.name, value: NSDecimalNumber(decimal: $0.value).doubleValue, date: $0.date)
        }

        sharedDefaults.set(NSDecimalNumber(decimal: totalSpent).doubleValue, forKey: totalSpentKey)
        sharedDefaults.set(todayTrades.count, forKey: entryCountKey)
        sharedDefaults.set(trades.filter { !$0.reflectionCompleted }.count, forKey: pendingReflectionCountKey)
        sharedDefaults.set(try? JSONEncoder().encode(entries), forKey: entriesKey)
        sharedDefaults.set(Date(), forKey: updatedAtKey)
    }

    static func loadSnapshot() -> DailyWidgetSnapshot {
        guard isCurrentDay(sharedDefaults.object(forKey: updatedAtKey) as? Date) else {
            return DailyWidgetSnapshot(
                totalSpent: 0,
                entryCount: 0,
                pendingReflectionCount: sharedDefaults.integer(forKey: pendingReflectionCountKey),
                entries: []
            )
        }

        return DailyWidgetSnapshot(
            totalSpent: sharedDefaults.double(forKey: totalSpentKey),
            entryCount: sharedDefaults.integer(forKey: entryCountKey),
            pendingReflectionCount: sharedDefaults.integer(forKey: pendingReflectionCountKey),
            entries: loadEntries()
        )
    }

    static func isCurrentDay(_ date: Date?, now: Date = Date(), calendar: Calendar = .current) -> Bool {
        guard let date else { return false }
        return calendar.isDate(date, inSameDayAs: now)
    }

    private static func loadEntries() -> [DailyWidgetEntry] {
        guard let data = sharedDefaults.data(forKey: entriesKey),
              let entries = try? JSONDecoder().decode([DailyWidgetEntry].self, from: data) else {
            return []
        }

        return entries.sorted { $0.date > $1.date }
    }
}
