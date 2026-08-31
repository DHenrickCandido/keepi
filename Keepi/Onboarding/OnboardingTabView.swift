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
                OnboardingImportView(notFirstTime: $notFirstTime)
                Onboarding4View(notFirstTime: $notFirstTime)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .ignoresSafeArea()
        .edgesIgnoringSafeArea(.all)
        .opacity(notFirstTime ? 0 : 1)
    }
}

struct OnboardingImportView: View {
    @Binding var notFirstTime: Bool

    var body: some View {
        ZStack {
            Color("mainGreen")

            Circle()
                .fill(Color("secondGreen").opacity(0.65))
                .frame(width: 230, height: 230)
                .offset(x: 170, y: -300)

            Circle()
                .stroke(Color("yellow").opacity(0.65), lineWidth: 4)
                .frame(width: 140, height: 140)
                .offset(x: -180, y: 320)

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Skip") {
                        finishOnboarding()
                    }
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                }
                .padding(.horizontal, 40)
                .padding(.top, 72)

                Spacer()

                importIllustration

                VStack(spacing: 12) {
                    Text("Bring in more than one entry")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("Import a CSV statement from your bank, review the entries, then reflect at your own pace.")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white.opacity(0.78))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 32)
                .padding(.top, 34)

                Spacer()
                    .frame(height: 112)
            }
        }
        .ignoresSafeArea()
    }

    private var importIllustration: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(Color("mainGreen"))
                    Text("BANK.CSV")
                        .font(.caption.bold())
                        .foregroundColor(Color("mainGreen"))
                }

                ForEach([0.82, 0.60, 0.72], id: \.self) { width in
                    Capsule()
                        .fill(Color("mainGreen").opacity(0.18))
                        .frame(width: 116 * width, height: 8)
                }
            }
            .padding(18)
            .frame(width: 150, height: 130, alignment: .leading)
            .background(.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .rotationEffect(.degrees(-4))

            Image(systemName: "arrow.right")
                .font(.title3.bold())
                .foregroundColor(Color("yellow"))

            VStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundColor(Color("mainGreen"))
                Text("Reflect")
                    .font(.caption.bold())
                    .foregroundColor(Color("mainGreen"))
            }
            .frame(width: 88, height: 100)
            .background(Color("secondGreen"), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .rotationEffect(.degrees(5))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Import a bank statement and review entries in Reflect")
    }

    private func finishOnboarding() {
        notFirstTime = true
        saveIsFirstTime(notFirstTime)
    }
}
