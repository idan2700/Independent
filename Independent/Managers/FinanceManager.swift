//
//  FinanceManager.swift
//  Independent
//
//  Created by Idan Levi on 10/12/2021.
//

import Foundation
import Firebase

class FinanceManager {
    
    static let shared = FinanceManager()
    private var incomeId = 0
    var allIncomes = [Income]() {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "allIncomesChanged"), object: allIncomes)
        }
    }
    private let db = Firestore.firestore()
    
    private init() {
        if let incomeID = UserDefaults.standard.value(forKey: "incomeID") as? Int {
            self.incomeId = incomeID
        } else if let maxId = FinanceManager.shared.allIncomes.max(by: {$0.id < $1.id})?.id {
            self.incomeId = maxId
        }
    }
    
    func saveIncome(income: Income, userName: String, complition: @escaping (Result<Void, Error>)-> Void) {
        db.collection("Income").document(userName).collection("Income").document(String(income.id)).setData(["name": income.name,  "amount": income.amount, "date": income.date, "isDeal": income.isDeal, "eventStoreId": income.eventStoreId]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    complition(.failure(error))
                } else {
                    complition(.success(()))
                }
            }
        }
    }
    
    func loadIncomes(userId: String, complition: @escaping (Result<Void, Error>)-> Void) {
        var incomes = [Income]()
        db.collection("Income").document(userId).collection("Income").getDocuments { (querySnapshot, error) in
            DispatchQueue.main.async {
                if let error = error {
                    complition(.failure(error))
                    return
                }
                if let query = querySnapshot {
                    for document in query.documents {
                        let id = document.documentID
                        let eventStoreId = document.get("eventStoreId") as? String
                        if let name = document.get("name") as? String,
                           let amount = document.get("amount") as? Int,
                           let deal = document.get("isDeal") as? Bool,
                           let timeStamp = document.get("date") as? Timestamp {
                            let date = timeStamp.dateValue()
                            let newIncome = Income(amount: amount, date: date, name: name, id: Int(id) ?? 0, isDeal: deal, eventStoreId: eventStoreId)
                            self.allIncomes.append(newIncome)
                        }
                    }
                }
                complition(.success(()))
            }
        }
    }
    
    func deleteIncome(incomeId: String, userID: String, complition: @escaping (Result<Void, Error>)-> Void) {
        db.collection("Income").document(userID).collection("Income").document(incomeId).delete() { error in
            if let error = error {
                complition(.failure(error))
            } else {
                complition(.success(()))
            }
        }
    }
    
    func editIncome(income: Income, userName: String, complition: @escaping (Result<Void, Error>)-> Void) {
        db.collection("Income").document(userName).collection("Income").document(String(income.id)).updateData(["name": income.name,  "amount": income.amount, "date": income.date, "isDeal": income.isDeal, "eventStoreId": income.eventStoreId]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    complition(.failure(error))
                } else {
                    complition(.success(()))
                }
            }
        }
    }
    
    func genrateIncomeID()-> Int {
        let newId = incomeId + 1
        incomeId = newId
        UserDefaults.standard.set(newId, forKey: "incomeID")
        return incomeId
    }
}
