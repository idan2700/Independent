//
//  LeadCollectionViewCellViewModel.swift
//  Independent
//
//  Created by Idan Levi on 28/10/2021.
//

import Foundation
import UIKit

class LeadCollectionViewCellViewModel {
    
    private var item: leadItems?
    private var indexPath: IndexPath
    private var leads: [Lead]
    private var precentOfSales: Int?
    
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
            let numberOfSales = leads.filter({$0.status == .deal}).count
            let numberOfLeads = leads.count
            if numberOfLeads != 0 {
                let precent = Float(numberOfSales) / Float(numberOfLeads) * 100
                self.precentOfSales = Int(precent)
            return "\(Int(precent))%"
            } else {
                return "0"
            }
        case .numberOfSales:
            return String(leads.filter({$0.status == .deal}).count)
        case .numberOfLeads:
            return String(leads.count) 
        }
    }
    
    var amountLabelColor: UIColor {
        guard let leadItems = leadItems(rawValue: indexPath.row) else {return UIColor(named: "gold")!}
        switch leadItems {
        case .numberOfLeads:
            return UIColor(named: "gold")!
        case .numberOfSales:
            return UIColor(named: "gold")!
        case .precentOfSales:
            guard let precentOfSales = precentOfSales else { return UIColor(named: "gold")!}
            if precentOfSales < 6 {
                return UIColor(named: "darkred")!
            } else if precentOfSales > 19 {
                return UIColor(named: "darkgreen")!
            } else {
                return UIColor(named: "gold")!
            }
        }
    }
}

enum leadItems: Int, CaseIterable {
    case numberOfLeads
    case numberOfSales
    case precentOfSales
    
    
    var itemLabel: String {
        switch self {
        case .numberOfLeads:
            return "כמות לידים"
        case .numberOfSales:
            return "כמות סגירות"
        case .precentOfSales:
            return "אחוז סגירות"
        }
    }
}
