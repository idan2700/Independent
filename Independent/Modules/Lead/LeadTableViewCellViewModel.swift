//
//  LeadTableViewCellViewModel.swift
//  Independent
//
//  Created by Idan Levi on 29/10/2021.
//

import Foundation

protocol LeadTableViewCellViewModelDelegate: AnyObject {
    
}

class LeadTableViewCellViewModel {
    
    weak var delegate: LeadTableViewCellViewModelDelegate?
    private var lead: Lead
    
    init(lead: Lead) {
        self.lead = lead
    }
    
    var nameLabel: String {
        return lead.fullName
    }
    
    var dateLabel: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        dateFormatter.locale = Locale(identifier: "He")
        return dateFormatter.string(from: lead.date)
    }
}
