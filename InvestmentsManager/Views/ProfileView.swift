//
//  ProfileView.swift
//  InvestmentsManager
//
//  Created by José Carlos Cabrera Martínez on 11/3/25.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject private var auth = AuthService.shared
    @State private var newName = ""
    @State private var errorText: String?
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Profile Information")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Manage your account details")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(auth.currentUser?.email ?? "-")
                            .font(.body)
                            .foregroundColor(.primary)
                            .textSelection(.enabled)
                            .padding(.vertical, 8)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display Name")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(auth.currentUser?.displayName ?? "-")
                            .font(.body)
                            .foregroundColor(.primary)
                            .textSelection(.enabled)
                            .padding(.vertical, 8)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Update Display Name")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Change how your name appears")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    TextField("Enter new display name", text: $newName)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(25)
                    
                    Button(action: saveName) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Save Changes")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                    }
                    .disabled(isLoading || newName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)

                if let errorText {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("Error")
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                        Text(errorText)
                            .foregroundColor(.primary)
                            .font(.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(25)
                }


                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Account Actions")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Manage your account session")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(role: .destructive) {
                        signOut()
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(25)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Profile")
        .background(Color(.systemGroupedBackground))
        .onAppear {
            auth.fetchCurrentUser { _ in }
        }
    }

    private func saveName() {
        guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorText = "Display name cannot be empty"
            return
        }

        isLoading = true
        auth.updateProfile(displayName: newName) { result in
            isLoading = false
            switch result {
            case .success:
                newName = ""
                errorText = nil
            case .failure(let err):
                errorText = err.localizedDescription
            }
        }
    }

    private func signOut() {
        let result = auth.signOut()
        if case .failure(let err) = result {
            errorText = err.localizedDescription
        } else {
            errorText = nil
        }
    }
}

#Preview {
    NavigationView {
        ProfileView()
    }
}
