//
//  ContentView.swift
//  Keepi
//
//  Created by Diego Henrick on 25/08/23.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var userIsLoggedIn = false
//    @Binding var listTitleEnvelopeName: String
    var body: some View {
        if userIsLoggedIn {
            HomeView(tradeModel: TradeModel(id: "34", name: "Comida", value: 25, tag: []))
            
//            HomeView(tradeModel: TradeModel(id: "34", name: "Comida", value: 25, tag: []), listTitleEnvelopeName: $listTitleEnvelopeName)
                .environmentObject(TradeListManager())
                .environmentObject(EnvelopeListManager())
//            content
        } else {
            content
        }
        
    }
    var content: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Welcome to MyApp")
                .font(.largeTitle)
                .bold()
            
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            
            Button(action: {
                register()
            }) {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Text("OR")
            
            Button(action: {
                // Implement login functionality here
            }) {
                Text("Log In with Existing Account")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            Button(action: {
                anonymous()
            }) {
                Text("Continue as Guest")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            Spacer()
        }
                .onAppear(){
                    Auth.auth().addStateDidChangeListener { auth, user in
                        if user != nil {
                            userIsLoggedIn.toggle()
                        }
                    }
                }
                .padding()

    }
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
    
    func anonymous() {

        Auth.auth().signInAnonymously { authResult, error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
    

}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
//        LoginView(listTitleEnvelopeName: .constant("Uber"))
    }
}
