//
//  LeadTableViewCellViewModel.swift
//  Independent
//
//  Created by Idan Levi on 29/10/2021.
//

import Foundation
import UIKit

protocol LeadTableViewCellViewModelDelegate: AnyObject {
    func changeCellView(status: Status)
}

class LeadTableViewCellViewModel {
    
    weak var delegate: LeadTableViewCellViewModelDelegate?
    var lead: Lead
    
    init(lead: Lead) {
        self.lead = lead
    }
    
    var name: String {
        return lead.fullName
    }
    
    var date: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        dateFormatter.locale = Locale(identifier: "He")
        return dateFormatter.string(from: lead.date)
    }
    
    var summry: String {
        if lead.summary == "" {
            return "אין תקציר "
        } else {
        return lead.summary ?? ""
        }
    }
    
    var phone: String {
        return lead.phoneNumber
    }
}
