//
//  Lead.swift
//  Independent
//
//  Created by Idan Levi on 29/10/2021.
//

import Foundation

struct Lead {
    var fullName: String
    var date: Date
    var summary: String?
    var phoneNumber: String
    var leadID: String
    var status: Status
    var fuDate: Date?
}

enum Status {
    case open
    case closed
    case deal
    
    var statusString: String {
        switch self {
        case .open:
            return "פתוח"
        case .closed:
            return "סגור"
        case .deal:
            return "עסקה"
        }
    }
}
