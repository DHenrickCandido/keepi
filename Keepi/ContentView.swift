//
//  ContentView.swift
//  Keepi
//
//  Created by Diego Henrick on 25/08/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var premiumManager: StoreKitPremiumManager
    @AppStorage("notFirstTime") private var notFirstTime = false
    @AppStorage("hasSeenOnboardingPaywall") private var hasSeenOnboardingPaywall = false
    @State private var showOnboardingPaywall = false

    var body: some View {
        Group {
            if !notFirstTime {
                OnboardingTabView(notFirstTime: $notFirstTime)
            } else {
                MainTabView()
                    .navigationBarBackButtonHidden(true)
                    .preferredColorScheme(.light)
            }
        }
        .onChange(of: notFirstTime) { completedOnboarding in
            guard completedOnboarding, !hasSeenOnboardingPaywall else { return }
            hasSeenOnboardingPaywall = true

            if !premiumManager.hasPremium {
                showOnboardingPaywall = true
            }
        }
        .fullScreenCover(isPresented: $showOnboardingPaywall) {
            PaywallView()
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
            .environmentObject(StoreKitPremiumManager())
    }
}
