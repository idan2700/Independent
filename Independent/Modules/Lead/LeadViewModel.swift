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
    func moveToCreateLeadVC(name: String?, phone: String?, leadManager: LeadManager)
    func changeCreateLeadButtonsVisability(toPresent: Bool)
    func presentErrorAlert(message: String)
    func setNoLeadsLabelState(isHidden: Bool)
    func setNextMonthButtonState(isHidden: Bool)
    func removeCell(at indexPath: IndexPath)
    func changeNewLeadButtonState(isEnabled: Bool)
    func changePresentByButtonUI(currentSelectedButton: String)
    func moveToEditSummryLeadVC(with lead: Lead, indexPath: IndexPath, leadManager: LeadManager)
    func expandUpdatedCell(lead: Lead)
    func moveToCreateDealVC(with lead: Lead, allEvents: [Event], allLeads: [Lead])
    func moveToContactsVC()
    func reloadData()
}

class LeadViewModel {
    
    weak var delegate: LeadViewModelDelegate?
    
    private let dateFormatter = DateFormatter()
    private let leadManager: LeadManager
    private var date = Date()
    private var allEvents = [Event]()
    private var leadsHolder = [Lead]()
    private var isNewLeadButtonSelected: Bool = false
    private var newDealIndexPath: IndexPath?
    
    private var allLeads: [Lead] {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "allLeadsChanged"), object: allLeads)
        }
    }
    
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

    init(delegate: LeadViewModelDelegate?, leadManager: LeadManager, allLeads: [Lead]) {
        self.delegate = delegate
        self.leadManager = leadManager
        self.allLeads = allLeads
        NotificationCenter.default.addObserver(self, selector: #selector(newDealAddedFromLeads), name: Notification.Name(rawValue: "newDealAddedFromLeads"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(allEventsChanged(notification:)), name: Notification.Name(rawValue: "allEventsChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dealOnExistingLead(notification:)), name: Notification.Name(rawValue: "dealOnExistingLead"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dealWasCanceled(notification:)), name: Notification.Name(rawValue: "dealWasCanceled"), object: nil)
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
            let filterd = currentMonthLeads.filter({$0.fullName.contains(text)})
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
            delegate?.moveToCreateLeadVC(name: name, phone: phoneNumber, leadManager: self.leadManager)
        }
        delegate?.moveToCreateLeadVC(name: name, phone: phoneWithNoLines, leadManager: self.leadManager)
    }

    func didTapAddManualy() {
        delegate?.moveToCreateLeadVC(name: nil, phone: nil, leadManager: self.leadManager)
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
            leadManager.deleteLead(leadId: leadID, userID: currentUserID) { [weak self] result in
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
        delegate?.moveToCreateDealVC(with: currentMonthLeads[indexPath.row], allEvents: allEvents, allLeads: allLeads)
    }
    
    @objc func newDealAddedFromLeads() {
        guard let indexPath = newDealIndexPath else {return}
        currentMonthLeads[indexPath.row].status = .deal
        self.removeLeadFromAllLeads(lead: currentMonthLeads[indexPath.row])
        allLeads.append(currentMonthLeads[indexPath.row])
        leadsHolder.append(currentMonthLeads[indexPath.row])
        changeLeadStatus(lead: currentMonthLeads[indexPath.row])
    }
    
    func didTapLockLead(at indexPath: IndexPath) {
        currentMonthLeads[indexPath.row].status = .closed
        self.removeLeadFromAllLeads(lead: currentMonthLeads[indexPath.row])
        allLeads.append(currentMonthLeads[indexPath.row])
        leadsHolder.append(currentMonthLeads[indexPath.row])
        changeLeadStatus(lead: currentMonthLeads[indexPath.row])
    }
    
    func didTapOpenLead(at indexPath: IndexPath) {
        if currentMonthLeads[indexPath.row].status == .deal {
            return
        }
        currentMonthLeads[indexPath.row].status = .open
        self.removeLeadFromAllLeads(lead: currentMonthLeads[indexPath.row])
        allLeads.append(currentMonthLeads[indexPath.row])
        leadsHolder.append(currentMonthLeads[indexPath.row])
        changeLeadStatus(lead: currentMonthLeads[indexPath.row])
    }
    
    func didPickNewLead(lead: Lead) {
        self.currentMonthLeads.append(lead)
        self.leadsHolder.append(lead)
        self.allLeads.append(lead)
        delegate?.reloadData()
    }
    
    func didPickUpdatedLead(lead: Lead, indexPath: IndexPath) {
        currentMonthLeads[indexPath.row] = lead
        removeLeadFromAllLeads(lead: lead)
        allLeads.append(lead)
        leadsHolder.append(lead)
        delegate?.reloadData()
        delegate?.expandUpdatedCell(lead: currentMonthLeads[indexPath.row])
    }
    
    func didTapEditLeadSummry(at indexPath: IndexPath) {
        delegate?.moveToEditSummryLeadVC(with: currentMonthLeads[indexPath.row], indexPath: indexPath, leadManager: self.leadManager)
    }

    //Mark:- Private funcs
    @objc private func allEventsChanged(notification: Notification) {
        guard let allEvents = notification.object as? [Event] else {return}
        self.allEvents = allEvents
    }
    
    private func checkIfLeadsAreEmpty() {
        if currentMonthLeads.isEmpty {
            self.delegate?.setNoLeadsLabelState(isHidden: false)
        } else {
            self.delegate?.setNoLeadsLabelState(isHidden: true)
        }
    }
    
    private func changeLeadStatus(lead: Lead) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        leadManager.updateLeadStatus(lead: lead, userName: currentUserID, status: lead.status.statusString) { [weak self] result in
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
       for lead in allLeads {
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
        self.allLeads.removeAll(where: {$0.phoneNumber == lead.phoneNumber})
        self.leadsHolder.removeAll(where: {$0.phoneNumber == lead.phoneNumber})
    }
    
    @objc private func dealOnExistingLead(notification: Notification) {
        guard let index = notification.object as? Int else {return}
        allLeads[index].status = .deal
        changeLeadStatus(lead: allLeads[index])
        currentMonthLeads = []
        leadsHolder = []
        checkIfLeadsAreEqualToCurrentPresentedMonth(currentPresentedMonth: date)
        delegate?.reloadData()
    }
    
    @objc private func dealWasCanceled(notification: Notification) {
        guard let index = notification.object as? Int else {return}
        allLeads[index].status = .closed
        changeLeadStatus(lead: allLeads[index])
        currentMonthLeads = []
        leadsHolder = []
        checkIfLeadsAreEqualToCurrentPresentedMonth(currentPresentedMonth: date)
        delegate?.reloadData()
    }
    
    
//    private func bind() {
//        DataBaseManager.shared.$isLoading
//            .sink { [weak self] isLoading in
//                guard let self = self else {return}
//                if isLoading {
//                    
//                } else {
//                    
//                }
//            }
//            .store(in: &cancellables)
//    }
}
