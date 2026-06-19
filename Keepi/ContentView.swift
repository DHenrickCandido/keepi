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
        if !notFirstTime {
            OnboardingTabView(notFirstTime: $notFirstTime)
        } else {
            MainTabView()
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
    }
}
