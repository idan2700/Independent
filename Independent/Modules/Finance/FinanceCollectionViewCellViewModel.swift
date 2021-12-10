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
    private var totalIncomes = 0
    private var totalOutcomes = 0
    
    init(item: FinanceItems?, incomes: [Income]) {
        self.item = item
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
                totalIncomes += income.amount
            }
            return String(totalIncomes)
        case .outcomes:
            return "0"
        case .profit:
            var totalIncomes = 0
            for income in incomes {
                totalIncomes += income.amount
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
            for income in incomes {
                totalIncomes += income.amount
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

