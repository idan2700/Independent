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
    
    private init() {}
    
    func saveIncome(income: Income, userName: String, complition: @escaping (Result<Void, Error>)-> Void) {
        db.collection(userName).document("Incomes").collection("Income").document(income.id).setData(["name": income.name,  "amount": income.amount, "dates": income.dates, "isDeal": income.isDeal, "eventStoreId": income.eventStoreId, "type": income.type.rawValue, "numberOfPayments": income.numberOfPayments]) { error in
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
        db.collection(userId).document("Incomes").collection("Income").getDocuments { (querySnapshot, error) in
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
                            let newIncome = Income(amount: amount, dates: dates, name: name, id: id, isDeal: deal, eventStoreId: eventStoreId, type: incomeType, numberOfPayments: numberOfPayments)
                            self.allIncomes.append(newIncome)
                        }
                    }
                }
                complition(.success(()))
            }
        }
    }
    
    func deleteIncome(incomeId: String, userID: String, complition: @escaping (Result<Void, Error>)-> Void) {
        db.collection(userID).document("Incomes").collection("Income").document(incomeId).delete() { error in
            if let error = error {
                complition(.failure(error))
            } else {
                complition(.success(()))
            }
        }
    }
    
    func editIncome(income: Income, userName: String, complition: @escaping (Result<Void, Error>)-> Void) {
        db.collection(userName).document("Incomes").collection("Income").document(income.id).updateData(["name": income.name,  "amount": income.amount, "dates": income.dates, "isDeal": income.isDeal, "eventStoreId": income.eventStoreId, "type": income.type.rawValue, "numberOfPayments": income.numberOfPayments]) { error in
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
        db.collection(userName).document("Outcomes").collection("Outcome").document(outcome.id).setData(["name": outcome.name,  "amount": outcome.amount, "dates": outcome.dates, "type": outcome.type.rawValue, "numberOfPayments": outcome.numberOfPayments]) { error in
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
        db.collection(userId).document("Outcomes").collection("Outcome").getDocuments { (querySnapshot, error) in
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
                            let newOutcome = Outcome(amount: amount, dates: dates, name: name, id: id, type: outcomeType, numberOfPayments: numberOfPayments)
                            self.allOutcomes.append(newOutcome)
                        }
                    }
                }
                complition(.success(()))
            }
        }
    }
    
    func deleteOutcome(outcomeId: String, userID: String, complition: @escaping (Result<Void, Error>)-> Void) {
        db.collection(userID).document("Outcomes").collection("Outcome").document(outcomeId).delete() { error in
            if let error = error {
                complition(.failure(error))
            } else {
                complition(.success(()))
            }
        }
    }
    
    func editOutcome(outcome: Outcome, userName: String, complition: @escaping (Result<Void, Error>)-> Void) {
        db.collection(userName).document("Outcomes").collection("Outcome").document(outcome.id).updateData(["name": outcome.name,  "amount": outcome.amount, "dates": outcome.dates, "type": outcome.type.rawValue, "numberOfPayments": outcome.numberOfPayments]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    complition(.failure(error))
                } else {
                    complition(.success(()))
                }
            }
        }
    }
}
