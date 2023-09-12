//
//  ContentView.swift
//  Keepi
//
//  Created by Diego Henrick on 25/08/23.
//

import SwiftUI

struct ContentView: View {
    @State var showingOnboarding: Bool = true
    var body: some View {
        if showingOnboarding {
            OnboardingTabView(showingOnboarding: $showingOnboarding)

        } else {
            HomeView(tradeModel: TradeModel(id: "34", name: "Comida", value: 25, tag: []))
                .environmentObject(TradeListManager())
                .environmentObject(EnvelopeListManager())
                .navigationBarBackButtonHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
