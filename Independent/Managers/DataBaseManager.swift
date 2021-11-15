//
//  DataBaseManager.swift
//  Independent
//
//  Created by Idan Levi on 25/10/2021.
//

import Foundation
import Firebase
import Combine
import UIKit

class DataBaseManager {
    
    private let db = Firestore.firestore()
    static let shared = DataBaseManager()
    
    @Published var allUsers = [String]()
    @Published var isLoading: Bool = false
    
    private init() {}
    
    func saveUser(userName: String, phone: String, complition: @escaping (Result <Void,Error>) -> Void) {
        if allUsers.contains(phone) {
            complition(.success(()))
            return
        }
        db.collection("Users").document(userName).setData(["phone": phone]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    complition(.failure(error))
                } else {
                    complition(.success(()))
                }
            }
        }
    }
    
    func loadData(collection: String) {
        isLoading = true
        db.collection(collection).getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else {return}
            self.isLoading = false
            DispatchQueue.main.async {
                if let e = error {
                    print(e)
                    return
                }
                if let query = querySnapshot {
                    for document in query.documents {
                        let user = document.get("phone") as? String
                        if let user = user {
                            self.allUsers.append(user)
                        }
                    }
                }
            }
        }
    }
}
