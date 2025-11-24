//
//  RegisterView.swift
//  InvestmentsManager
//
//  Created by José Carlos Cabrera Martínez on 11/3/25.
//



import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var errorMessage: String?
    @StateObject private var auth = AuthService.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Create Account")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Create your new account")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 16) {
                        TextField("Enter Email", text: $email)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password (Min 6 characters)", text: $password)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(25)
                        
                        TextField("Display Name", text: $displayName)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(25)
                    }
                    
                    Button("Sign Up") {
                        handleRegistration()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .font(.headline)
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .disabled(email.isEmpty || password.isEmpty || displayName.isEmpty)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(25)

                if let errorMessage = errorMessage {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("Error")
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                        Text(errorMessage)
                            .foregroundColor(.primary)
                            .font(.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(25)
                }

                Spacer()
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    private func handleRegistration() {
        guard Validators.isValidEmail(email) else {
            self.errorMessage = "Invalid Email"
            return
        }

        guard Validators.isValidPassword(password) else {
            self.errorMessage = "Invalid Password"
            return
        }

        guard !displayName.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.errorMessage = "Display Name is required"
            return
        }

        auth.signUp(email: email, password: password, displayName: displayName) { result in
            switch result {
            case .success:
                self.errorMessage = nil
            case .failure(let failure):
                self.errorMessage = failure.localizedDescription
            }
        }
    }
}

#Preview {
    NavigationView {
        RegisterView()
    }
}
