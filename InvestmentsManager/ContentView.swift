//
//  ContentView.swift
//  InvestmentsManager
//
//  Created by José Carlos Cabrera Martínez on 11/3/25.
//


import SwiftUI

struct ContentView: View {
    
    @StateObject private var auth = AuthService.shared
    @State private var isLoaded = false
    
    
    var body: some View {
        Group{
            
            if !isLoaded{
                ProgressView()
                    .onAppear {
                        auth.getCurrentAppUser{ _ in
                            isLoaded = true
                        }
                    }
            }else if auth.currentUser ==  nil {
                // Auth page
                AuthGate()
            } else {
                // Profile Page
                ProfileView()
            }
            
        }
        
    }
}

#Preview {
    ContentView()
}

 
