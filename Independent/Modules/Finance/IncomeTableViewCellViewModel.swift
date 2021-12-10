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
    
    init(income: Income) {
        self.income = income
    }
    
    var amount: String {
        return String(income.amount)
    }
    
    var date: String {
        dateFormatter.dateFormat = "dd/MM"
        dateFormatter.locale = Locale(identifier: "He")
        return dateFormatter.string(from: income.date)
    }
    
    var name: String {
        return income.name
    }
}
