//
//  Onboarding3View.swift
//  Keepi
//
//  Created by Julia Elice Jurczyszyn on 05/09/23.
//

import SwiftUI

struct Onboarding3View: View {
    @Binding var showingOnboarding: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color("mainGreen")
                
                Circle()
                    .foregroundColor(Color("secondGreen"))
                    .opacity(0.7)
                    .frame(width: 150)
                    .offset(x: -170, y: -380)
                
                Circle()
                    .foregroundColor(Color("yellow"))
                    .opacity(0.7)
                    .frame(width: 40)
                    .offset(x: -70, y: -320)
                
                Circle()
                    .stroke(lineWidth: 4)
                    .foregroundColor(Color("yellow"))
                    .opacity(0.7)
                    .frame(width: 320)
                    .offset(x: 250, y: -110)
                
                Circle()
                    .stroke(lineWidth: 4)
                    .foregroundColor(Color("red"))
                    .opacity(0.7)
                    .frame(width: 100)
                    .offset(x: -100, y: 300)
                
                
                
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            showingOnboarding = false
                        } label: {
                            Text("Skip")
                                .font(.system(size: 20))
                                .bold()
                                .foregroundColor(.white)
                                .padding(.trailing, 40)
                        }
                        
                    }
                    .padding(.top, 80)
                    Spacer()
                        
                }
                
                Image("envelopes")
                    .offset(y: -50)
                
                Text("Use the envelopes to define the budget for each type of trade.")
                    .font(.system(size: 24))
                    .bold()
                    .foregroundColor(.white)
                    .frame(width: 350)
                    .multilineTextAlignment(.center)
                    .offset(y: 150)
            }
            .ignoresSafeArea()
        }
    }
}

struct Onboarding3View_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding3View(showingOnboarding: .constant(false))
    }
}
