//
//  LeadViewModel.swift
//  Independent
//
//  Created by Idan Levi on 28/10/2021.
//

import Foundation
import Firebase
import Combine
import CoreImage
import UIKit
import Contacts

protocol LeadViewModelDelegate: AnyObject {
    func updateCurrentMonthLabel()
    func moveToCreateLeadVC(name: String?, phone: String?)
    func animateNewLeadButton(toOpen: Bool)
    func presentAlert(message: String)
    func setLeadLoaderState(isHidden: Bool)
    func setNoLeadsLabelState(isHidden: Bool)
    func setNextMonthButtonState(isHidden: Bool)
    func removeCell(at indexPath: IndexPath)
    func changeNewLeadButtonState(isEnabled: Bool)
    func moveToContactsVC()
    func reloadData()
}

class LeadViewModel {
    
    weak var delegate: LeadViewModelDelegate?
    
    private let dateFormatter = DateFormatter()
    private var date = Date()
    private var allLeads = [Lead]()
    private var isNewLeadButtonSelected: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    var currentMonthLeads = [Lead]() {
        didSet {
            checkIfLeadsAreEmpty()
        }
    }
    
    var numberOfItems: Int {
        return leadItems.allCases.count
    }
    
    var numberOfCells: Int {
        return currentMonthLeads.count
    }
    
    var stringDate: String {
        dateFormatter.dateFormat = "MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "He")
         return dateFormatter.string(from: date)
    }

    init(delegate: LeadViewModelDelegate?) {
        self.delegate = delegate
    }
    
    func start() {
        delegate?.setLeadLoaderState(isHidden: false)
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        DataBaseManager.shared.loadLeadCollection(userId: currentUserID) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.delegate?.setLeadLoaderState(isHidden: true)
                switch result {
                case .success(let leads):
                    self.allLeads = leads
                    self.checkIfLeadsAreEqualToCurrentPresentedMonth(currentPresentedMonth: Date())
                    self.checkIfLeadsAreEmpty()
                    self.delegate?.reloadData()
                case .failure(_):
                    self.delegate?.presentAlert(message: "בעיה בטעינת מתעניינים מהשרת, אנא נסה שנית")
                }
            }
        }
    }
    
    func getItemViewModel(at indexPath: IndexPath) -> LeadCollectionViewCellViewModel {
        return LeadCollectionViewCellViewModel(item: leadItems(rawValue: indexPath.row),
                                               indexPath: indexPath,
                                               leads: currentMonthLeads)
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> LeadTableViewCellViewModel {
        return LeadTableViewCellViewModel(lead: currentMonthLeads[indexPath.row])
    }
    
    func didTapNextMonth(currentPresentedMonth: String) {
        self.currentMonthLeads = []
        dateFormatter.dateFormat = "MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "He")
        date = Calendar.current.date(byAdding: .month, value: 1, to: date) ?? Date()
        checkIfLeadsAreEqualToCurrentPresentedMonth(currentPresentedMonth: date)
        delegate?.reloadData()
        delegate?.updateCurrentMonthLabel()
        if currentPresentedMonth == dateFormatter.string(from: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()) {
            delegate?.setNextMonthButtonState(isHidden: true)
            delegate?.changeNewLeadButtonState(isEnabled: true)
        }
    }
    
    func didTapLastMonth() {
        self.currentMonthLeads = []
        date = Calendar.current.date(byAdding: .month, value: -1, to: date) ?? Date()
        checkIfLeadsAreEqualToCurrentPresentedMonth(currentPresentedMonth: date)
        delegate?.reloadData()
        delegate?.updateCurrentMonthLabel()
        delegate?.setNextMonthButtonState(isHidden: false)
        delegate?.changeNewLeadButtonState(isEnabled: false)
    }
    
    func didTapCreateNewLead() {
        isNewLeadButtonSelected = !isNewLeadButtonSelected
        delegate?.animateNewLeadButton(toOpen: isNewLeadButtonSelected)
    }
    
    func didTapAddFromContacts() {
        delegate?.moveToContactsVC()
    }

    func didSelectContact(contact: CNContact) {
        let name = contact.givenName + " " + contact.familyName
        let phone = contact.phoneNumbers[0].value.stringValue
        let phoneNumber = phone.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range: nil)
        delegate?.moveToCreateLeadVC(name: name, phone: phoneNumber)
    }

    func didTapAddManualy() {
        delegate?.moveToCreateLeadVC(name: nil, phone: nil)
    }
    
    func didTapCall(at indexPath: IndexPath) {
        guard let phoneCallURL = URL(string: "tel://\(currentMonthLeads[indexPath.row].phoneNumber)") else { return }
        if UIApplication.shared.canOpenURL(phoneCallURL) {
            UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
        }
    }
    
    func didTapSendWhatsapp(at indexPath: IndexPath) {
        guard let url  = URL(string: "https://wa.me/972\(currentMonthLeads[indexPath.row].phoneNumber)") else {return}
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url as URL, options: [:]) { (success) in
                       if success {
                           print("WhatsApp accessed successfully")
                       } else {
                           self.delegate?.presentAlert(message: "אני לא מוצא את הווטסאפ, בטוח שהוא מותקן על המכשיר?")
                       }
                   }
           }
    }
    
    func didTapDelete(at indexPath: IndexPath) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        let leadID = String(currentMonthLeads[indexPath.row].leadID)
            DataBaseManager.shared.deleteLead(leadId: leadID, userID: currentUserID) { [weak self] result in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        self.currentMonthLeads.remove(at: indexPath.row)
                        self.delegate?.removeCell(at: indexPath)
                        self.delegate?.reloadData()
                    case .failure(_):
                        self.delegate?.presentAlert(message: "נוצרה בעיה בפניה לשרת לצורך המחיקה, אנא נסה שנית")
                    }
                }
            }
    }
    
    func didTapMakeDeal(at indexPath: IndexPath) {
        currentMonthLeads[indexPath.row].status = .deal
        allLeads.removeAll(where: {$0.fullName == currentMonthLeads[indexPath.row].fullName})
        allLeads.append(currentMonthLeads[indexPath.row])
        changeLeadStatus(lead: currentMonthLeads[indexPath.row])
    }
    
    func didTapLockLead(at indexPath: IndexPath) {
        currentMonthLeads[indexPath.row].status = .closed
        allLeads.removeAll(where: {$0.fullName == currentMonthLeads[indexPath.row].fullName})
        allLeads.append(currentMonthLeads[indexPath.row])
        changeLeadStatus(lead: currentMonthLeads[indexPath.row])
    }
    
    func didTapOpenLead(at indexPath: IndexPath) {
        currentMonthLeads[indexPath.row].status = .open
        allLeads.removeAll(where: {$0.fullName == currentMonthLeads[indexPath.row].fullName})
        allLeads.append(currentMonthLeads[indexPath.row])
        changeLeadStatus(lead: currentMonthLeads[indexPath.row])
    }
    
    func didPickNewLead(lead: Lead) {
        self.currentMonthLeads.append(lead)
        self.allLeads.append(lead)
        delegate?.reloadData()
    }

    
    //Mark:- Private funcs
    private func checkIfLeadsAreEmpty() {
        if currentMonthLeads.isEmpty {
            self.delegate?.setNoLeadsLabelState(isHidden: false)
        } else {
            self.delegate?.setNoLeadsLabelState(isHidden: true)
        }
    }
    
    private func changeLeadStatus(lead: Lead) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        DataBaseManager.shared.updateLeadStatus(lead: lead, userName: currentUserID, status: lead.status.statusString) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success():
                self.delegate?.reloadData()
            case .failure(_):
                self.delegate?.presentAlert(message: "נוצרה בעיה מול השרת בשינוי סטטוס הליד, אנא נסה שנית")
            }
        }
    }

    private func checkIfLeadsAreEqualToCurrentPresentedMonth(currentPresentedMonth: Date) {
       for lead in allLeads {
           self.dateFormatter.dateFormat = "MMMM"
           self.dateFormatter.locale = Locale(identifier: "He")
           let currentMonth = self.dateFormatter.string(from: currentPresentedMonth)
           if self.dateFormatter.string(from: lead.date) == currentMonth {
               self.currentMonthLeads.append(lead)
           }
       }
   }
    
    private func bind() {
        DataBaseManager.shared.$isLoading
            .sink { [weak self] isLoading in
                guard let self = self else {return}
                if isLoading {
                    self.delegate?.setLeadLoaderState(isHidden: false)
                } else {
                    self.delegate?.setLeadLoaderState(isHidden: true)
                }
            }
            .store(in: &cancellables)
    }
}
