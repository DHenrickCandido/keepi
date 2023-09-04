//
//  TagComponent.swift
//  Keepi
//
//  Created by Kauane Santana on 30/08/23.
//

import SwiftUI

struct TagComponent: View {
    @State var selectedTag: Tag
    
    var body: some View {
        VStack {
            Text(selectedTag.name)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white)
        .cornerRadius(4)
    }
}

struct TagComponent_Previews: PreviewProvider {
    static var previews: some View {
        TagComponent(selectedTag: Tags.getTags()[0])
    }
}
