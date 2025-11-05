//
//  AppUser.swift
//  InvestmentsManager
//
//  Created by José Carlos Cabrera Martínez on 11/3/25.
//

import Foundation
import FirebaseFirestore


struct AppUser: Identifiable, Codable {
    
    @DocumentID var id: String? // we will use FirebaseAuth.User.uid
    let email: String
    var displayName: String
    let createdAt: Date = Date() // by default true

}
 
