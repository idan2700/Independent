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

protocol LeadViewModelDelegate: AnyObject {
    func updateCurrentMonthLabel()
    func moveToCreateLeadVC()
    func animateNewLeadButton(toOpen: Bool)
    func presentAlert(message: String)
    func setLeadLoaderState(isHidden: Bool)
    func setNoLeadsLabelState(isHidden: Bool)
    func setNextMonthButtonState(isHidden: Bool)
    func removeCell(at indexPath: IndexPath)
    func reloadData()
}

class LeadViewModel {
    
    weak var delegate: LeadViewModelDelegate?
    
    private let dateFormatter = DateFormatter()
    private var date = Date()
    private var allLeads = [Lead]()
    private var isNewLeadButtonSelected: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    var leads = [Lead]() {
        didSet {
            checkIfLeadsAreEmpty()
        }
    }
    
    var numberOfItems: Int {
        return leadItems.allCases.count
    }
    
    var numberOfCells: Int {
        return leads.count
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
        return LeadCollectionViewCellViewModel(itemType: leadItems(rawValue: indexPath.row))
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> LeadTableViewCellViewModel {
        return LeadTableViewCellViewModel(lead: leads[indexPath.row])
    }
    
    func didTapNextMonth(currentPresentedMonth: String) {
        self.leads = []
        dateFormatter.dateFormat = "MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "He")
        date = Calendar.current.date(byAdding: .month, value: 1, to: date) ?? Date()
        checkIfLeadsAreEqualToCurrentPresentedMonth(currentPresentedMonth: date)
        delegate?.reloadData()
        delegate?.updateCurrentMonthLabel()
        if currentPresentedMonth == dateFormatter.string(from: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()) {
            delegate?.setNextMonthButtonState(isHidden: true)
        }
    }
    
    func didTapLastMonth() {
        self.leads = []
        date = Calendar.current.date(byAdding: .month, value: -1, to: date) ?? Date()
        checkIfLeadsAreEqualToCurrentPresentedMonth(currentPresentedMonth: date)
        delegate?.reloadData()
        delegate?.updateCurrentMonthLabel()
        delegate?.setNextMonthButtonState(isHidden: false)
    }
    
    func didTapCreateNewLead() {
        isNewLeadButtonSelected = !isNewLeadButtonSelected
        delegate?.animateNewLeadButton(toOpen: isNewLeadButtonSelected)
    }

    func didTapAddManualy() {
        delegate?.moveToCreateLeadVC()
    }
    
    func didTapCall(at indexPath: IndexPath) {
        guard let phoneCallURL = URL(string: "tel://\(leads[indexPath.row].phoneNumber)") else { return }
        if UIApplication.shared.canOpenURL(phoneCallURL) {
            UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
        }
    }
    
    func didTapSendWhatsapp(at indexPath: IndexPath) {
        guard let url  = URL(string: "https://wa.me/972\(leads[indexPath.row].phoneNumber)") else {return}
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
        let leadID = String(leads[indexPath.row].leadID)
            DataBaseManager.shared.deleteLead(leadId: leadID, userID: currentUserID) { [weak self] result in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        self.leads.remove(at: indexPath.row)
                        self.delegate?.removeCell(at: indexPath)
                    case .failure(_):
                        self.delegate?.presentAlert(message: "נוצרה בעיה בפניה לשרת לצורך המחיקה, אנא נסה שנית")
                    }
                }
            }
    }
    
    func didPickNewLead(lead: Lead) {
        self.leads.append(lead)
        delegate?.reloadData()
    }
    
    //Mark:- Private funcs
    private func checkIfLeadsAreEmpty() {
        if leads.isEmpty {
            self.delegate?.setNoLeadsLabelState(isHidden: false)
        } else {
            self.delegate?.setNoLeadsLabelState(isHidden: true)
        }
    }

    private func checkIfLeadsAreEqualToCurrentPresentedMonth(currentPresentedMonth: Date) {
       for lead in allLeads {
           self.dateFormatter.dateFormat = "MMMM"
           self.dateFormatter.locale = Locale(identifier: "He")
           let currentMonth = self.dateFormatter.string(from: currentPresentedMonth)
           if self.dateFormatter.string(from: lead.date) == currentMonth {
               self.leads.append(lead)
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
