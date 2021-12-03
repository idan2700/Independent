//
//  CreateEventViewModel.swift
//  Independent
//
//  Created by Idan Levi on 16/11/2021.
//

import Foundation

protocol CreateDealViewModelDelegate: AnyObject {
    func sendDealToCalendar(deal: Deal, isNewDeal: Bool)
}

class CreateDealViewModel {
    
    private var allEvents: [Event]
    private var allLeads: [Lead]
    private var isNewDeal: Bool
    weak var delegate: CreateDealViewModelDelegate?
    
    var isLaunchedFromLead: Bool
    var existingDeal: Event?
    var name: String?
    var phone: String?
    var currentDate: Date?
    
    init(delegate: CreateDealViewModelDelegate, allEvents: [Event], isLaunchedFromLead: Bool, allLeads: [Lead], isNewDeal: Bool) {
        self.delegate = delegate
        self.allEvents = allEvents
        self.allLeads = allLeads
        self.isNewDeal = isNewDeal
        self.isLaunchedFromLead = isLaunchedFromLead
    }
    
    func getCellViewModel(cell: CreateDealTableViewCell)-> CreateDealTableViewCellViewModel {
        return CreateDealTableViewCellViewModel(delegate: cell, allEvents: allEvents, allLeads: allLeads, eventsManager: EventsManager(), currentDate: currentDate ?? Date())
    }
    
    func didPickNewDeal(newDeal: Deal) {
        delegate?.sendDealToCalendar(deal: newDeal, isNewDeal: isNewDeal)
    }
}


