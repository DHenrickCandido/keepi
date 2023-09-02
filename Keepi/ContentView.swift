//
//  ContentView.swift
//  Keepi
//
//  Created by Diego Henrick on 25/08/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView(tradeModel: TradeModel(name: "testeName", value: 25, tag: []), tradeListManager: TradeListManager())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
