//
//  CreateEventViewModel.swift
//  Independent
//
//  Created by Idan Levi on 16/11/2021.
//

import Foundation
import Firebase

protocol CreateDealViewModelDelegate: AnyObject {
    func sendDealToCalendar(deal: Deal, isNewDeal: Bool)
    func presentErrorAlert(message: String)
    func returnToPrevious()
}

class CreateDealViewModel {
    
    private var isNewDeal: Bool
    weak var delegate: CreateDealViewModelDelegate?
    
    var isLaunchedFromLead: Bool
    var existingDeal: Event?
    var name: String?
    var phone: String?
    var currentDate: Date?
    
    init(delegate: CreateDealViewModelDelegate, isLaunchedFromLead: Bool, isNewDeal: Bool) {
        self.delegate = delegate
        self.isNewDeal = isNewDeal
        self.isLaunchedFromLead = isLaunchedFromLead
    }
    
    func getCellViewModel(cell: CreateDealTableViewCell)-> CreateDealTableViewCellViewModel {
        return CreateDealTableViewCellViewModel(delegate: cell, currentDate: currentDate ?? Date())
    }
    
    func didPickNewDeal(newDeal: Deal) {
        if isLaunchedFromLead {
            self.saveDeal(deal: newDeal)
        } else {
            delegate?.sendDealToCalendar(deal: newDeal, isNewDeal: isNewDeal)
        }
    }
    
    private func saveDeal(deal: Deal) {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        EventsManager.shared.saveDeal(deal: deal, userName: userId) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success():
                    EventsManager.shared.allEvents.append(Event.deal(viewModel: DealTableViewCellViewModel(deal: deal)))
                    EventsManager.shared.sortEvents()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "newDealAddedFromLeads"), object: nil)
                    self.createNewIncome(deal: deal)
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "נוצרה בעיה מול השרת בשמירת העסקה, אנא נסה שנית ")
                }
            }
        }
    }
    
    private func createNewIncome(deal: Deal) {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        guard let amount = Int(deal.price) else { return }
        let id = FinanceManager.shared.genrateIncomeID()
        let income = Income(amount: amount, date: deal.startDate, name: deal.name, id: id, isDeal: true, eventStoreId: deal.eventStoreID)
        FinanceManager.shared.saveIncome(income: income, userName: userId) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success():
                    FinanceManager.shared.allIncomes.append(income)
                    self.delegate?.returnToPrevious()
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "נוצרה בעיה מול השרת בשמירת הכנסה, אנא נסה שנית")
                }
            }
        }
    }
}


