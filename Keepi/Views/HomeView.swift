//
//  HomeView.swift
//  Keepi
//
//  Created by Diego Henrick on 30/08/23.
//

import SwiftUI

struct HomeView: View {
    var userName: String = "Jujuba"
    var body: some View {
        HStack{
            VStack{
                VStack{
                    HStack(){
                        Text("Hello, \(userName)!")
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                        
                    }
                    HStack{
                        Text("Any interesting trades today?")
                            .foregroundColor(Color(UIColor.systemGray))
                        Spacer()
                    }
                }.padding(.horizontal, 32)
                Divider()

                HStack{
                    VStack {
                        HStack{
                            Text("My envelopes")
                                .font(.title3)
                                .bold()
                            Spacer()
                        }
                        
                        ScrollView (.horizontal, showsIndicators: false){
                            HStack{
                                ForEach(0..<2) {_ in
                                    EnvelopeCardView(icon: "birthday.cake.fill", name: "iFood", budget: 200.0)
                                }
                                NewEnvelopeButtonView()

                            }
                        }
                        Spacer()
                    }
                }.padding(.horizontal)
                    

                 
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
