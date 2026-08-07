//
//  EnvelopeFilterView.swift
//  Keepi
//
//  Created by Kauane Santana on 12/09/23.
//

import SwiftUI

struct EnvelopeFilterView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var interactor: HomeInteractor
//    @State var listTitleEnvelopeName: String
    @State var selectedEnvelope: Int
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
                            
//                            Image(systemName: "trash")
//                                .font(.title)
//                                .foregroundColor(.red)
//                                .padding(16)


                            
                            
                            
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    
                    Spacer()
                }.ignoresSafeArea()
                
                
                
                ScrollView{
//
//                    Spacer()
//                        .frame(height: 46)
                    
                    ForEach(Array(interactor.listTransactions.enumerated()), id: \.element.id){ index, item in
                        if(item.envelopeId == envelopeId){
                            //                    Text(item.name)
                            TransactionCardComponent(date: item.date, name: item.name, value: item.value, envelopeName: interactor.getEnvelopeNameById(id: item.envelopeId), feeling: item.feeling, journalEntry: item.journalEntry)
                                .padding(.horizontal,16)
                        }
                        
                        
                    }
                }
                .padding(.top, 145)
            }
            .navigationBarBackButtonHidden(true)
        
            
            
            
        .ignoresSafeArea()
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
                },
            trailing:
                Image(systemName: "trash")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .font(.title2)
                .foregroundColor(.white)
                .onTapGesture {
                    self.presentationMode.wrappedValue.dismiss()
                    interactor.removeEnvelope(envelopeId: envelopeId)
                }
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(interactor.getEnvelopeNameById(id: envelopeId))
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

