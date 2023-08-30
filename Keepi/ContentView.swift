//
//  ContentView.swift
//  Keepi
//
//  Created by Diego Henrick on 25/08/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Trade(tradeModel: TradeModel(name: "teste"), tradeListModel: TradeListManager())
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundColor(.accentColor)
//            Text("Hello, Keepi!")
//        }
//        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
