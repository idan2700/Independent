//
//  DataBaseManager.swift
//  Independent
//
//  Created by Idan Levi on 25/10/2021.
//

import Foundation
import Firebase
import Combine

class DataBaseManager {
    
    private let db = Firestore.firestore()
    static let shared = DataBaseManager()
    
    @Published var allUsers = [String]()
    @Published var isLoading: Bool = false
    
    private init() {}
    
    func saveUser(user: String, complition: @escaping (Result <String?,Error>) -> Void) {
        if allUsers.contains(user) {
            complition(.success(nil))
            return
        }
        db.collection("AllUsers").addDocument(data: ["user": user]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    complition(.failure(error))
                } else {
                    complition(.success(nil))
                }
            }
        }
    }
    
    func loadData() {
        isLoading = true
        db.collection("AllUsers").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else {return}
            self.isLoading = false
            DispatchQueue.main.async {
                if let e = error {
                    print(e)
                    return
                }
                if let query = querySnapshot {
                    for document in query.documents {
                        let user = document.get("user") as? String
                        if let user = user {
                            self.allUsers.append(user)
                        }
                    }
                }
            }
        }
    }
}
