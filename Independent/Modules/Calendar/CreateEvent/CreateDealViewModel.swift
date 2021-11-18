//
//  CreateEventViewModel.swift
//  Independent
//
//  Created by Idan Levi on 16/11/2021.
//

import Foundation

protocol CreateDealViewModelDelegate: AnyObject {
    func sendDealToCalendar(deal: Deal)
}

class CreateDealViewModel {
    
    let currentEventID: Int
    weak var delegate: CreateDealViewModelDelegate?
    
    init(delegate: CreateDealViewModelDelegate, currentEventID: Int) {
        self.delegate = delegate
        self.currentEventID = currentEventID
    }
    
    func getCellViewModel(cell: CreateDealTableViewCell)-> CreateDealTableViewCellViewModel {
        return CreateDealTableViewCellViewModel(delegate: cell, currentEventID: currentEventID)
    }
    
    func didPickNewDeal(newDeal: Deal) {
        delegate?.sendDealToCalendar(deal: newDeal)
    }
}


