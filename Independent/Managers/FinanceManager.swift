//
//  FinanceManager.swift
//  Independent
//
//  Created by Idan Levi on 10/12/2021.
//

import Foundation
import Firebase

class FinanceManager {
    
    private let db = Firestore.firestore()
    
    func saveIncome(income: Income, userName: String, complition: @escaping (Result<Void, Error>)-> Void) {
        db.collection("Income").document(userName).collection("Income").document(String(income.id)).setData(["name": income.name,  "amount": income.amount, "date": income.date]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    complition(.failure(error))
                } else {
                    complition(.success(()))
                }
            }
        }
    }
    
    func loadIncomes(userId: String, complition: @escaping (Result<[Income], Error>)-> Void) {
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
                        if let name = document.get("name") as? String,
                           let amount = document.get("amount") as? Int,
                           let timeStamp = document.get("date") as? Timestamp {
                            let date = timeStamp.dateValue()
                            let newIncome = Income(amount: amount, date: date, name: name, id: Int(id) ?? 0)
                            incomes.append(newIncome)
                        }
                    }
                }
                complition(.success(incomes))
            }
        }
    }
}
