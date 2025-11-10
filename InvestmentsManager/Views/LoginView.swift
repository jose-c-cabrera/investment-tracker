//
//  LoginView.swift
//  InvestmentsManager
//
//  Created by José Carlos Cabrera Martínez on 11/3/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var errorMessage: String?
    
    @StateObject private var auth = AuthService.shared
    
    
    var body: some View {
        displayLoginForm()
    }
    
    private func displayLoginForm() -> some View{
        Form{
            Section("Login") {
                TextField("Enter Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                
                SecureField("Password (Min 6 characters)", text: $password)
                
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
            
            
            Button("Login"){
                handleAuthentication()
            }
            .disabled(email.isEmpty || password.isEmpty)
        }
    }


    private func handleAuthentication(){
        // validations
        guard Validators.isValidEmail(email) else {
            self.errorMessage = "Invalid Email"
            return
        }
        
        guard Validators.isValidPassword(password) else {
            self.errorMessage = "Invalid Passwrd"
            return
        }
        
        // auth.sign up
        auth.logIn(email: email, password: password) { result in
            switch result {
            case .success:
                errorMessage = nil
            case .failure(let err):
                errorMessage = err.localizedDescription
                
                
            }
        }
    }

}


#Preview {
    LoginView()
}
