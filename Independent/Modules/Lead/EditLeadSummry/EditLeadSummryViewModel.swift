//
//  EditLeadSummryViewModel.swift
//  Independent
//
//  Created by Idan Levi on 14/11/2021.
//

import Foundation
import Firebase

protocol EditLeadSummryViewModelDelegate: AnyObject {
    func returnToLeadVC()
    func updateTextViewText(with currentSummry: String)
    func returnToLeadVC(with updatedLead: Lead, indexPath: IndexPath)
    func presentErrorAlert(message: String)
}

class EditLeadSummryViewModel {
    
    private var lead: Lead
    private var indexPath: IndexPath
    private let leadManager: LeadManager
    weak var delegate: EditLeadSummryViewModelDelegate?
    
    init(lead: Lead, delegate: EditLeadSummryViewModelDelegate?, indexPath: IndexPath, leadManager: LeadManager) {
        self.lead = lead
        self.delegate = delegate
        self.indexPath = indexPath
        self.leadManager = leadManager
    }
    
    func start() {
        guard let currentSummary = lead.summary else {return}
        delegate?.updateTextViewText(with: currentSummary)
    }
    
    func didTapEdit(with newSummry: String) {
        guard let currentUser = Auth.auth().currentUser?.uid else {return}
        leadManager.updateLeadSummary(lead: lead, userName: currentUser, summary: newSummry) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.lead.summary = newSummry
                    self.delegate?.returnToLeadVC(with: self.lead, indexPath: self.indexPath)
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "נוצרה בעיה מול השרת בעדכון התקציר, אנא נסה שנית")
                }
            }
        }
    }
    
    func didTapCancel() {
        delegate?.returnToLeadVC()
    }
}
