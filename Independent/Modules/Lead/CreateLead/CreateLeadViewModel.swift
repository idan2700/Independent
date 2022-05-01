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
    func restartPhoneTextField()
}

class CreateLeadViewModel {
    
    private var leadId = 0
    weak var delegate: CreateLeadViewModelDelegate?
    var nameFromContact: String?
    var phoneFromContact: String?
    
    init(delegate: CreateLeadViewModelDelegate?, leads: [Lead]) {
        self.delegate = delegate
        if let leadID = UserDefaults.standard.value(forKey: "leadID") as? Int {
            self.leadId = leadID
        } else if let maxId = LeadManager.shared.allLeads.max(by: {$0.leadID < $1.leadID})?.leadID {
            self.leadId = maxId
        }
    }
    
    func didTapAdd(name: String, date: Date, summary: String?, phoneNumber: String) {
        guard let currentUser = Auth.auth().currentUser?.uid else {return}
        let lead = Lead(fullName: name, date: date, summary: summary, phoneNumber: phoneNumber, leadID: genrateLeadID(), status: .open)
        LeadManager.shared.saveLead(lead: lead, userName: currentUser) { [weak self] result in
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
    
    func didEditPhone(phone: String) {
        if phone.count < 9 || phone.count > 10 {
            return
        } else {
            if LeadManager.shared.allLeads.contains(where: {$0.phoneNumber == phone}) {
                self.delegate?.presentAlert(message: "הליד קיים במערכת")
                self.delegate?.restartPhoneTextField()
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
