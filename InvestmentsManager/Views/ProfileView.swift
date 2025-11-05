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
 
    var body: some View {
        Form {
            Section("Profile") {
                Text("Email: \(auth.currentUser?.email ?? "-")")
                Text("Display Name: \(auth.currentUser?.displayName ?? "-")")
                Text("Active: \(auth.currentUser?.isActive == true ? "Yes" : "No")")
            }
 
            Section("Update Display Name") {
                TextField("New Display Name", text: $newName)
 
                Button("Save") {
                    guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else {
                        errorText = "Display name cannot be empty"
                        return
                    }
 
                    auth.updateProfile(displayName: newName) { result in
                        switch result {
                        case .success:
                            newName = ""
                            errorText = nil
                        case .failure(let err):
                            errorText = err.localizedDescription
                        }
                    }
                }
            }
 
            if let errorText {
                Text(errorText)
                    .foregroundColor(.red)
            }
 
            Button(role: .destructive, action: {
                let result = auth.signOut()
                if case .failure(let err) = result {
                    errorText = err.localizedDescription
                } else {
                    errorText = nil
                }
            }) {
                Text("Sign Out")
            }
        }
        .onAppear {
            auth.fetchCurrentAppUser { _ in }
        }
    }
}
 
#Preview {
    ProfileView()
}
