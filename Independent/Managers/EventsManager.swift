//
//  EventsManager.swift
//  Independent
//
//  Created by Idan Levi on 18/11/2021.
//

import Foundation
import Firebase

class EventsManager {
    
    private let db = Firestore.firestore()
    
    @Published var isLoading: Bool = false
    
    func saveDeal(deal: Deal, userName: String, complition: @escaping (Result<Void, Error>)-> Void) {
        db.collection("Events").document(userName).collection("deal").document(String(deal.dealID)).setData(["name": deal.name, "phone": deal.phone, "location": deal.location, "startDate": deal.startDate, "endDate": deal.endDate, "price": deal.price, "notes": deal.notes]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    complition(.failure(error))
                } else {
                    complition(.success(()))
                }
            }
        }
    }
    
    func loadDeals(userId: String, complition: @escaping (Result<[Deal], Error>)-> Void) {
        var deals = [Deal]()
        isLoading = true
        db.collection("Events").document(userId).collection("deal").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else {return}
            self.isLoading = false
            DispatchQueue.main.async {
                if let error = error {
                    complition(.failure(error))
                    return
                }
                if let query = querySnapshot {
                    for document in query.documents {
                        let dealID = document.documentID
                        if let name = document.get("name") as? String,
                           let phone = document.get("phone") as? String,
                           let location = document.get("location") as? String,
                           let price = document.get("price") as? String,
                           let notes = document.get("notes") as? String,
                           let startTimeStamp = document.get("startDate") as? Timestamp,
                           let endTimeStamp = document.get("endDate") as? Timestamp {
                           let startDate = startTimeStamp.dateValue()
                            let endDate = endTimeStamp.dateValue()
                            let newDeal = Deal(name: name, phone: phone, location: location, startDate: startDate, endDate: endDate, price: price, notes: notes, dealID: Int(dealID) ?? 0)
                            deals.append(newDeal)
                        }
                    }
                }
                complition(.success(deals))
            }
        }
    }
}
