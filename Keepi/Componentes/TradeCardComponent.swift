//
//  TradeCardComponent.swift
//  Keepi
//
//  Created by Kauane Santana on 30/08/23.
//

import SwiftUI

struct TradeCardComponent: View {
    @State var date: Date
    @State var name: String
    @State var value: Float
    @State var selectedTags: [Tag]
    @State var envelopeName: String
    
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
                        Text(name)
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(Color(.black))
                        
                        Text(envelopeName)
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
                            
                            
                            Text(String(format: "%.2f", value))
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
                            
                            Text(TradeListManager.date2string(date: date, dateFormat: "dd MMM"))
                            
                        
                        }
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
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
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .foregroundColor(Color(.systemGray))
        .cornerRadius(16)
    }
}

struct TradeCardComponent_Previews: PreviewProvider {
    static var previews: some View {
        TradeCardComponent(date: Date(), name: "teste", value: 25, selectedTags: [], envelopeName: "ifood")
    }
}
