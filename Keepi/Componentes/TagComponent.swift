//
//  TagComponent.swift
//  Keepi
//
//  Created by Kauane Santana on 30/08/23.
//

import SwiftUI

struct TagComponent: View {
    var body: some View {
        VStack {
            Text("tag1")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white)
        .cornerRadius(4)
    }
}

struct TagComponent_Previews: PreviewProvider {
    static var previews: some View {
        TagComponent()
    }
}
