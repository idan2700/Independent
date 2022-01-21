//
//  OutcomeTableViewCellViewModel.swift
//  Independent
//
//  Created by Idan Levi on 31/12/2021.
//

import Foundation

class OutcomeTableViewCellViewModel {
    private var outcome: Outcome
    private var dateFormatter = DateFormatter()
    private var currentPresentedMonth: Date
    
    init(outcome: Outcome, currentPresentedMonth: Date) {
        self.outcome = outcome
        self.currentPresentedMonth = currentPresentedMonth
    }
    
    var payments: String? {
        if outcome.type == .payments {
            if let index = outcome.dates.firstIndex(where: {(dateFormatter.string(from: $0) == dateFormatter.string(from: currentPresentedMonth))}) {
                return "\(index + 1) מתוך \(outcome.numberOfPayments ?? 0)"
            }
            return ""
        } else if outcome.type == .permanent {
            return "הוצאה קבועה"
        } else {
            return nil
        }
    }
    
    var amount: String {
        if outcome.type == .payments {
            guard let numberOfPayments = outcome.numberOfPayments else {return "\(outcome.amount) שח"}
            return "\(outcome.amount / numberOfPayments) שח"
        }
        return "\(outcome.amount) שח"
    }
    
    var date: String {
        dateFormatter.dateFormat = "dd"
        dateFormatter.locale = Locale(identifier: "He")
        let dayString = dateFormatter.string(from: outcome.dates[0])
        dateFormatter.dateFormat = "MM"
        let monthString = dateFormatter.string(from: currentPresentedMonth)
        return "\(dayString)/\(monthString)"
    }
    
    var name: String {
        return outcome.name
    }
}
