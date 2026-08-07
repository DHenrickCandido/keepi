//
//  KeepiApp.swift
//  Keepi
//
//  Created by Diego Henrick on 25/08/23.
//

import SwiftUI
import FirebaseCore

@main
struct KeepiApp: App {
    @StateObject private var premiumManager = StoreKitPremiumManager()
    @State var splash = 1.0
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(premiumManager)
                    .preferredColorScheme(.light)

                SplashScreenView()
                    .preferredColorScheme(.light)
                    .opacity(splash)

            }
            .animation(.easeInOut, value: splash)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        splash = 0.0
                    }
                }
            }
        }
        
    }
}
