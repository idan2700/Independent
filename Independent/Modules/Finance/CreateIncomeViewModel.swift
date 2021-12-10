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
    
    private var incomeId = 0
    private var incomes: [Income]
    private var financeManager: FinanceManager
    weak var delegate: CreateIncomeViewModelDelegate?
    
    init(incomes: [Income], financeManager: FinanceManager, delegate: CreateIncomeViewModelDelegate?) {
        self.incomes = incomes
        self.financeManager = financeManager
        self.delegate = delegate
        if let incomeID = UserDefaults.standard.value(forKey: "incomeID") as? Int {
            self.incomeId = incomeID
        } else if let maxId = incomes.max(by: {$0.id < $1.id})?.id {
            self.incomeId = maxId
        }
    }
    
    func didTapAdd(title: String, amount: String, date: Date) {
        if validated(title: title, amount: amount) {
            guard let currentUser = Auth.auth().currentUser?.uid else {return}
            guard let amount = Int(amount) else {return}
            let income = Income(amount: amount, date: date, name: title, id: genrateIncomeID())
            financeManager.saveIncome(income: income, userName: currentUser) { [weak self] result in
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
    
    func genrateIncomeID()-> Int {
        let newId = incomeId + 1
        incomeId = newId
        UserDefaults.standard.set(newId, forKey: "incomeID")
        return incomeId
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
