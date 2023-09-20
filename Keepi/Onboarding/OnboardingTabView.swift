//
//  OnboardingTabView.swift
//  Keepi
//
//  Created by Julia Elice Jurczyszyn on 05/09/23.
//

import Foundation
import SwiftUI

struct OnboardingTabView: View {
    @Binding var notFirstTime: Bool
    var body: some View {
        ZStack {
            Color("beige")
                .ignoresSafeArea()
            
            TabView {
                Onboarding1View(notFirstTime: $notFirstTime)
                Onboarding2View(notFirstTime: $notFirstTime)
                Onboarding3View(notFirstTime: $notFirstTime)
                Onboarding4View(notFirstTime: $notFirstTime)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .ignoresSafeArea()
        .edgesIgnoringSafeArea(.all)
        .opacity(notFirstTime ? 0 : 1)
    }
}
