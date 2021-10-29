//
//  LeadCollectionViewCellViewModel.swift
//  Independent
//
//  Created by Idan Levi on 28/10/2021.
//

import Foundation

enum leadItems: Int, CaseIterable {
    case precentOfSales
    case numberOfSales
    case numberOfLeads

    var itemTypeLabel: String {
        switch self {
        case .numberOfLeads:
            return "כמות מתעניינים"
        case .numberOfSales:
            return "כמות סגירות"
        case .precentOfSales:
            return "אחוז סגירות"
        }
    }
}

class LeadCollectionViewCellViewModel {
    
    var itemType: leadItems?
    
    init(itemType: leadItems?) {
        self.itemType = itemType
    }
   
    
    var itemTypeLabel: String {
        return itemType?.itemTypeLabel ?? ""
    }
}
