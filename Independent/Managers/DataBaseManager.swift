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
    
    func saveLead(lead: Lead, userName: String, complition: @escaping (Result<Void, Error>)-> Void) {
        db.collection("lead").document(userName).collection("lead").document(String(lead.leadID)).setData(["name": lead.fullName, "phone": lead.phoneNumber, "summry": lead.summary, "date": lead.date, "status": lead.status.statusString]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    complition(.failure(error))
                } else {
                    complition(.success(()))
                }
            }
        }
    }
    
    func updateLeadStatus(lead: Lead, userName: String, status: String, complition: @escaping (Result<Void, Error>)-> Void) {
        db.collection("lead").document(userName).collection("lead").document(String(lead.leadID)).updateData(["status": status]) { error in
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
    
    func loadLeadCollection(userId: String, complition: @escaping (Result<[Lead], Error>)-> Void) {
        var leads = [Lead]()
        isLoading = true
        db.collection("lead").document(userId).collection("lead").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else {return}
            self.isLoading = false
            DispatchQueue.main.async {
                if let error = error {
                    complition(.failure(error))
                    return
                }
                if let query = querySnapshot {
                    for document in query.documents {
                        let leadID = document.documentID
                        if let name = document.get("name") as? String,
                           let phone = document.get("phone") as? String,
                           let summary = document.get("summry") as? String,
                           let statusString = document.get("status") as? String,
                           let timeStamp = document.get("date") as? Timestamp {
                           let date = timeStamp.dateValue()
                            var status = Status.open
                            if statusString == "פתוח" {
                                status = .open
                            } else if statusString == "סגור" {
                                status = .closed
                            } else if statusString == "עסקה" {
                                status = .deal
                            }
                            let newLead = Lead(fullName: name, date: date, summary: summary, phoneNumber: phone, leadID: Int(leadID) ?? 0, status: status)
                            leads.append(newLead)
                        }
                    }
                }
                complition(.success(leads))
            }
        }
    }
    
    func deleteLead(leadId: String, userID: String, complition: @escaping (Result<Void, Error>)-> Void) {
        db.collection("lead").document(userID).collection("lead").document(leadId).delete() { error in
            if let error = error {
                complition(.failure(error))
            } else {
                complition(.success(()))
            }
        }
    }
}
