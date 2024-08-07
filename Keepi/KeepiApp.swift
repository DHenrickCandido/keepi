//
//  KeepiApp.swift
//  Keepi
//
//  Created by Diego Henrick on 25/08/23.
//

import SwiftUI
import Firebase

@main
struct KeepiApp: App {
    @State var splash = 1.0
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
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
