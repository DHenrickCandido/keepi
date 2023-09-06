import SwiftUI

struct Tag: Identifiable, Hashable {
    let id: Int
    let name: String
    
}

struct Tags {

    static func getTags() -> [Tag] {
        let allTags: [Tag] = [
            Tag(id: 1, name: "I wanted it"),
            Tag(id: 2, name: "I needed it"),
            Tag(id: 3, name: "I was with friends"),
            Tag(id: 4, name: "It was on sale"),
            Tag(id: 5, name: "I didn't think much about"),
            Tag(id: 6, name: "Other")
        ]
        
        return allTags
    }
}
