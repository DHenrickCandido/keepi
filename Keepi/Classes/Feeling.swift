import Foundation

struct Feeling: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let index: Int
}

struct FeelingList {
    
    let feelings: [Feeling] = [
        Feeling(name: "happy", icon: "feeling0", index: 0),
        Feeling(name: "super happy", icon: "feeling1", index: 1),
        Feeling(name: "neutral", icon: "feeling2", index: 2),
        Feeling(name: "sad", icon: "feeling3", index: 3),
        Feeling(name: "super shy", icon: "feeling4", index: 4)
    ]
    
    static func getFeelings() -> [Feeling] {
        let feelings: [Feeling] = [
            Feeling(name: "happy", icon: "feeling0", index: 0),
            Feeling(name: "super happy", icon: "feeling1", index: 1),
            Feeling(name: "neutral", icon: "feeling2", index: 2),
            Feeling(name: "sad", icon: "feeling3", index: 3),
            Feeling(name: "super shy", icon: "feeling4", index: 4)
        ]
        
        return feelings
    }
}
