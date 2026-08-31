import Foundation

struct ReflectionContext {
    let envelopes: [Envelope]
}

protocol ReflectionRule {
    func evaluate(entries: [TransactionModel], context: ReflectionContext) -> ReflectionObservation?
}

// "You marked 6 purchases as impulsive. 4 of them were in Eating Out."
struct HighImpulseEnvelopeRule: ReflectionRule {
    func evaluate(entries: [TransactionModel], context: ReflectionContext) -> ReflectionObservation? {
        let impulsiveEntries = entries.filter { $0.spendingIntent == .impulsive }
        guard impulsiveEntries.count >= 2 else { return nil }
        
        var envelopeCounts: [String: Int] = [:]
        for entry in impulsiveEntries {
            envelopeCounts[entry.envelopeId, default: 0] += 1
        }
        
        guard let topEnvelope = envelopeCounts.max(by: { $0.value < $1.value }) else { return nil }
        
        // Only trigger if a significant portion of impulsive spending was in one place (e.g. > 40%)
        let percentage = Double(topEnvelope.value) / Double(impulsiveEntries.count)
        guard percentage > 0.4, topEnvelope.value >= 2 else { return nil }
        
        let envelopeName = context.envelopes.first(where: { $0.id == topEnvelope.key })?.name ?? "Unknown Envelope"
        
        return ReflectionObservation(
            text: "You marked \(impulsiveEntries.count) purchases as impulsive. \(topEnvelope.value) of them were in \(envelopeName).",
            highlight: "Impulsive Pattern"
        )
    }
}

// "Most purchases you marked as 'regret' were made in Shopping."
struct MostRegrettedEnvelopeRule: ReflectionRule {
    func evaluate(entries: [TransactionModel], context: ReflectionContext) -> ReflectionObservation? {
        // Assuming feeling 3 corresponds to 'Regret' / Bad
        let regretEntries = entries.filter { $0.feeling == 3 }
        guard regretEntries.count >= 2 else { return nil }
        
        var envelopeCounts: [String: Int] = [:]
        for entry in regretEntries {
            envelopeCounts[entry.envelopeId, default: 0] += 1
        }
        
        guard let topEnvelope = envelopeCounts.max(by: { $0.value < $1.value }) else { return nil }
        
        let percentage = Double(topEnvelope.value) / Double(regretEntries.count)
        guard percentage >= 0.5 else { return nil }
        
        let envelopeName = context.envelopes.first(where: { $0.id == topEnvelope.key })?.name ?? "Unknown Envelope"
        
        return ReflectionObservation(
            text: "Most purchases you marked as 'regret' were made in \(envelopeName).",
            highlight: "Regret Pattern"
        )
    }
}

// Example: "You have 5 unreviewed imports from this week."
struct UnreviewedCountRule: ReflectionRule {
    let unreviewedCount: Int
    func evaluate(entries: [TransactionModel], context: ReflectionContext) -> ReflectionObservation? {
        guard unreviewedCount > 0 else { return nil }
        return ReflectionObservation(
            text: "You have \(unreviewedCount) unreviewed imported transactions.",
            highlight: "Unreviewed Imports"
        )
    }
}
