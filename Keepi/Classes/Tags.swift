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
            Tag(id: 6, name: "Other"),
            Tag(id: 7, name: "It was planned"),
            Tag(id: 8, name: "It was impulsive")
        ]
        return allTags
    }
    
    static func getTags(listNames: [String]) -> [Tag] {
        var tagsList: [Tag] = []
        for name in listNames {
            for tag in getTags() {
                if name == tag.name{
                    tagsList.append(tag)
                }
            }
        }
        return tagsList
    }
}
