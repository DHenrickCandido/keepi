//
//  Lista.swift
//  Keepi
//
//  Created by Kauane Santana on 25/08/23.
//

import SwiftUI

struct Lista: View {
    var body: some View {
        List{
            Text("compra 1")
            Text("compra 2")
            Text("compra 3")
            Text("compra 4")
            Text("compra 5")
        }
    }
}

struct Lista_Previews: PreviewProvider {
    static var previews: some View {
        Lista()
    }
}
