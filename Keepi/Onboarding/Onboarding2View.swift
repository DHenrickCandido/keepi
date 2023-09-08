//
//  Onboarding2View.swift
//  Keepi
//
//  Created by Julia Elice Jurczyszyn on 05/09/23.
//

import SwiftUI

struct Onboarding2View: View {
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("mainGreen")
                
                //ELEMENTOS DE ENFEITE
                Circle()
                    .stroke(lineWidth: 4)
                    .foregroundColor(Color("secondGreen"))
                    .opacity(0.7)
                    .frame(width: 250)
                    .offset(x: 180, y: -120)
                
                Circle()
                    .foregroundColor(Color("secondGreen"))
                    .frame(width: 40)
                    .offset(x: 60, y: -145)
                
                Circle()
                    .stroke(lineWidth: 4)
                    .foregroundColor(Color("yellow"))
                    .opacity(0.7)
                    .frame(width: 150)
                    .offset(x: -170, y: 300)
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
                
                Image("trades")
                    .offset(y: -50)
                
                
                Text("Here at Keepi, your purchases are referred to as trades.")
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

struct Onboarding2View_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding2View()
    }
}
