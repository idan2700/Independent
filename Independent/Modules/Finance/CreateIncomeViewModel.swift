//
//  CreateIncomeViewModel.swift
//  Independent
//
//  Created by Idan Levi on 10/12/2021.
//

import Foundation
import Firebase

protocol CreateIncomeViewModelDelegate: AnyObject {
    func returnToFinanceVC(with income: Income)
    func presentAlert(message: String)
    func changeErrorNameVisability(toPresent: Bool)
    func changePriceErrorVisability(toPresent: Bool)
}

class CreateIncomeViewModel {
    
    
    private var isNewIncome: Bool
    weak var delegate: CreateIncomeViewModelDelegate?
    var exsitingIncome: Income?
    
    init(delegate: CreateIncomeViewModelDelegate?, isNewIncome: Bool) {
        self.isNewIncome = isNewIncome
        self.delegate = delegate
    }
    
    var title: String {
        if let exsitingIncome = exsitingIncome {
            return exsitingIncome.name
        } else {
            return ""
        }
    }
    
    var amount: String {
        if let exsitingIncome = exsitingIncome {
            return String(exsitingIncome.amount)
        } else {
            return ""
        }
    }
    
    var date: Date {
        if let exsitingIncome = exsitingIncome {
            return exsitingIncome.date
        } else {
            return Date()
        }
    }
    
    func didTapAdd(title: String, amount: String, date: Date) {
        if validated(title: title, amount: amount) {
            guard let currentUser = Auth.auth().currentUser?.uid else {return}
            guard let amount = Int(amount) else {return}
            let income = Income(amount: amount, date: date, name: title, id: FinanceManager.shared.genrateIncomeID(), isDeal: false, eventStoreId: nil)
            FinanceManager.shared.saveIncome(income: income, userName: currentUser) { [weak self] result in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        self.delegate?.returnToFinanceVC(with: income)
                    case .failure(_):
                        self.delegate?.presentAlert(message: "שגיאה בשמירת המתעניין לשרת, אנא נסה שוב")
                    }
                }
            }
        } else {
            return
        }
    }
    
    private func validated(title: String, amount: String)-> Bool {
        if title.isEmpty {
            self.delegate?.changeErrorNameVisability(toPresent: true)
            return false
        }
        if amount.isEmpty {
            self.delegate?.changePriceErrorVisability(toPresent: true)
            return false
        }
       return true
    }
    
    func didEditTitle(title: String) {
        if title.isEmpty {
            self.delegate?.changeErrorNameVisability(toPresent: true)
            return
        } else {
            self.delegate?.changeErrorNameVisability(toPresent: false)
            return
        }
    }
    
    func didEditAmount(amount: String) {
        if amount.isEmpty {
            self.delegate?.changePriceErrorVisability(toPresent: true)
            return
        } else {
            self.delegate?.changePriceErrorVisability(toPresent: false)
            return
        }
    }
}
