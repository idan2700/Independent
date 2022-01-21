//
//  Outcome.swift
//  Independent
//
//  Created by Idan Levi on 31/12/2021.
//

import Foundation

struct Outcome {
    let amount: Int
    let dates: [Date]
    let name: String
    let id: Int
    let type: OutcomeType
    let numberOfPayments: Int?
}

enum OutcomeType: String {
    case oneTime = "חד פעמית"
    case payments = "תשלומים"
    case permanent = "קבועה"
}
