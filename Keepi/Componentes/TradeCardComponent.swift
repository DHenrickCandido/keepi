//
//  TradeCardComponent.swift
//  Keepi
//
//  Created by Kauane Santana on 30/08/23.
//

import SwiftUI

struct TradeCardComponent: View {
    var date: Date
    var name: String
    var value: Float
    var selectedTags: [Tag]
    var envelopeName: String
    var feeling: Int
    var body: some View {
        VStack{
            HStack(spacing: 18){
                //icon
                VStack{
                    //img aqui
                    Image("feeling\(feeling)")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        
                        
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
                        
                        Text(envelopeName)
                            .font(.subheadline)
                            .foregroundColor(Color(.systemGray))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 24){
                        HStack{
                            //img aqui
                            ZStack{
                                Text("$")
                                    .font(.footnote)
                                    .foregroundColor(Color("darkGreenKeepi"))
                            }
                            
                            
                            Text(String(format: "%.2f", value))
                                .font(.footnote)

                        }
                        .frame(width: 80, alignment: .leading)

                        
                        HStack(spacing: 4){
                            //img aqui
                            ZStack{
                                Image(systemName: "calendar")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color("darkGreenKeepi"))
                            }
                            
                            Text(TradeListManager.date2string(date: date, dateFormat: "dd MMM"))
                                .font(.footnote)
                        
                        }
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                    
                    HStack(alignment: .center, spacing: 8){
                        ScrollView (.horizontal, showsIndicators: false){
                            HStack {
                                ForEach(selectedTags) { tag in
                                    TagComponent(selectedTag: tag)
                                }
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
        .background(Color(.white))
        .foregroundColor(Color(.systemGray))

        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)

    }
}

struct TradeCardComponent_Previews: PreviewProvider {
    static var previews: some View {
        TradeCardComponent(date: Date(), name: "teste", value: 25, selectedTags: [], envelopeName: "ifood", feeling: 4)
    }
}
