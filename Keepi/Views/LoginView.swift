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
    var body: some View {
        if userIsLoggedIn {
            HomeView(tradeModel: TradeModel(name: "iFood", value: 25, tag: []))
                .environmentObject(TradeListManager())
//            content
        } else {
            content
        }
        
    }
    var content: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(.plain)
            
            SecureField("Password", text: $password)
                .textFieldStyle(.plain)
            
            Button {
                register()
            } label: {
                Text("Sign up")
                    .bold()
                    .frame(width: 200, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.blue)
                    )
                    .foregroundColor(.white)
            }
            
            Button {
                // login
            } label: {
                Text("Already have an account? Login")
                    .bold()
            }
            
            Button {
                anonymous()
            } label: {
                Text("anonymous")
                    .bold()
            }
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
    }
}
