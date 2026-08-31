import Foundation

enum EntryPeriod {
    case day(Date)
    case month(Date)
    case allTime
}

protocol EntryAggregationService {
    func total(
        entries: [TransactionModel],
        envelopeID: String,
        period: EntryPeriod
    ) -> Decimal

    func entries(
        from entries: [TransactionModel],
        envelopeID: String,
        period: EntryPeriod
    ) -> [TransactionModel]
}

struct DefaultEntryAggregationService: EntryAggregationService {
    let calendar: Calendar
    
    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }
    
    func entries(
        from entries: [TransactionModel],
        envelopeID: String,
        period: EntryPeriod
    ) -> [TransactionModel] {
        let envelopeEntries = entries.filter { $0.envelopeId == envelopeID }
        
        switch period {
        case .allTime:
            return envelopeEntries
        case .day(let date):
            return envelopeEntries.filter { calendar.isDate($0.date, inSameDayAs: date) }
        case .month(let date):
            guard let interval = calendar.dateInterval(of: .month, for: date) else { return [] }
            return envelopeEntries.filter {
                $0.date >= interval.start && $0.date < interval.end
            }
        }
    }
    
    func total(
        entries: [TransactionModel],
        envelopeID: String,
        period: EntryPeriod
    ) -> Decimal {
        return self.entries(from: entries, envelopeID: envelopeID, period: period)
            .reduce(0) { $0 + $1.spendingAmount }
    }
}
