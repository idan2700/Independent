//
//  IncomeTableViewCellViewModel.swift
//  Independent
//
//  Created by Idan Levi on 10/12/2021.
//

import Foundation

class IncomeTableViewCellViewModel {
    
    private var income: Income
    private var dateFormatter = DateFormatter()
    private var currentPresentedMonth: Date
    
    init(income: Income, currentPresentedMonth: Date) {
        self.income = income
        self.currentPresentedMonth = currentPresentedMonth
    }
    
    var payments: String? {
        if income.type == .payments {
            if let index = income.dates.firstIndex(where: {(dateFormatter.string(from: $0) == dateFormatter.string(from: currentPresentedMonth))}) {
                return "\(index + 1) מתוך \(income.numberOfPayments ?? 0)"
            }
            return ""
        } else if income.type == .permanent {
            return "הכנסה קבועה"
        } else {
            return nil
        }
    }
    
    var amount: String {
        if income.type == .payments {
            guard let numberOfPayments = income.numberOfPayments else {return "\(income.amount) שח"}
            return "\(income.amount / numberOfPayments) שח"
        }
        return "\(income.amount) שח"
    }
    
    var date: String {
        dateFormatter.dateFormat = "dd"
        dateFormatter.locale = Locale(identifier: "He")
        let dayString = dateFormatter.string(from: income.dates[0])
        dateFormatter.dateFormat = "MM"
        let monthString = dateFormatter.string(from: currentPresentedMonth)
        return "\(dayString)/\(monthString)"
    }
    
    var name: String {
        return income.name
    }
}
