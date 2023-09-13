//
//  Onboarding4View.swift
//  Keepi
//
//  Created by Julia Elice Jurczyszyn on 05/09/23.
//

import SwiftUI

struct Onboarding4View: View {
    @Binding var showingOnboarding: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color("mainGreen")
                    .ignoresSafeArea()
                
                Circle()
                    .foregroundColor(Color("red"))
                    .opacity(0.7)
                    .frame(width: 200)
                    .offset(x: -180, y: -350)
                
                Circle()
                    .stroke(lineWidth: 4)
                    .foregroundColor(Color("secondGreen"))
                    .opacity(0.7)
                    .frame(width: 100)
                    .offset(x: 90, y: -130)
                
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
                
             
                    Image("emotions")
                    .offset(y: -50)
              
                    
                    Text("Register and reflect on what motivated you to make a trade.")
                        .font(.system(size: 24))
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 350)
                        .multilineTextAlignment(.center)
                        .offset(y: 150)
                    
                VStack {
                    Spacer()
                    Button {
                        showingOnboarding = false
                        
                    } label: {
                        Text("Get Started  \(Image(systemName: "arrow.forward"))")
                            .font(.system(size: 20))
                            .bold()
                            .foregroundColor(Color("mainGreen"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background()
                            .cornerRadius(16)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 80)
            }
            .ignoresSafeArea()
        }
    }
}

struct Onboarding4View_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding4View(showingOnboarding: .constant(false))
    }
}
