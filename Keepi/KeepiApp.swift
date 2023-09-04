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
    @StateObject var tradeListManager = TradeListManager()
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
