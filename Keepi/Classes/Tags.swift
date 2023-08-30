import SwiftUI

struct Tag: Identifiable, Hashable {
    let id = UUID()
    let name: String
    
}

struct Tags {

    static func getTags() -> [Tag] {
        let allTags: [Tag] = [
            Tag(name: "Estava com vontade"),
            Tag(name: "Saí com os amigos"),
            Tag(name: "Comprei por impulso")
        ]
        
        return allTags
    }
}
