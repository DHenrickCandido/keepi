//
//  ContentView.swift
//  Keepi
//
//  Created by Diego Henrick on 25/08/23.
//

import SwiftUI

struct ContentView: View {
    @State var showingOnboarding: Bool = true
//    @Binding var listTitleEnvelopeName: String
    
    var body: some View {
        if showingOnboarding {
            OnboardingTabView(showingOnboarding: $showingOnboarding)

        } else {
            HomeView(tradeModel: TradeModel(id: "34", name: "Comida", value: 25, tag: []))
            
//            HomeView(tradeModel: TradeModel(id: "34", name: "Comida", value: 25, tag: []), listTitleEnvelopeName: $listTitleEnvelopeName)
            
                .environmentObject(TradeListManager())
                .environmentObject(EnvelopeListManager())
                .navigationBarBackButtonHidden(true)
                .preferredColorScheme(.light)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
//        ContentView(listTitleEnvelopeName: .constant("teste"))
    }
}
