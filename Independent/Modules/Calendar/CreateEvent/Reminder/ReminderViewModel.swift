//
//  ReminderViewModel.swift
//  Independent
//
//  Created by Idan Levi on 03/12/2021.
//

import Foundation

class ReminderViewModel {
    
    var numberOfRaws: Int {
        return ReminderTime.allCases.count
    }
    
    func getCellViewModel(at indexPath: IndexPath)-> ReminderTableViewCellViewModel {
        return ReminderTableViewCellViewModel(index: indexPath.row)
    }
}
