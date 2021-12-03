//
//  ReminderTableViewCellViewModel.swift
//  Independent
//
//  Created by Idan Levi on 03/12/2021.
//

import Foundation
import UIKit

class ReminderTableViewCellViewModel {
    
    private var index: Int
    
    init(index: Int) {
        self.index = index
    }
    
    var reminderTitle: String {
        guard let reminderTime = ReminderTime(rawValue: index) else {return ""}
        return reminderTime.reminderTimeTitle
    }
    
    var cellSpace: Int {
        guard let reminderTime = ReminderTime(rawValue: index) else {return 0}
        return reminderTime.cellSpace
    }
    
    var cellSpaceColor: UIColor {
        guard let reminderTime = ReminderTime(rawValue: index) else {return .clear}
        return reminderTime.color
    }
    
    var reminderTime: Int? {
        guard let reminderTime = ReminderTime(rawValue: index) else {return 0}
        return reminderTime.reminderTime
    }
}
