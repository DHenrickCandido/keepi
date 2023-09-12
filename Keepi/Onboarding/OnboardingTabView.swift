//
//  OnboardingTabView.swift
//  Keepi
//
//  Created by Julia Elice Jurczyszyn on 05/09/23.
//

import Foundation
import SwiftUI

struct OnboardingTabView: View {
    @Binding var showingOnboarding: Bool
    var body: some View {
        ZStack {
            Color("beige")
                .ignoresSafeArea()
            
            TabView {
                Onboarding1View(showingOnboarding: $showingOnboarding)
                Onboarding2View(showingOnboarding: $showingOnboarding)
                Onboarding3View(showingOnboarding: $showingOnboarding)
                Onboarding4View(showingOnboarding: $showingOnboarding)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .ignoresSafeArea()
        .edgesIgnoringSafeArea(.all)
    }
}
