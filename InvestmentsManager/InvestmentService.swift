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

    public func createInvestment(_ investment: Investment, userId: String, completion: @escaping (Result<Void,Error>)->Void) {
        do {
            try db.collection("users").document(userId)
                .collection("investments").document(investment.id.uuidString)
                .setData(from: investment) { error in
                    if let error = error {
                        print(error.localizedDescription)
                        return completion(.failure(error))
                    }
                    completion(.success((())))
                    
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

    func updateInvestment(_ investment: Investment, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("users").document(userId)
                .collection("investments").document(investment.id.uuidString)
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
    func deleteInvestment(withId id: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("users").document(userId)
            .collection("investments").document(id).delete { error in
                if let error = error {
                    print(error.localizedDescription)
                    return completion(.failure(error))
                }
                
                completion(.success(()))
            }
    }


}

