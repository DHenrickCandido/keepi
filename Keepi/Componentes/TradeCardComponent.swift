//
//  TradeCardComponent.swift
//  Keepi
//
//  Created by Kauane Santana on 30/08/23.
//

import SwiftUI

struct TradeCardComponent: View {
    @State var current_date = Date()
    @State var name: String
    @State var value: Float
    @State var selectedTags: [Tag]
    
    var body: some View {
        VStack{
            HStack(spacing: 18){
                //icon
                VStack{
                    //img aqui
                    Image("feeling04")
                        
                        
                }
                .frame(width: 70, height: 108)
                .background(Color("lightGrayKeepi"))
                .cornerRadius(12)
                
                //info da compra
                VStack (spacing: 8){
                    VStack (alignment: .leading){
                        Text(name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color("blackKeepi"))
                        
                        Text("envelope")
                            .font(.subheadline)
                            .foregroundColor(Color(.systemGray))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 24){
                        HStack(spacing: 4){
                            //img aqui
                            ZStack{
                                Text("$")
                                    .font(.footnote)
                                    .foregroundColor(Color("darkGreenKeepi"))
                            }
                            
                            
                            Text(String(format: "%.2f", value))
                                .font(.footnote)
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
                        ScrollView (.horizontal, showsIndicators: false){
                            HStack {
//                                ForEach(selectedTags) { tag in
//                                    TagComponent(selectedTag: tag)
//                                }
                                // Comentado apenas para Interface (recolocar depois)
                                
                                VStack {
                                    Text("Texto teste")
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white)
                                .cornerRadius(4)
                            
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
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .foregroundColor(Color(.systemGray))
        .cornerRadius(16)
    }
}

struct TradeCardComponent_Previews: PreviewProvider {
    static var previews: some View {
        TradeCardComponent(name: "teste", value: 25, selectedTags: [])
    }
}
