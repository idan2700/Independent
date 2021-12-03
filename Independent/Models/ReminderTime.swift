//
//  ReminderTime.swift
//  Independent
//
//  Created by Idan Levi on 03/12/2021.
//

import Foundation
import UIKit

enum ReminderTime: Int, CaseIterable {
    case none
    case one
    case five
    case ten
    case fiftin
    case therthy
    case oneHour
    case twoHours
    case oneDay
    
    var reminderTimeTitle: String {
        switch self {
        case .none:
            return "ללא"
        case .one:
            return "דקה לפני"
        case .five:
            return "5 דקות לפני"
        case .ten:
            return "10 דקות לפני"
        case .fiftin:
            return "רבע שעה לפני"
        case .therthy:
            return "חצי שעה לפני"
        case .oneHour:
            return "שעה לפני"
        case .twoHours:
            return "שעתיים לפני"
        case .oneDay:
            return "יום לפני"
        }
    }
    
    var reminderTime: Int? {
        switch self {
        case .none:
            return nil
        case .one:
            return 1
        case .five:
            return 5
        case .ten:
            return 10
        case .fiftin:
            return 15
        case .therthy:
            return 30
        case .oneHour:
            return 60
        case .twoHours:
            return 120
        case .oneDay:
            return 1440
        }
    }
    
    var cellSpace: Int {
        switch self {
        case .none:
            return 0
        case .one:
            return 30
        case .five:
            return 0
        case .ten:
            return 0
        case .fiftin:
            return 0
        case .therthy:
            return 0
        case .oneHour:
            return 0
        case .twoHours:
            return 0
        case .oneDay:
            return 0
        }
    }
    
    var color: UIColor {
        switch self {
        case .none:
            return .clear
        case .one:
            return UIColor(named: "30white")!
        case .five:
            return UIColor(named: "30white")!
        case .ten:
            return UIColor(named: "30white")!
        case .fiftin:
            return UIColor(named: "30white")!
        case .therthy:
            return UIColor(named: "30white")!
        case .oneHour:
            return UIColor(named: "30white")!
        case .twoHours:
            return UIColor(named: "30white")!
        case .oneDay:
            return .clear
        }
    }
}
