//
//  FuDateViewModel.swift
//  Independent
//
//  Created by Idan Levi on 21/06/2022.
//

import Foundation
import Firebase

protocol FuDateViewModelDelegate: AnyObject {
    func updateDateButtonTitle()
    func presentAlert(message: String)
    func returnToLeadVC(with updatedLead: Lead)
}

class FuDateViewModel {
    
    private var selectedDate: Date?
    var lead: Lead
    weak var delegate: FuDateViewModelDelegate?
    
    init(delegate: FuDateViewModelDelegate, lead: Lead) {
        self.delegate = delegate
        self.lead = lead
    }
    
    var currentDateTitle: String {
        if let fuDate = lead.fuDate {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "He")
            dateFormatter.dateFormat = "EEEE, d MMMM"
            return dateFormatter.string(from: fuDate)
        } else {
            return "ללא"
        }
    }
    
    var selectedDateTitle: String {
        if let selectedDate = selectedDate {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "He")
            dateFormatter.dateFormat = "EEEE, d MMMM"
            return dateFormatter.string(from: selectedDate)
        } else {
            return "ללא"
        }
    }
    
    func didTapSet() {
        guard let currentUser = Auth.auth().currentUser?.uid else {return}
        LeadManager.shared.updateLeadFuDate(lead: lead, userName: currentUser, fuDate: selectedDate) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.lead.fuDate = self.selectedDate
                    self.delegate?.returnToLeadVC(with: self.lead)
                case .failure(_):
                    self.delegate?.presentAlert(message: "שגיאה בעדכון התאריך לשרת, אנא נסה שוב")
                }
            }
        }
    }
    
    func didTapRemoveFuDate() {
        self.selectedDate = nil
        delegate?.updateDateButtonTitle()
    }
    
    func didSelectDate(date: Date) {
        self.selectedDate = date
        delegate?.updateDateButtonTitle()
    }
}
