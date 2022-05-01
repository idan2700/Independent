//
//  Income.swift
//  Independent
//
//  Created by Idan Levi on 10/12/2021.
//

import Foundation

struct Income {
    let amount: Int
    let dates: [Date]
    let name: String
    let id: String
    let isDeal: Bool
    let eventStoreId: String?
    let type: IncomeType
    let numberOfPayments: Int?
}

enum IncomeType: String {
    case oneTime = "חד פעמית"
    case payments = "תשלומים"
    case permanent = "קבועה"
}
