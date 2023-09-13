//
//  EnvelopeFilterView.swift
//  Keepi
//
//  Created by Kauane Santana on 12/09/23.
//

import SwiftUI

struct EnvelopeFilterView: View {
    @ObservedObject var envelopeListManager: EnvelopeListManager
    @ObservedObject var tradeListManager: TradeListManager
    @Environment(\.presentationMode) var presentationMode
    
//    @State var listTitleEnvelopeName: String
    
    var envelopeId: String
//    @State var listaFiltroStruct: ListaFiltro = ListaFiltro()
    
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
//
//                    Spacer()
//                        .frame(height: 46)
                    
                    ForEach(Array(tradeListManager.lista.enumerated()), id: \.element.id){ index, item in
                        if(item.envelopeId == envelopeId){
                            //                    Text(item.name)
                            TradeCardComponent(date: item.date, name: item.name, value: item.value, selectedTags: item.tag, envelopeName: item.envelopeId, feeling: item.feeling)
                                .padding(.horizontal,16)
                        }
                        
                        
                    }
                }
                .padding(.top, 145)
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
                })
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                Text(listTitleEnvelopeName)
//                    .font(.largeTitle.bold())
//                    .accessibilityAddTraits(.isHeader)
//            }
//        }
    }
}

//struct EnvelopeFilterView_Previews: PreviewProvider {
//    static var previews: some View {
//        EnvelopeFilterView()
//    }
//}
