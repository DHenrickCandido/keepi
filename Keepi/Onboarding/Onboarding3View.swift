//
//  Onboarding3View.swift
//  Keepi
//
//  Created by Julia Elice Jurczyszyn on 05/09/23.
//

import SwiftUI

struct Onboarding3View: View {
    let tela: CGFloat = 2
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
                //            // elipse grande verde escuro
                //            Ellipse()
                //                .foregroundColor(Color("mainGreen"))
                //                .frame(width: 2000, height: 1000)
                //                .position(x: 500, y: 700)
                //
                //            //circulo verde claro vazado com stroke
                //            Circle()
                //                .stroke(lineWidth: 4)
                //                .foregroundColor(Color("secondGreen"))
                //                .frame(width: 150)
                //                .position(x: 0, y: 280)
                
                
            }
            VStack {
                Image("envelopes")
                
                Text("Use the envelopes to define the budget for each type of trade.")
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

struct Onboarding3View_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding3View()
    }
}
