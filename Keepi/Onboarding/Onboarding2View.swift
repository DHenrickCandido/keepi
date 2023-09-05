//
//  Onboarding2View.swift
//  Keepi
//
//  Created by Julia Elice Jurczyszyn on 05/09/23.
//

import SwiftUI

struct Onboarding2View: View {
    let tela: CGFloat = 1
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                Image("backgroundOnboarding")
                    .resizable()
//                    .frame(width: 1572, height: 852)
                    .frame(width: proxy.size.width * 4, height: proxy.size.height)
                    .offset(x: -tela * proxy.size.width)
                    .ignoresSafeArea()
                //            Color("lightGray")
                //                .ignoresSafeArea()
                //
                //            // Circulo verde escuro
                //            Circle()
                //                .foregroundColor(Color("mainGreen"))
                //                .position(x: 0, y: 60)
                //                .frame(width: 850)
                //
                //            //Circulo claro em cima
                //            Circle()
                //                .foregroundColor(Color("lightGray"))
                //                .frame(width: 450)
                //                .position(x: 120, y: 0)
                //
                //            //elipse grande verde escuro
                //            Ellipse()
                //                .foregroundColor(Color("mainGreen"))
                //                .frame(width: 2000, height: 1000)
                //                .position(x: 1107, y: 700)
                //
                //            //circulo verde claro vazado com stroke
                //            Circle()
                //                .stroke(lineWidth: 4)
                //                .foregroundColor(Color("secondGreen"))
                //                .frame(width: 150)
                //                .position(x: 620, y: 280)
              
            }
            
            VStack {
                Image("trades")
                
                Text("Here at Keepi, your purchases are referred to as trades.")
                    .font(.system(size: 24))
                    .bold()
                    .foregroundColor(.white)
                    .frame(width: 350)
                    .multilineTextAlignment(.center)
            }
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity)
    }
}

struct Onboarding2View_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding2View()
    }
}
