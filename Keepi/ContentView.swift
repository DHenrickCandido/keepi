//
//  ContentView.swift
//  Keepi
//
//  Created by Diego Henrick on 25/08/23.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("notFirstTime") var notFirstTime: Bool = false
    
    var body: some View {
        let _ = print("PRINTTTTTT aaa \(loadIsFirstTime())")

        if !notFirstTime {
            OnboardingTabView(notFirstTime: $notFirstTime)
            
        } else {
            HomeView(tradeModel: TradeModel(id: "34", name: "Comida", value: 25, tag: []))
                .environmentObject(HomeInteractor(tradeListManager: TradeListManager(), envelopeListManager: EnvelopeListManager()))
                .navigationBarBackButtonHidden(true)
                .preferredColorScheme(.light)
        }
    }
}

public func saveIsFirstTime(_ notFirstTime: Bool) {
    UserDefaults.standard.set(notFirstTime, forKey: "notFirstTime")
}

func loadIsFirstTime() -> Bool {
    return UserDefaults.standard.bool(forKey: "notFirstTime")
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
//        ContentView(listTitleEnvelopeName: .constant("teste"))
    }
}

