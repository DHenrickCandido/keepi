import Foundation

struct Feeling: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
}

struct FeelingList {
    
    let feelings: [Feeling] = [
        Feeling(name: "happy", icon: "feeling0"),
        Feeling(name: "super happy", icon: "feeling1"),
        Feeling(name: "neutral", icon: "feeling2"),
        Feeling(name: "sad", icon: "feeling3"),
        Feeling(name: "super shy", icon: "feeling4")
    ]
    
    static func getFeelings() -> [Feeling] {
        let feelings: [Feeling] = [
            Feeling(name: "happy", icon: "feeling0"),
            Feeling(name: "super happy", icon: "feeling1"),
            Feeling(name: "neutral", icon: "feeling2"),
            Feeling(name: "sad", icon: "feeling3"),
            Feeling(name: "super shy", icon: "feeling4")
        ]
        
        return feelings
    }
}
