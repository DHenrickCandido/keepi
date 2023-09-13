//
//  SplashScreenView.swift
//  Keepi
//
//  Created by Julia Elice Jurczyszyn on 12/09/23.
//

import SwiftUI

struct SplashScreenView: View {
    
    // Animacao logo
    @State var rotation = 0.0
    @State var scaleXY = 1.0
    
    //animacao bola
    @State var positionY = 0
    @State var opacity = 0.0
    
    //animacao sapo
    @State var maskPositionY = 280
    @State var maskOpacity = 1.0
    
    var body: some View {
        ZStack {
            Color("mainGreen")
            
            Image("sapoFeliz")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 200)
                .offset(y: CGFloat(maskPositionY))
                .animation(.easeInOut(duration: 2), value: maskPositionY)
                .onAppear() {
                    maskPositionY = 210
                }
            
                
            
            Color("secondGreen")
                .reverseMask {
                    Circle()
                        .frame(width: 1000)
                        .offset(y: CGFloat(positionY))
                        .opacity(CGFloat(opacity))
                        .animation(.easeInOut(duration: 2), value: opacity)
                        .onAppear() {
                            positionY -= 280
                            opacity = 1.0
                        }
                }
                
            
            Image("keepi")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 100)
                .rotationEffect(.degrees(rotation))
                .scaleEffect(CGFloat(scaleXY))
                .animation(.easeInOut(duration: 1.5), value: scaleXY)
                .onAppear() {
                    rotation += 360
                    scaleXY += 1.1
                }
                .offset(y: -50)
        } //chave zstack
        .ignoresSafeArea()
    }
}






struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
