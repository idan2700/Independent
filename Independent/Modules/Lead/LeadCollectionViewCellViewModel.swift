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
    
    var itemLabel: String {
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
    
    private var item: leadItems?
    private var indexPath: IndexPath
    private var leads: [Lead]
    
    init(item: leadItems?, indexPath: IndexPath, leads: [Lead]) {
        self.item = item
        self.indexPath = indexPath
        self.leads = leads
    }
   
    var itemLabel: String {
        return item?.itemLabel ?? ""
    }
    
    var amount: String {
        guard let leadItems = leadItems(rawValue: indexPath.row) else {return "0"}
        switch leadItems {
        case .precentOfSales:
            break
        case .numberOfSales:
            break
        case .numberOfLeads:
            return String(leads.count) 
        }
        return "0"
    }
}
