//
//  LeadViewModel.swift
//  Independent
//
//  Created by Idan Levi on 28/10/2021.
//

import Foundation
import Firebase
import CoreImage
import UIKit
import Contacts

protocol LeadViewModelDelegate: AnyObject {
    func updateCurrentMonthLabel()
    func moveToCreateLeadVC(name: String?, phone: String?)
    func changeCreateLeadButtonsVisability(toPresent: Bool)
    func presentErrorAlert(message: String)
    func setNoLeadsLabelState(isHidden: Bool)
    func setNextMonthButtonState(isHidden: Bool)
    func removeCell(at indexPath: IndexPath)
    func changeNewLeadButtonState(isEnabled: Bool)
    func changePresentByButtonUI(currentSelectedButton: String)
    func moveToEditSummryLeadVC(with lead: Lead, indexPath: IndexPath)
    func expandUpdatedCell(lead: Lead)
    func moveToCreateDealVC(lead: Lead)
    func moveToContactsVC()
    func changeMonthlyViewVisability(toPresent: Bool)
    func reloadData()
}

class LeadViewModel {
    
    weak var delegate: LeadViewModelDelegate?
    
    private let dateFormatter = DateFormatter()
    private var date = Date()
    private var leadsHolder = [Lead]()
    private var isNewLeadButtonSelected: Bool = false
    private var newDealIndexPath: IndexPath?
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(newDealAddedFromLeads), name: Notification.Name(rawValue: "newDealAddedFromLeads"), object: nil)
    }
    
    func start() {
        self.checkIfLeadsAreEqualToCurrentPresentedMonth(currentPresentedMonth: Date())
        self.checkIfLeadsAreEmpty()
        self.delegate?.reloadData()
    }
    
    func getItemViewModel(at indexPath: IndexPath) -> LeadCollectionViewCellViewModel {
        return LeadCollectionViewCellViewModel(item: leadItems(rawValue: indexPath.row),
                                               indexPath: indexPath,
                                               leads: leadsHolder)
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> LeadTableViewCellViewModel {
        return LeadTableViewCellViewModel(lead: currentMonthLeads[indexPath.row])
    }
    
    func didChangeSegmant(selectedIndex: Int) {
        switch selectedIndex {
        case 0:
            delegate?.changeMonthlyViewVisability(toPresent: true)
            checkIfLeadsAreEqualToCurrentPresentedMonth(currentPresentedMonth: date)
            checkIfLeadsAreEmpty()
            delegate?.reloadData()
        case 1:
            delegate?.changeMonthlyViewVisability(toPresent: false)
            currentMonthLeads = []
            leadsHolder = []
            currentMonthLeads = LeadManager.shared.allLeads
            leadsHolder = LeadManager.shared.allLeads
            checkIfLeadsAreEmpty()
            delegate?.reloadData()
        default:
            break
        }
    }
    
    func didTapNextMonth(currentPresentedMonth: String) {
        self.currentMonthLeads = []
        self.leadsHolder = []
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
        self.leadsHolder = []
        date = Calendar.current.date(byAdding: .month, value: -1, to: date) ?? Date()
        checkIfLeadsAreEqualToCurrentPresentedMonth(currentPresentedMonth: date)
        delegate?.reloadData()
        delegate?.updateCurrentMonthLabel()
        delegate?.setNextMonthButtonState(isHidden: false)
        delegate?.changeNewLeadButtonState(isEnabled: false)
    }
    
    func didSearchForLead(text: String) {
        currentMonthLeads = leadsHolder
        if text.isEmpty {
            currentMonthLeads = leadsHolder
        } else {
            let filterd = currentMonthLeads.filter({$0.fullName.contains(text) || $0.phoneNumber.contains(text)})
            if filterd.count > 0 {
                currentMonthLeads = filterd
            } else {
                currentMonthLeads = []
            }
        }
        delegate?.reloadData()
    }
    
    func didTapCreateNewLead() {
        isNewLeadButtonSelected = !isNewLeadButtonSelected
        delegate?.changeCreateLeadButtonsVisability(toPresent: isNewLeadButtonSelected)
    }
    
    func didTapAddFromContacts() {
        delegate?.moveToContactsVC()
        delegate?.changeCreateLeadButtonsVisability(toPresent: false)
    }

    func didSelectContact(contact: CNContact) {
        let name = contact.givenName + " " + contact.familyName
        let phone = contact.phoneNumbers[0].value.stringValue
        let phoneWithNoLines = phone.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range: nil)
        if phoneWithNoLines.count > 10 {
            let phoneWithNoBlanks = phoneWithNoLines.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
            var phoneNumber = phoneWithNoBlanks.replacingOccurrences(of: "+", with: "", options: NSString.CompareOptions.literal, range: nil)
            for _ in 0...2 {
                phoneNumber.remove(at: phoneNumber.startIndex)
            }
            phoneNumber.insert("0", at: phoneNumber.startIndex)
            delegate?.moveToCreateLeadVC(name: name, phone: phoneNumber)
        }
        delegate?.moveToCreateLeadVC(name: name, phone: phoneWithNoLines)
    }

    func didTapAddManualy() {
        delegate?.moveToCreateLeadVC(name: nil, phone: nil)
        delegate?.changeCreateLeadButtonsVisability(toPresent: false)
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
                           self.delegate?.presentErrorAlert(message: "אני לא מוצא את הווטסאפ, בטוח שהוא מותקן על המכשיר?")
                       }
                   }
           }
    }
    
    func didTapDelete(at indexPath: IndexPath) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        let leadID = String(currentMonthLeads[indexPath.row].leadID)
        LeadManager.shared.deleteLead(leadId: leadID, userID: currentUserID) { [weak self] result in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        self.removeLeadFromAllLeads(lead: self.currentMonthLeads[indexPath.row])
                        self.currentMonthLeads.remove(at: indexPath.row)
                        self.delegate?.removeCell(at: indexPath)
                        self.delegate?.reloadData()
                    case .failure(_):
                        self.delegate?.presentErrorAlert(message: "נוצרה בעיה בפניה לשרת לצורך המחיקה, אנא נסה שנית")
                    }
                }
            }
    }
    
    func didTapPresentBy(presentByTitle: String) {
        switch presentByTitle {
        case "כל הלידים":
            delegate?.changePresentByButtonUI(currentSelectedButton: "כל הלידים")
            self.currentMonthLeads = leadsHolder
        case "פתוחים":
            delegate?.changePresentByButtonUI(currentSelectedButton: "פתוחים")
            let filterd = self.leadsHolder.filter({$0.status == .open})
            self.currentMonthLeads = filterd
        case "סגורים":
            delegate?.changePresentByButtonUI(currentSelectedButton: "סגורים")
            let filterd = self.leadsHolder.filter({$0.status == .closed})
            self.currentMonthLeads = filterd
        case "הומרו לעסקה":
            delegate?.changePresentByButtonUI(currentSelectedButton: "הומרו לעסקה")
            let filterd = self.leadsHolder.filter({$0.status == .deal})
            self.currentMonthLeads = filterd
        default:
            self.currentMonthLeads = leadsHolder
        }
        delegate?.reloadData()
    }
    
    func didTapMakeDeal(at indexPath: IndexPath) {
        self.newDealIndexPath = indexPath
        delegate?.moveToCreateDealVC(lead: currentMonthLeads[indexPath.row])
    }
    
    @objc func newDealAddedFromLeads() {
        guard let indexPath = newDealIndexPath else {return}
        currentMonthLeads[indexPath.row].status = .deal
        self.removeLeadFromAllLeads(lead: currentMonthLeads[indexPath.row])
        LeadManager.shared.allLeads.append(currentMonthLeads[indexPath.row])
        leadsHolder.append(currentMonthLeads[indexPath.row])
        changeLeadStatus(lead: currentMonthLeads[indexPath.row])
    }
    
    func didTapLockLead(at indexPath: IndexPath) {
        currentMonthLeads[indexPath.row].status = .closed
        self.removeLeadFromAllLeads(lead: currentMonthLeads[indexPath.row])
        LeadManager.shared.allLeads.append(currentMonthLeads[indexPath.row])
        leadsHolder.append(currentMonthLeads[indexPath.row])
        changeLeadStatus(lead: currentMonthLeads[indexPath.row])
    }
    
    func didTapOpenLead(at indexPath: IndexPath) {
        if currentMonthLeads[indexPath.row].status == .deal {
            return
        }
        currentMonthLeads[indexPath.row].status = .open
        self.removeLeadFromAllLeads(lead: currentMonthLeads[indexPath.row])
        LeadManager.shared.allLeads.append(currentMonthLeads[indexPath.row])
        leadsHolder.append(currentMonthLeads[indexPath.row])
        changeLeadStatus(lead: currentMonthLeads[indexPath.row])
    }
    
    func didPickNewLead(lead: Lead) {
        self.currentMonthLeads.append(lead)
        self.leadsHolder.append(lead)
        LeadManager.shared.allLeads.append(lead)
        delegate?.reloadData()
    }
    
    func didPickUpdatedLead(lead: Lead, indexPath: IndexPath) {
        currentMonthLeads[indexPath.row] = lead
        removeLeadFromAllLeads(lead: lead)
        LeadManager.shared.allLeads.append(lead)
        leadsHolder.append(lead)
        delegate?.reloadData()
        delegate?.expandUpdatedCell(lead: currentMonthLeads[indexPath.row])
    }
    
    func didTapEditLeadSummry(at indexPath: IndexPath) {
        delegate?.moveToEditSummryLeadVC(with: currentMonthLeads[indexPath.row], indexPath: indexPath)
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
        LeadManager.shared.updateLeadStatus(lead: lead, userName: currentUserID, status: lead.status.statusString) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success():
                self.delegate?.reloadData()
            case .failure(_):
                self.delegate?.presentErrorAlert(message: "נוצרה בעיה מול השרת בשינוי סטטוס הליד, אנא נסה שנית")
            }
        }
    }

    private func checkIfLeadsAreEqualToCurrentPresentedMonth(currentPresentedMonth: Date) {
        currentMonthLeads = []
        leadsHolder = []
        for lead in LeadManager.shared.allLeads {
            self.dateFormatter.dateFormat = "MMMM"
            self.dateFormatter.locale = Locale(identifier: "He")
            let currentMonth = self.dateFormatter.string(from: currentPresentedMonth)
            if self.dateFormatter.string(from: lead.date) == currentMonth {
                self.currentMonthLeads.append(lead)
                self.leadsHolder.append(lead)
            }
        }
    }
    
    private func removeLeadFromAllLeads(lead: Lead) {
        LeadManager.shared.allLeads.removeAll(where: {$0.phoneNumber == lead.phoneNumber})
        self.leadsHolder.removeAll(where: {$0.phoneNumber == lead.phoneNumber})
    }
}
