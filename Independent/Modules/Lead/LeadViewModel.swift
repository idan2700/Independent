//
//  LeadViewModel.swift
//  Independent
//
//  Created by Idan Levi on 28/10/2021.
//

import Foundation

protocol LeadViewModelDelegate: AnyObject {
    func updateCurrentMonthLabel()
    func moveToCreateLeadVC()
    func animateNewLeadButton(toOpen: Bool)
}

class LeadViewModel {
    
    weak var delegate: LeadViewModelDelegate?
    
    private let dateFormatter = DateFormatter()
    private var date = Date()
    private var leads = [Lead]()
    private var isNewLeadButtonSelected: Bool = false

    
    init(delegate: LeadViewModelDelegate?) {
        self.delegate = delegate
        leads.append(Lead(fullName: "עידן לוי", date: Date(), summary: "", phoneNumber: ""))
        leads.append(Lead(fullName: "עידן לוי", date: Date(), summary: "jkbds jkbcndjksc jkbn kcjdsc kjn jdshc kj kjbkjds ckj kjnbkjds ckjn kjn ckjdsnckj jckjdsnckjnkj ckdjnjkn kjnc kjsdn k", phoneNumber: ""))
        leads.append(Lead(fullName: "עידן לוי", date: Date(), summary: "", phoneNumber: ""))
        leads.append(Lead(fullName: "עידן לוי", date: Date(), summary: "", phoneNumber: ""))
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
    
    func didTapCreateNewLead() {
        isNewLeadButtonSelected = !isNewLeadButtonSelected
        delegate?.animateNewLeadButton(toOpen: isNewLeadButtonSelected)
    }

    
    func didTapAddManualy() {
        delegate?.moveToCreateLeadVC()
    }
    
}
