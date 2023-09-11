//
//  NewTradeView.swift
//  Keepi
//
//  Created by Andrea Oquendo on 30/08/23.
//

import SwiftUI
import Combine

struct Example_test: View {
    
    @State private var showNewEnvelope: Bool = false
    
    var body: some View {
        Button("click me") {
            showNewEnvelope.toggle()
        }
        .sheet(isPresented: $showNewEnvelope){
//            NewEnvelopeView(envelopeListManager: envelopeListManager, showNewEnvelope: $showNewEnvelope)
//                .presentationDetents([.fraction(0.9)])
//                .interactiveDismissDisabled()
        }
        .onAppear{
            showNewEnvelope = true
        }
    }
}

func QuestionText(text: String) -> some View {
    Text(text)
        .font(.headline)
        .bold()
}

struct Example_test_Previews: PreviewProvider {
    static var previews: some View {
        Example_test()
    }
}

struct NewEnvelopeView: View {
    
    @ObservedObject var envelopeListManager: EnvelopeListManager
    
    @Binding var showNewEnvelope: Bool
    
    @State var iconSelected: String = Icons.getIcons()[0]
    @State var envelopeName: String = ""
    @State var envelopeBudget: String = ""
    @State private var selectedTheme = "Dark"
    
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
                                        ForEach(Icons.getIcons(), id: \.self) { img in
                                            let isActive = ( img == iconSelected )
                                            IconEnvelopeOption(img:img, active: isActive)
                                                    .onTapGesture {
                                                        
                                                        iconSelected = img
                                                        print(iconSelected)
                                                    }
                                            
                                        }
                                        
                                    }
                                }

                                
                            }
                            }
                        }
                    
                }
                .padding(10)
                
                AddEnvelopeButton()
                
//                HStack(alignment: .top, spacing: 10) {
//                    Text("Add Envelope")
//                        .font(.headline)
//                        .bold()
//                }
//                .padding(.horizontal, 32)
//                .padding(.vertical, 16)
//                .frame(maxWidth: .infinity, alignment: .top)
//                .background(Color(red: 0.9, green: 0.9, blue: 0.92))
//                .cornerRadius(100)
            }
            .padding(10)
                
            
            .padding(.top, 16)
        }
    }
    
    func saveEnvelope() {
        let valueFloat = Float(envelopeBudget)
        let id = envelopeName.replacingOccurrences(of: " ", with: "")

        let envelope = EnvelopeModel(id: id, name: envelopeName, budget: valueFloat ?? 0, icon: iconSelected)
        print(envelope)
        envelopeListManager.addEnvelope(envelope: envelope)
        envelopeListManager.fetchEnvelopes()

        // Fechar a modal
        showNewEnvelope.toggle()
    }


    func AddEnvelopeButton() -> some View {
        HStack(alignment: .top, spacing: 10) {
            QuestionText(text: "Add Envelope")
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(red: 0.9, green: 0.9, blue: 0.92))
        .cornerRadius(100)
        .onTapGesture {
            saveEnvelope()
        }
    }
    
    func IconEnvelopeOption(img: String, active: Bool) -> some View {
        Image(img)
            .foregroundColor(.clear)
            .frame(width: 72, height: 72)
            .background(active ? .black : Color(red: 0.85, green: 0.85, blue: 0.85) )
            .cornerRadius(100)
            
    }
}

