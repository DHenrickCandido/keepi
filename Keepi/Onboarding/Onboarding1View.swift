//
//  Onboarding1View.swift
//  Keepi
//
//  Created by Julia Elice Jurczyszyn on 05/09/23.
//

import SwiftUI

struct Onboarding1View: View {
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("mainGreen")
                
                // ELEMENTOS DE ENFEITE
                Circle()
                    .foregroundColor(Color("secondGreen"))
                    .frame(width: 200)
                    .opacity(0.7)
                    .offset(x: 200, y: -200)
                
                Circle()
                    .stroke(lineWidth: 4)
                    .foregroundColor(Color("red"))
                    .opacity(0.7)
                    .frame(width: 100)
                    .offset(x: -120, y: -300)
                
                Circle()
                    .foregroundColor(Color("yellow"))
                    .frame(width: 300)
                    .opacity(0.7)
                    .offset(x: -200, y: 400)
                    
                
                NavigationLink {
                    LoginView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    VStack {
                        HStack {
                            Spacer()
                            Text("Skip")
                                .font(.system(size: 20))
                                .bold()
                                .foregroundColor(.white)
                                .padding(.trailing, 40)
                        }
                        .padding(.top, 80)
                        Spacer()
                            
                    }
                }
                
                Image("keepi")
                    .resizable()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .scaledToFit()
                    .padding(.horizontal, 91.5)
                    .offset(y: -50)
                
                Text("Reflect the emotions of your currency trades.")
                    .foregroundColor(.white)
                    .font(.system(size: 24))
                    .bold()
                    .frame(width: 255)
                    .multilineTextAlignment(.center)
                    .offset(y: 150)   
            }
            .ignoresSafeArea()
        }
    }
}

struct Onboarding1View_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding1View()
    }
}
