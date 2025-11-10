//
//  InvestmentService.swift
//  InvestmentsManager
//
//  Created by José Carlos Cabrera Martínez on 11/3/25.
//

import Foundation
import FirebaseFirestore
class InvestmentService {
    static let shared = InvestmentService()
    private let db = Firestore.firestore()

    public func createInvestment(_ investment: Investment, completion: @escaping (Result<Investment,Error>)->Void) {
        var newInvestment = investment
        let userId = investment.userId
        if newInvestment.id == nil {
            newInvestment.id = UUID().uuidString
        }
        
        guard let investmentId = newInvestment.id else {
            return completion(.failure(SimpleError("Failed to create a new InvestmentID")))
        }
        
        do {
            try db.collection("users").document(userId)
                .collection("investments").document(newInvestment.id!)
                .setData(from: investment) { error in
                    if let error = error {
                        print(error.localizedDescription)
                        return completion(.failure(error))
                    }
                    completion(.success(newInvestment))
                    
                }
        } catch {
            completion(.failure(SimpleError("Unable to create investment")))
        }
        
    }

    func getInvestments(for userId: String, completion: @escaping (Result<[Investment], Error>) -> Void) {
        db.collection("users").document(userId)
            .collection("investments").getDocuments { snapshot, error in
                if let error = error {
                    return completion(.failure(error))
                }
                guard let snapshot = snapshot else {
                    return completion(.success([]))
                }
                
                do {
                    let investments = try snapshot.documents.map { doc in
                        try doc.data(as: Investment.self)
                    }
                    completion(.success(investments))
                } catch {
                    completion(.failure(error))
                }
            }

    }

    func updateInvestment(_ investment: Investment, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let investmentId = investment.id else {
            return completion(.failure(SimpleError("Investment ID is required")))
        }
        
        let userId = investment.userId
        do {
            try db.collection("users").document(userId)
                .collection("investments").document(investment.id!)
                .setData(from: investment) { error in
                    if let error = error {
                        print(error.localizedDescription)
                        return completion(.failure(error))
                    }
                    completion(.success(()))
                }
            
        } catch {
            completion(.failure(SimpleError("Unable to update investment")))
            
        }
        
    }
    func deleteInvestment(_ investment: Investment, completion: @escaping (Result<Void, Error>) -> Void) {
         guard let investmentId = investment.id else {
             return completion(.failure(SimpleError("Investment ID is required")))
         }
         
         let userId = investment.userId
         
         db.collection("users").document(userId)
             .collection("investments").document(investmentId).delete { error in
                 if let error = error {
                     print(error.localizedDescription)
                     return completion(.failure(error))
                 }
                 completion(.success(()))
             }
     }

}

