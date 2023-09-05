//
//  Onboarding4View.swift
//  Keepi
//
//  Created by Julia Elice Jurczyszyn on 05/09/23.
//

import SwiftUI

struct Onboarding4View: View {
    let tela: CGFloat = 3
    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { proxy in
                    Image("backgroundOnboarding")
                        .resizable()
                        .frame(width: 1572, height: 852)
                    
                        .frame(width: proxy.size.width * 4, height: proxy.frame(in: .named("navstack")).height)
                        .offset(x: -tela * proxy.size.width)
                        .ignoresSafeArea()
                    //                Color("lightGray")
                    //                    .ignoresSafeArea()
                    //
                    //                //elipse grande verde escuro
                    //                Ellipse()
                    //                    .foregroundColor(Color("mainGreen"))
                    //                    .frame(width: 2000, height: 1000)
                    //                    .position(x: 300, y: 700)
                    
                    
                    
                }
                VStack {
                    Image("emotions")
                    
                    Text("Register and reflect on what motivated you to make a trade.")
                        .font(.system(size: 24))
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 350)
                        .multilineTextAlignment(.center)
                    
                    NavigationLink {
                        LoginView()
                    } label: {
                        Text("Get Started \(Image(systemName: "arrow.forward"))")
                            .font(.system(size: 24))
                    }
                }
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity)
        .coordinateSpace(name: "navstack")
    }
}

struct Onboarding4View_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding4View()
    }
}
