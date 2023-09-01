//
//  NewTradeView.swift
//  Keepi
//
//  Created by Andrea Oquendo on 30/08/23.
//

import SwiftUI
import Combine

struct Example: View {
    
    @State private var showNewEnvelope: Bool = false
    
    
    var body: some View {
        Button("click me") {
            showNewEnvelope.toggle()
        }
        .sheet(isPresented: $showNewEnvelope){
            NewEnvelopeView(showNewEnvelope: $showNewEnvelope)
                .presentationDetents([.fraction(0.9)])
                .interactiveDismissDisabled()
        }
        .onAppear{
            showNewEnvelope = true
        }
    }
}

struct Example_Previews: PreviewProvider {
    static var previews: some View {
        Example()
    }
}

struct NewEnvelopeView: View {
    
    @Binding var showNewEnvelope: Bool
    @State var iconSelected: Int = 0
    @State var envelopeName: String = ""
    @State var envelopeBudget: String = ""
    @State private var selectedTheme = "Dark"
    let tags = [
        "Estava com vontade",
        "Estava com amigos",
        "Eu precisava",
        "Não pensei muito sobre",
        "Estava em promoção",
        "Outro"
    ]
    let themes = ["iFood", "Vida Social", "Outros"]
    
    let columns = [GridItem(), GridItem(), GridItem(), GridItem()]
    
    
    var body: some View {
        ZStack{
            VStack(spacing:10){
                
                ZStack(){
                    
                    VStack(alignment: .center, spacing: 0) {
                        Text("New Envelope")
                            .font(.title2)
                            .bold()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 15)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .bold()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 15)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .onTapGesture {
                        showNewEnvelope.toggle()
                    }
                    
                }
                
                
                
                VStack(spacing: 32){
                    
                    
                    // Qual sua Troca + TextField
                    VStack (alignment: .leading) {
                        Text("Name of the envelope?")
                            .font(.headline)
                            .bold()
                        
                        HStack(alignment: .top, spacing: 10) {
                            TextField("Ex. Food, Clothes, Transportation", text: $envelopeName)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(54)
                        .overlay(
                            RoundedRectangle(cornerRadius: 54)
                                .inset(by: 0.5)
                                .stroke(Color(red: 0.56, green: 0.56, blue: 0.58), lineWidth: 1)
                        )
                        
                        Text("Budget for this envelope?")
                            .font(.headline)
                            .bold()
                            .padding(.top, 24)
                        
                        HStack(alignment: .top, spacing: 10) {
                            TextField("Ex. 200.00", text: $envelopeBudget)
                                .keyboardType(.decimalPad)
                                .onReceive(Just(envelopeBudget)) { newValue in
                                    let filtered = newValue.filter { "0123456789".contains($0) }
                                    if filtered != newValue {
                                        self.envelopeBudget = filtered
                                    }
                                }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(54)
                        .overlay(
                            RoundedRectangle(cornerRadius: 54)
                                .inset(by: 0.5)
                                .stroke(Color(red: 0.56, green: 0.56, blue: 0.58), lineWidth: 1)

                        )
                    }
                    
                    
                    
                    // Divider
                    VStack(){}
                    .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
                    .background(Color(red: 0.56, green: 0.56, blue: 0.58))
                    
                    // Icon
                    VStack(alignment: .leading, spacing:24){
                        Text("Select an icon?")
                            .font(.headline)
                            .bold()
                        HStack(){
                            NavigationStack {
                                ScrollView {
                                    LazyVGrid(columns:columns) {
                                        ForEach(0..<8, id: \.self) { index in
                                            let isActive = ( index == iconSelected )
                                                EmotionOption(active: isActive)
                                                    .onTapGesture {
                                                        iconSelected = index
                                                    }
                                            
                                        }
                                        
                                    }
                                }

                                
                            }
                            }
                        }
                    
                }
                .padding(10)
                
                HStack(alignment: .top, spacing: 10) {
                    Text("Add Envelope")
                        .font(.headline)
                        .bold()
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .top)
                .background(Color(red: 0.9, green: 0.9, blue: 0.92))
                .cornerRadius(100)
            }
            .padding(10)
            .padding(.top, 16)
        }
    }
    func EmotionOption(active: Bool) -> some View {
        Rectangle()
            .foregroundColor(.clear)
            .frame(width: 72, height: 72)
            .background(active ? .black : Color(red: 0.85, green: 0.85, blue: 0.85) )
            .cornerRadius(100)
            
    }
}

