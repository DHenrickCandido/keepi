//
//  NewTradeView.swift
//  Keepi
//
//  Created by Andrea Oquendo on 30/08/23.
//

import SwiftUI

struct Example: View {
    
    @State private var showNewTrade: Bool = false
    
    
    var body: some View {
        Button("click me") {
            showNewTrade.toggle()
        }
        .sheet(isPresented: $showNewTrade){
            NewTradeView(showNewTrade: $showNewTrade)
                .presentationDetents([.fraction(0.8)])
                .interactiveDismissDisabled()
        }
        .onAppear{
            showNewTrade = true
        }
    }
}

struct Example_Previews: PreviewProvider {
    static var previews: some View {
        Example()
    }
}

struct NewTradeView: View {
    
    @Binding var showNewTrade: Bool
    
    @State var compraTitulo: String = ""
    @State var value: String = ""
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
    
    var body: some View {
        ZStack{
            VStack(spacing:10){
                
                ZStack(){
                    
                    VStack(alignment: .center, spacing: 0) {
                        Text("Nova Troca")
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
                        showNewTrade.toggle()
                    }
                    
                }
                
                
                
                VStack(spacing: 32){
                    
                    
                    // Qual sua Troca + TextField
                    VStack (alignment: .leading) {
                        Text("Qual sua troca?")
                            .font(.headline)
                            .bold()
                        
                        HStack(alignment: .top, spacing: 10) {
                            TextField("Ex. Comidas, Roupas, Transporte", text: $compraTitulo)
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
                    
                    // Envelope + Qual valor
                    HStack(){
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Envelope")
                                .font(.headline)
                                .bold()
                            HStack(alignment: .center){
                                Picker("Select", selection: $selectedTheme) {
                                    ForEach(themes, id: \.self) {
                                        Text("\($0)                      ")
                                    }
                                }
                                .pickerStyle(.menu)
                                .accentColor(.black)
                
                                
                                
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .cornerRadius(54)
                            .overlay(
                                RoundedRectangle(cornerRadius: 54)
                                .inset(by: 0.5)
                                .stroke(Color(red: 0.56, green: 0.56, blue: 0.58), lineWidth: 1)
                            )
                        }
                        .padding(0)
                        .frame(width: 171, alignment: .topLeading)
                        
                        Spacer()
                        VStack(alignment: .leading, spacing:16){
                            Text("Qual valor?")
                                .font(.headline)
                                .bold()
                            
                            HStack(alignment: .top, spacing: 10) {
                                TextField("Ex. 25,00", text: $value)
                                    .keyboardType(.decimalPad)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(width: 150, alignment: .topLeading)
                            .cornerRadius(54)
                            .overlay(
                              RoundedRectangle(cornerRadius: 54)
                                .inset(by: 0.5)
                                .stroke(Color(red: 0.56, green: 0.56, blue: 0.58), lineWidth: 1)
                            )
                        }
                    }
                    
                    // Divider
                    VStack(){}
                    .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
                    .background(Color(red: 0.56, green: 0.56, blue: 0.58))
                    
                    // Feelings section
                    VStack(alignment: .leading, spacing:24){
                        Text("Como se sentiu com essa troca?")
                            .font(.headline)
                            .bold()
                        HStack(){
                            ForEach(0..<5, id: \.self) { index in
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 40, height: 40)
                                    .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                                    .cornerRadius(100)
                                if index != 4 {
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 24){
                        Text("Qual sua principal motivação?")
                            .font(.headline)
                            .bold()
                        
                        ScrollView(.horizontal){
                            HStack(alignment: .top, spacing: 9) {
                                
                                ForEach(tags, id: \.self) { tag in
                                    Text(tag)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .cornerRadius(32)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 32)
                                                .inset(by: 0.5)
                                                .stroke(Color(red: 0.56, green: 0.56, blue: 0.58), lineWidth: 1)
                                        )
                                }
                                
                            }
                            .padding(0)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            
                        }
                    }
                }
                .padding(10)
                
                HStack(alignment: .top, spacing: 10) {
                    Text("Adicionar troca")
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
}
