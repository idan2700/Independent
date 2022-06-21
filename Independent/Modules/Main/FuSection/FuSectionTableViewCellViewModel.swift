//
//  FuSectionTableViewCellViewModel.swift
//  Independent
//
//  Created by Idan Levi on 21/06/2022.
//

import Foundation

protocol FuSectionTableViewCellViewModelDelegate: AnyObject {
    func presentErrAlert(message: String)
    func moveToFuDateVC(lead: Lead)
}

class FuSectionTableViewCellViewModel {
    
    weak var delegate: FuSectionTableViewCellViewModelDelegate?
    
    var numberOfRows: Int {
        return LeadManager.shared.todaysFu.count
    }
    
    func viewModelForCell(at indexPath: IndexPath)-> FuTableViewCellViewModel {
        return FuTableViewCellViewModel(lead: LeadManager.shared.todaysFu[indexPath.row], delegate: self)
    }
    
    func didTapDelete(at indexPath: IndexPath) {
        
    }
    
    func didTapMakeDeal(at indexPath: IndexPath) {
        
    }
    
    func didTapLockLead(at indexPath: IndexPath) {
        
    }
    
    func didTapChangeFuDate(at indexPath: IndexPath) {
        delegate?.moveToFuDateVC(lead: LeadManager.shared.todaysFu[indexPath.row])
    }
}

extension FuSectionTableViewCellViewModel: FuTableViewCellViewModelDelegate {
    func presentAlert(message: String) {
        self.delegate?.presentErrAlert(message: message)
    }
}
