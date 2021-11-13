//
//  CreateLeadViewModel.swift
//  Independent
//
//  Created by Idan Levi on 07/11/2021.
//

import Foundation
import Firebase

protocol CreateLeadViewModelDelegate: AnyObject {
    func returnToLeadVC(with newLead: Lead)
    func presentAlert(message: String)
}

class CreateLeadViewModel {
    
    private var leadId = 0
    private var leads: [Lead]
    weak var delegate: CreateLeadViewModelDelegate?
    var nameFromContact: String?
    var phoneFromContact: String?
    
    init(delegate: CreateLeadViewModelDelegate?, leads: [Lead]) {
        self.delegate = delegate
        self.leads = leads
        if let leadID = UserDefaults.standard.value(forKey: "leadID") as? Int {
            self.leadId = leadID
        } else if let maxId = leads.max(by: {$0.leadID < $1.leadID})?.leadID {
            self.leadId = maxId
        }
    }
    
    func didTapAdd(name: String, date: Date, summary: String?, phoneNumber: String) {
        guard let currentUser = Auth.auth().currentUser?.uid else {return}
        let lead = Lead(fullName: name, date: date, summary: summary, phoneNumber: phoneNumber, leadID: genrateLeadID(), status: .open)
        DataBaseManager.shared.saveLead(lead: lead, userName: currentUser) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.delegate?.returnToLeadVC(with: lead)
                case .failure(_):
                    self.delegate?.presentAlert(message: "שגיאה בשמירת המתעניין לשרת, אנא נסה שוב")
                }
            }
        }
    }
    
    func genrateLeadID()-> Int {
        let newId = leadId + 1
        leadId = newId
        UserDefaults.standard.set(newId, forKey: "leadID")
        return leadId
    }
    
    
}
