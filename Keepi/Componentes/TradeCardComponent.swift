//
//  TradeCardComponent.swift
//  Keepi
//
//  Created by Kauane Santana on 30/08/23.
//

import SwiftUI

struct TradeCardComponent: View {
    @State var current_date = Date()
    
    var body: some View {
        VStack{
            HStack(spacing: 18){
                //icon
                VStack{
                    //img aqui
                    Circle()
                        .frame(width: 48, height: 48)
                        
                        
                }
                .frame(width: 90, height: 94)
                .background(.white)
                .cornerRadius(10)
                
                //info da compra
                VStack (spacing: 8){
                    VStack (alignment: .leading){
                        Text("Name")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(Color(.black))
                        
                        Text("envelope")
                            .font(.subheadline)
                            .foregroundColor(Color(.systemGray))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 24){
                        HStack{
                            //img aqui
                            ZStack{
                                Circle()
                                    .fill(.white)
                                    .frame(width: 20, height: 20)
                                Text("$")
                            }
                            
                            
                            Text("valor")
                        }
                        
                        HStack{
                            //img aqui
                            ZStack{
                                Circle()
                                    .fill(.white)
                                    .frame(width: 20, height: 20)
                                Image(systemName: "calendar")
                                    .font(.system(size: 12))
                            }
                            
                            Text("18/08/2023")
                            
                        
                        }
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                    HStack(alignment: .center, spacing: 8){
                        ScrollView (.horizontal){
                            HStack {
                                TagComponent()
                                
                            }
                            
                        }
                            
                    }
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .foregroundColor(Color(.systemGray))
        .cornerRadius(16)
    }
}

struct TradeCardComponent_Previews: PreviewProvider {
    static var previews: some View {
        TradeCardComponent()
    }
}
