//
//  AuthService.swift
//  InvestmentsManager
//
//  Created by José Carlos Cabrera Martínez on 11/3/25.
//


import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore


class AuthService: ObservableObject {
    
    
    static let shared = AuthService() // Singleton Pattern
    @Published var currentUser: AppUser?
    
    // db reference
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    func signUp(email: String, password: String, displayName: String, completion: @escaping (Result<AppUser, Error>) -> Void) {
    
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
                return completion(.failure(error))
            }
            
            guard let user = result?.user else {
                print(result)
                return completion(.failure(SimpleError("No user found")))
            }
            
            let uid = user.uid
            let appUser = AppUser(id: uid, email: email, displayName: displayName)
            
            do {
                try self.db.collection("users").document(uid).setData(from: appUser) {
                    error in
                    if let error = error {
                        print(error.localizedDescription)
                        return completion(.failure(error))
                    }
                    
                    DispatchQueue.main.async {
                        self.currentUser = appUser
                    } // update in the main
                    
                    completion(.success(appUser))
                    
                }
            }catch {
                completion(.failure(SimpleError("Unable to create Profile")))
            }
            
            
        }
    }
    
    
    func logIn(email: String, password: String, completion: @escaping (Result<AppUser, Error>)-> Void) {
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                
                // fetch the user
                self.fetchCurrentUser { res in
                    switch res {
                        
                    case .failure(let failure):
                        completion(.failure(failure))
                        
                    case .success(let appUserObj):
                        if let appUser = appUserObj {
                            completion(.success(appUser))
                        }else {
                            // create a minimal record
                            let email = result?.user.email ?? "No Email Found"
                            let name = result?.user.displayName ?? "No Name Found"
                            let appUser = AppUser(email: email, displayName: name)
                            print("Attempting login with email: '\(email)', password length: \(password.count)")

                            // we will push a miniaml record object to the firestore
                            do {
                                try self.db.collection("users").document(user.uid).setData(from: appUser) {
                                    error in
                                    
                                    if let error = error {
                                        completion(.failure(error))
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.currentUser = appUser
                                    }
                                    completion(.success(appUser))
                                }
                            }catch {
                                completion(.failure(error))
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    
    // fetch current user
    
    func fetchCurrentUser(completion: @escaping (Result<AppUser?, Error>)-> Void){
        guard let uid = auth.currentUser?.uid else {
            DispatchQueue.main.async {
                self.currentUser = nil
                
            }
            
            return completion(.success(nil))
        }
        
        db.collection("users").document(uid).getDocument { snap, error in
            if let error = error { return completion(.failure(error)) }
            guard let snap = snap else { return completion(.success(nil)) }
            
            do {
                let user = try snap.data(as: AppUser.self)
                
                DispatchQueue.main.async { self.currentUser = user }
                completion(.success(user))
                
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    
    // updating the user name
    
    func updateProfile(displayName: String, completion: @escaping (Result<Void, Error>)-> Void) {
        guard let uid = auth.currentUser?.uid else {
            return completion(.success(()))
        } // if not uid is found it will be empty string
        
        db.collection("users").document(uid).updateData(["displayName": displayName]) { error in
            if let error = error {
                return completion(.failure(error))
            }else {
                self.fetchCurrentUser { _ in
                    completion(.success(()))
                }
            }
        }
        
    }
    
    
    // signout
    func signOut() -> Result<Void, Error> {
        do {
            try auth.signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
            }
            return .success(())
        } catch {
            print("Sign out error: \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    
}
 
