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
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundColor(Color("mainGreen"))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color("lightGrayKeepi"))
        .cornerRadius(16)
    }
}

struct TagComponent_Previews: PreviewProvider {
    static var previews: some View {
        TagComponent(selectedTag: Tags.getTags()[0])
    }
}
