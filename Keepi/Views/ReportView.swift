//
//  ReportView.swift
//  Keepi
//
//  Created by Diego Henrick on 14/09/23.
//

import SwiftUI

struct ReportView: View {
    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject var interactor: HomeInteractor
    
    var body: some View {
        ZStack{
            VStack {
                
                ZStack (alignment: .leading) {
                    Rectangle()
                        .frame(height: 240)
                        .foregroundColor(Color("darkGreenKeepi"))
                        .roundedCorner(16, corners: [.bottomLeft, .bottomRight])
                    
                    
                    
                    HStack (alignment: .top) {
//                            Image(systemName: "chevron.backward")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(height: 40)
                        
                        Spacer()
                        
//                        Image(systemName: "clipboard.fill")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(height: 56)
//                            .foregroundColor(.white)
//                            .padding(.trailing,8)
//                            .onTapGesture {
//                                self.presentationMode.wrappedValue.dismiss()
//                            }
                        Image("keepiMascote")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 120)
                        
                        
                    }
                    .padding(.horizontal, 16)
                }
                
                
                Spacer()
            }.ignoresSafeArea()
            
            
            
            ScrollView{
                MostTradesView()
                    .environmentObject(HomeInteractor(tradeListManager: TradeListManager(), envelopeListManager: EnvelopeListManager()))
            }
            .padding(.top, 154)
        }
        .navigationBarBackButtonHidden(true)
    
        
        
        
    .ignoresSafeArea()
    .onTapGesture {
        print("cheguei")
    }
    
    .navigationBarItems(leading:
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.vertical, 244)
            })
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
        ToolbarItem(placement: .principal) {
            VStack {
                Text("These are your tendencies ")
                    .foregroundColor(.white)
                    .font(.title)
                    .fontWeight(.bold)
                .accessibilityAddTraits(.isHeader)
            }
            .padding(.vertical, 244)

        }
        
    }
}

}


struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView()
    }
}
