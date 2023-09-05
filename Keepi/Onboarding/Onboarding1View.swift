//
//  Onboarding1View.swift
//  Keepi
//
//  Created by Julia Elice Jurczyszyn on 05/09/23.
//

import SwiftUI

struct Onboarding1View: View {
    let tela: CGFloat = 0
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                Image("backgroundOnboarding")
                    .resizable()
//                    .frame(width: 1572, height: 852)
                    .frame(width: proxy.size.width * 4, height: proxy.size.height)
                    .offset(x: -tela * proxy.size.width)
                    .ignoresSafeArea()
                
                //            // Circulo verde escuro
                //            Circle()
                //                .foregroundColor(Color("mainGreen"))
                //                .position(x: 400, y: 60)
                //                .frame(width: 800)
                //
                //            //Circulo claro em cima
                //            Circle()
                //                .foregroundColor(Color("lightGray"))
                //                .frame(width: 450)
                //                .position(x: 600, y: 0)
                //
                //            //Circulo verde claro vazado com stroke
                //            Circle()
                //                .stroke(lineWidth: 4)
                //                .foregroundColor(Color("secondGreen"))
                //                .frame(width: 70)
                //                .position(x: 390, y: 100)
                //
                //            //Circulo amarelo pequeno
                //            Circle()
                //                .foregroundColor(Color("yellow"))
                //                .frame(width: 30)
                //                .position(x: 500, y: 425)
                //
                //            //Circulo verde claro pequeno
                //            Circle()
                //                .foregroundColor(Color("secondGreen"))
                //                .frame(width: 20)
                //                .position(x: 460, y: 435)
                //
                //
                //            //Circulo amarelo vazado com stroke
                //            Circle()
                //                .stroke(lineWidth: 4)
                //                .foregroundColor(Color("yellow"))
                //                .frame(width: 200)
                //                .position(x: 250, y: 750)
                //
                //            //Circulo verde escuro menor sobre o circulo amarelo vazado
                //            Circle()
                //                .foregroundColor(Color("mainGreen"))
                //                .frame(width: 50)
                //                .position(x: 335, y: 700)
                //
                //            //Elipse no cantinho direito
                //            Ellipse()
                //                .foregroundColor(Color("mainGreen"))
                //                .frame(width: 2000, height: 1000)
                //                .position(x: 1500, y: 700)
                
                
                VStack {
                    Spacer()
                    
//                    Image("keepi")
//                        .resizable()
//                        .frame(maxWidth: .infinity)
//                        .scaledToFit()
//                        .padding(.horizontal, 300)
//                        .padding(.top, 100)
                    
                    Spacer()
                    
                    Text("Reflect the emotions of your currency trades.")
                        .foregroundColor(Color("mainGreen"))
                        .font(.system(size: 24))
                        .bold()
                        .frame(width: 350)
                        .padding(.bottom, 80)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
            }
        }
        .background(.yellow)
        .ignoresSafeArea()
        .frame(maxWidth: .infinity)
    }
}

struct Onboarding1View_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding1View()
    }
}
