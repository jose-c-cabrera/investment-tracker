//
//  AuthGate.swift
//  InvestmentsManager
//
//  Created by José Carlos Cabrera Martínez on 11/3/25.
//

import SwiftUI
 
struct AuthGate: View {
    
    @State private var showLogin = true
 
    var body: some View {
        VStack{
            Picker("", selection: $showLogin) {
                Text("Login").tag(true)
                Text("Sign Up").tag(false)
            }
            .pickerStyle(.segmented)
            .padding()
            
            
            if showLogin {
                // Login View
                LoginView()
            }else {
                // Register view
                RegisterView()
            }
        }
    }
}
 
#Preview {
    AuthGate()
}
