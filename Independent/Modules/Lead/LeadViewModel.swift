//
//  LeadViewModel.swift
//  Independent
//
//  Created by Idan Levi on 28/10/2021.
//

import Foundation

protocol LeadViewModelDelegate: AnyObject {
    func updateCurrentMonthLabel()
}

class LeadViewModel {
    
    weak var delegate: LeadViewModelDelegate?
    
    private let dateFormatter = DateFormatter()
    private var date = Date()
    private var leads = [Lead]()
    
    init(delegate: LeadViewModelDelegate?) {
        self.delegate = delegate
        leads.append(Lead(fullName: "עידן לוי", date: Date(), summary: ""))
        leads.append(Lead(fullName: "עידן לוי", date: Date(), summary: ""))
        leads.append(Lead(fullName: "עידן לוי", date: Date(), summary: ""))
        leads.append(Lead(fullName: "עידן לוי", date: Date(), summary: ""))
        leads.append(Lead(fullName: "עידן לוי", date: Date(), summary: ""))
        leads.append(Lead(fullName: "עידן לוי", date: Date(), summary: ""))
        leads.append(Lead(fullName: "עידן לוי", date: Date(), summary: ""))
        leads.append(Lead(fullName: "עידן לוי", date: Date(), summary: ""))
    }
    
    var numberOfItems: Int {
        return leadItems.allCases.count
    }
    
    func getItemViewModel(at indexPath: IndexPath) -> LeadCollectionViewCellViewModel {
        return LeadCollectionViewCellViewModel(itemType: leadItems(rawValue: indexPath.row))
    }
    
    var numberOfCells: Int {
        return leads.count
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> LeadTableViewCellViewModel {
        return LeadTableViewCellViewModel(lead: leads[indexPath.row])
    }
    
    var stringDate: String {
        dateFormatter.dateFormat = "MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "He")
         return dateFormatter.string(from: date)
    }
    
    func didTapNextMonth() {
        date = Calendar.current.date(byAdding: .month, value: 1, to: date) ?? Date()
        delegate?.updateCurrentMonthLabel()
    }
    
    func didTapLastMonth() {
        date = Calendar.current.date(byAdding: .month, value: -1, to: date) ?? Date()
        delegate?.updateCurrentMonthLabel()
    }
    
}
