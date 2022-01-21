//
//  FinanceCollectionViewCellViewModel.swift
//  Independent
//
//  Created by Idan Levi on 10/12/2021.
//

import Foundation
import UIKit

class FinanceCollectionViewCellViewModel {
    private var item: FinanceItems?
    private var incomes: [Income]
    private var outcomes: [Outcome]
    private var totalIncomes = 0
    private var totalOutcomes = 0
    
    init(item: FinanceItems?, incomes: [Income], outcomes: [Outcome]) {
        self.item = item
        self.outcomes = outcomes
        self.incomes = incomes
    }
   
    var itemLabel: String {
        return item?.itemLabel ?? ""
    }
    
    var amount: String {
        guard let item = item else { return "0" }
        switch item {
        case .incomes:
            for income in incomes {
                if income.type == .payments {
                    guard let numberOfPayments = income.numberOfPayments else {return "0"}
                    totalIncomes += income.amount / numberOfPayments
                } else {
                    totalIncomes += income.amount
                }
            }
            return String(totalIncomes)
        case .outcomes:
            for outcome in outcomes {
                if outcome.type == .payments {
                    guard let numberOfPayments = outcome.numberOfPayments else {return "0"}
                    totalOutcomes += outcome.amount / numberOfPayments
                } else {
                    totalOutcomes += outcome.amount
                }
            }
            return String(totalOutcomes)
        case .profit:
            var totalIncomes = 0
            for income in incomes {
                if income.type == .payments {
                    guard let numberOfPayments = income.numberOfPayments else {return "0"}
                    totalIncomes += income.amount / numberOfPayments
                } else {
                    totalIncomes += income.amount
                }
            }
            var totalOutcomes = 0
            for outcome in outcomes {
                if outcome.type == .payments {
                    guard let numberOfPayments = outcome.numberOfPayments else {return "0"}
                    totalOutcomes += outcome.amount / numberOfPayments
                } else {
                    totalOutcomes += outcome.amount
                }
            }
            return String(totalIncomes - totalOutcomes)
        }
    }
    
    var amountLabelColor: UIColor {
        guard let item = item else { return UIColor(named: "gold")! }
        switch item {
        case .incomes:
            return UIColor(named: "gold")!
        case .outcomes:
            return UIColor(named: "gold")!
        case .profit:
            var totalIncomes = 0
            var totalOutcomes = 0
            for income in incomes {
                if income.type == .payments {
                    guard let numberOfPayments = income.numberOfPayments else {return UIColor(named: "gold")!}
                    totalIncomes += income.amount / numberOfPayments
                } else {
                totalIncomes += income.amount
                }
            }
            for outcome in outcomes {
                if outcome.type == .payments {
                    guard let numberOfPayments = outcome.numberOfPayments else {return UIColor(named: "gold")!}
                    totalOutcomes += outcome.amount / numberOfPayments
                } else {
                totalOutcomes += outcome.amount
                }
            }
            if totalIncomes - totalOutcomes > 0 {
                return UIColor(named: "darkgreen")!
            } else if totalIncomes - totalOutcomes < 0 {
                return UIColor(named: "darkred")!
            } else {
            return UIColor(named: "gold")!
            }
        }
    }
}

enum FinanceItems: Int, CaseIterable {
    case incomes
    case outcomes
    case profit
    
    
    var itemLabel: String {
        switch self {
        case .incomes:
            return "סה״כ הכנסות"
        case .outcomes:
            return "סה״כ הוצאות"
        case .profit:
            return "סה״כ רווח"
        }
    }
}

