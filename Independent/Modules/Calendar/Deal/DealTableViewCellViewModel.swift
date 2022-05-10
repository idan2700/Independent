//
//  EventTableViewCellViewModel.swift
//  Independent
//
//  Created by Idan Levi on 15/11/2021.
//

import Foundation

protocol DealTableViewCellViewModelDelegate: AnyObject {
    func changeNotesLabelVisability(toPresent: Bool)
}

class DealTableViewCellViewModel {
    
    var deal: Deal
    private var dateFormatter = DateFormatter()
    private var isNotesButtonIsOpen: Bool = false
    
    weak var delegate: DealTableViewCellViewModelDelegate?
    
    init(deal: Deal) {
        self.deal = deal
    }
    
    var eventName: String {
        return deal.name
    }
    
    var dealID: String {
        return deal.dealID
    }
    
    var notes: String {
        if deal.notes == "" {
            return "אין הערות"
        } else {
            return deal.notes ?? "אין הערות"
        }
    }
    
    var phone: String {
        return deal.phone
    }
    
    var location: String {
        return deal.location ?? ""
    }
    
    var time: String {
        if deal.isAllDay {
            return "יום שלם"
        } else {
            dateFormatter.locale = Locale(identifier: "He")
            dateFormatter.dateFormat = "HH:mm"
            let startTime = dateFormatter.string(from: deal.startDate)
            let endTime = dateFormatter.string(from: deal.endDate)
            return "\(startTime) : \(endTime)"
        }
    }
    
    func didTapNotesButton() {
        if isNotesButtonIsOpen {
            self.delegate?.changeNotesLabelVisability(toPresent: false)
        } else {
            self.delegate?.changeNotesLabelVisability(toPresent: true)
        }
        isNotesButtonIsOpen = !isNotesButtonIsOpen
    }
    
    var reminderTitle: String {
        return deal.reminder
    }
}
