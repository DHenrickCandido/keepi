//
//  OnboardingTabView.swift
//  Keepi
//
//  Created by Julia Elice Jurczyszyn on 05/09/23.
//

import Foundation
import SwiftUI

struct OnboardingTabView: View {
    
    var body: some View {
        ZStack {
            Color("beige")
                .ignoresSafeArea()
            
            TabView {
                Onboarding1View()
                Onboarding2View()
                Onboarding3View()
                Onboarding4View()
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .ignoresSafeArea()
        .edgesIgnoringSafeArea(.all)
    }
}
