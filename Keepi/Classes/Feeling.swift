import Foundation

struct Feeling: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
}

struct FeelingList {
    
    static func getFeelings() -> [Feeling] {
        let feelings: [Feeling] = [
            Feeling(name: "happy", icon: "sun.min"),
            Feeling(name: "super happy", icon: "sun.min"),
            Feeling(name: "neutral", icon: "sun.min"),
            Feeling(name: "sad", icon: "sun.min"),
            Feeling(name: "super shy", icon: "sun.min")
        ]
        
        return feelings
    }
}
