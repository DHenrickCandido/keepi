import SwiftUI
import WidgetKit

struct KeepiDailyEntry: TimelineEntry {
    let date: Date
    let totalSpent: Double
    let entryCount: Int
    let pendingReflectionCount: Int
    let entries: [KeepiWidgetEntry]
}

struct KeepiWidgetEntry: Codable, Identifiable {
    let id: String
    let title: String
    let value: Double
    let date: Date
}

struct KeepiDailyProvider: TimelineProvider {
    func placeholder(in context: Context) -> KeepiDailyEntry {
        KeepiDailyEntry(
            date: Date(),
            totalSpent: 42.50,
            entryCount: 3,
            pendingReflectionCount: 1,
            entries: [
                KeepiWidgetEntry(id: "1", title: "Coffee", value: 5.50, date: Date()),
                KeepiWidgetEntry(id: "2", title: "Lunch", value: 22.00, date: Date()),
                KeepiWidgetEntry(id: "3", title: "Transport", value: 15.00, date: Date())
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (KeepiDailyEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<KeepiDailyEntry>) -> Void) {
        let entry = currentEntry()
        let now = Date()
        let regularRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: now) ?? now
        let midnight = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0),
            matchingPolicy: .nextTime
        ) ?? regularRefresh
        let nextRefresh = min(regularRefresh, midnight)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func currentEntry() -> KeepiDailyEntry {
        let defaults = UserDefaults(suiteName: "group.candidohdiego.Keepi") ?? .standard
        let updatedAt = defaults.object(forKey: "dailyWidget.updatedAt") as? Date
        let isCurrentDay = updatedAt.map(Calendar.current.isDateInToday) ?? false

        return KeepiDailyEntry(
            date: Date(),
            totalSpent: isCurrentDay ? defaults.double(forKey: "dailyWidget.totalSpent") : 0,
            entryCount: isCurrentDay ? defaults.integer(forKey: "dailyWidget.entryCount") : 0,
            pendingReflectionCount: defaults.integer(forKey: "dailyWidget.pendingReflectionCount"),
            entries: isCurrentDay ? loadEntries(from: defaults) : []
        )
    }

    private func loadEntries(from defaults: UserDefaults) -> [KeepiWidgetEntry] {
        guard let data = defaults.data(forKey: "dailyWidget.entries"),
              let entries = try? JSONDecoder().decode([KeepiWidgetEntry].self, from: data) else {
            return []
        }

        return entries.sorted { $0.date > $1.date }
    }
}

struct KeepiWidgetEntryView: View {
    let entry: KeepiDailyEntry

    private var visibleEntries: [KeepiWidgetEntry] {
        Array(entry.entries.prefix(3))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(WidgetFormat.currency(entry.totalSpent))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.18, green: 0.38, blue: 0.26))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Text("\(entry.entryCount) today")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if entry.pendingReflectionCount > 0 {
                        Text("\(entry.pendingReflectionCount) to reflect")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 0.18, green: 0.38, blue: 0.26))
                    }
                }

                Spacer()

                Link(destination: URL(string: "keepi://add")!) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color(red: 0.18, green: 0.38, blue: 0.26))
                        .accessibilityLabel("Add entry")
                }
            }

            Divider()

            if visibleEntries.isEmpty {
                Spacer(minLength: 0)

                Text("No entries yet")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)

                Spacer(minLength: 0)
            } else {
                VStack(spacing: 5) {
                    ForEach(visibleEntries) { item in
                        HStack(spacing: 6) {
                            Text(item.title)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .lineLimit(1)

                            Spacer(minLength: 4)

                            Text(WidgetFormat.currency(item.value))
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 0.18, green: 0.38, blue: 0.26))
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                    }

                    if entry.entryCount > visibleEntries.count {
                        Text("+\(entry.entryCount - visibleEntries.count) more")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding(14)
        .containerBackground(Color(red: 0.95, green: 0.96, blue: 0.94), for: .widget)
        .widgetURL(URL(string: "keepi://add"))
    }
}

private enum WidgetFormat {
    static func currency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "$%.2f", value)
    }
}

struct keepiWidget: Widget {
    let kind = "KeepiDailyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: KeepiDailyProvider()) { entry in
            KeepiWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Keepi Today")
        .description("See today's entries and quickly add a new one.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    keepiWidget()
} timeline: {
    KeepiDailyEntry(
        date: .now,
        totalSpent: 42.50,
        entryCount: 3,
        pendingReflectionCount: 1,
        entries: [
            KeepiWidgetEntry(id: "1", title: "Coffee", value: 5.50, date: .now),
            KeepiWidgetEntry(id: "2", title: "Lunch", value: 22.00, date: .now),
            KeepiWidgetEntry(id: "3", title: "Transport", value: 15.00, date: .now)
        ]
    )
}
