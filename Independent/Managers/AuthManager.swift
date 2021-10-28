//
//  AuthManager.swift
//  Independent
//
//  Created by Idan Levi on 25/10/2021.
//

import Foundation
import FirebaseAuth
import Combine

class AuthManager {
    
    static let shared = AuthManager()
    
    
    private init() {}
    
    func signIn(with credential: PhoneAuthCredential, complition: @escaping (Result<AuthDataResult?,Error>) -> Void) {
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                complition(.failure(error))
                return
            } else {
                complition(.success(nil))
            }
        }
    }
}
