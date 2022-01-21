//
//  FinanceManager.swift
//  Independent
//
//  Created by Idan Levi on 10/12/2021.
//

import Foundation
import Firebase

class FinanceManager {
    
    
    private var incomeId = 0
    private var outcomeId = 0
    var allIncomes = [Income]()

    var allOutcomes = [Outcome]()
  
    private let db = Firestore.firestore()
    static let shared = FinanceManager()
    
    private init() {
//        updateId()
    }
    
    func saveIncome(income: Income, userName: String, complition: @escaping (Result<Void, Error>)-> Void) {
        db.collection("Income").document(userName).collection("Income").document(String(income.id)).setData(["name": income.name,  "amount": income.amount, "dates": income.dates, "isDeal": income.isDeal, "eventStoreId": income.eventStoreId, "type": income.type.rawValue, "numberOfPayments": income.numberOfPayments]) { error in
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
                        let numberOfPayments = document.get("numberOfPayments") as? Int
                        if let name = document.get("name") as? String,
                           let amount = document.get("amount") as? Int,
                           let deal = document.get("isDeal") as? Bool,
                           let type = document.get("type") as? String,
                           let timeStamps = document.get("dates") as? [Timestamp] {
                            var dates = [Date]()
                            for timeStamp in timeStamps {
                                dates.append(timeStamp.dateValue())
                            }
                            var incomeType = IncomeType.oneTime
                            if type == IncomeType.oneTime.rawValue {
                                incomeType = IncomeType.oneTime
                            } else if type == IncomeType.payments.rawValue {
                                incomeType = IncomeType.payments
                            } else if type == IncomeType.permanent.rawValue {
                                incomeType = IncomeType.permanent
                            }
                            let newIncome = Income(amount: amount, dates: dates, name: name, id: Int(id) ?? 0, isDeal: deal, eventStoreId: eventStoreId, type: incomeType, numberOfPayments: numberOfPayments)
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
        db.collection("Income").document(userName).collection("Income").document(String(income.id)).updateData(["name": income.name,  "amount": income.amount, "dates": income.dates, "isDeal": income.isDeal, "eventStoreId": income.eventStoreId, "type": income.type.rawValue, "numberOfPayments": income.numberOfPayments]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    complition(.failure(error))
                } else {
                    complition(.success(()))
                }
            }
        }
    }
    
    func saveOutcome(outcome: Outcome, userName: String, complition: @escaping (Result<Void, Error>)-> Void) {
        db.collection("Outcome").document(userName).collection("Outcome").document(String(outcome.id)).setData(["name": outcome.name,  "amount": outcome.amount, "dates": outcome.dates, "type": outcome.type.rawValue, "numberOfPayments": outcome.numberOfPayments]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    complition(.failure(error))
                } else {
                    complition(.success(()))
                }
            }
        }
    }
    
    func loadOutcomes(userId: String, complition: @escaping (Result<Void, Error>)-> Void) {
        db.collection("Outcome").document(userId).collection("Outcome").getDocuments { (querySnapshot, error) in
            DispatchQueue.main.async {
                if let error = error {
                    complition(.failure(error))
                    return
                }
                if let query = querySnapshot {
                    for document in query.documents {
                        let id = document.documentID
                        let numberOfPayments = document.get("numberOfPayments") as? Int
                        if let name = document.get("name") as? String,
                           let amount = document.get("amount") as? Int,
                           let type = document.get("type") as? String,
                           let timeStamps = document.get("dates") as? [Timestamp] {
                            var dates = [Date]()
                            for timeStamp in timeStamps {
                                dates.append(timeStamp.dateValue())
                            }
                            var outcomeType = OutcomeType.oneTime
                            if type == OutcomeType.oneTime.rawValue {
                                outcomeType = OutcomeType.oneTime
                            } else if type == OutcomeType.payments.rawValue {
                                outcomeType = OutcomeType.payments
                            } else if type == OutcomeType.permanent.rawValue {
                                outcomeType = OutcomeType.permanent
                            }
                            let newOutcome = Outcome(amount: amount, dates: dates, name: name, id: Int(id) ?? 0, type: outcomeType, numberOfPayments: numberOfPayments)
                            self.allOutcomes.append(newOutcome)
                        }
                    }
                }
                complition(.success(()))
            }
        }
    }
    
    func deleteOutcome(outcomeId: String, userID: String, complition: @escaping (Result<Void, Error>)-> Void) {
        db.collection("Outcome").document(userID).collection("Outcome").document(outcomeId).delete() { error in
            if let error = error {
                complition(.failure(error))
            } else {
                complition(.success(()))
            }
        }
    }
    
    func editOutcome(outcome: Outcome, userName: String, complition: @escaping (Result<Void, Error>)-> Void) {
        db.collection("Outcome").document(userName).collection("Outcome").document(String(outcome.id)).updateData(["name": outcome.name,  "amount": outcome.amount, "dates": outcome.dates, "type": outcome.type.rawValue, "numberOfPayments": outcome.numberOfPayments]) { error in
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
    
    func genrateOutcomeID()-> Int {
        let newId = incomeId + 1
        incomeId = newId
        UserDefaults.standard.set(newId, forKey: "outcomeID")
        return incomeId
    }
    
    private func updateId() {
        if let incomeID = UserDefaults.standard.value(forKey: "incomeID") as? Int {
            self.incomeId = incomeID
        } else if let maxId = FinanceManager.shared.allIncomes.max(by: {$0.id < $1.id})?.id {
            self.incomeId = maxId
        }
        if let outcomeId = UserDefaults.standard.value(forKey: "outcomeID") as? Int {
            self.outcomeId = outcomeId
        } else if let maxId = FinanceManager.shared.allOutcomes.max(by: {$0.id < $1.id})?.id {
            self.outcomeId = maxId
        }
    }
}
