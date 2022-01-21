//
//  CreateOutcomeViewModel.swift
//  Independent
//
//  Created by Idan Levi on 31/12/2021.
//

import Foundation
import Firebase

protocol CreateOutcomeViewModelDelegate: AnyObject {
    func returnToFinanceVC(with income: Outcome)
    func presentAlert(message: String)
    func changeErrorNameVisability(toPresent: Bool)
    func changePriceErrorVisability(toPresent: Bool)
    func changeIncomeTypeButtonUI(currentSelectedButton: String)
    func changePaymentsPickerVisability(toPresent: Bool)
}

class CreateOutcomeViewModel {
    
    var payments = [String]()
    private var isNewOutcome: Bool
    weak var delegate: CreateOutcomeViewModelDelegate?
    var exsitingOutcome: Outcome?
    private var selectedType: OutcomeType = .oneTime
    var numberOfPayments: Int?
    
    init(delegate: CreateOutcomeViewModelDelegate?, isNewOutcome: Bool) {
        self.isNewOutcome = isNewOutcome
        self.delegate = delegate
        for number in 2...60 {
            payments.append(String(number))
        }
    }
    
    var numberOfRaws: Int {
        return payments.count
    }
    
    var title: String {
        if let exsitingOutcome = exsitingOutcome {
            return exsitingOutcome.name
        } else {
            return ""
        }
    }
    
    var amount: String {
        if let exsitingOutcome = exsitingOutcome {
            return String(exsitingOutcome.amount)
        } else {
            return ""
        }
    }
    
    var date: Date {
        if let exsitingOutcome = exsitingOutcome {
            return exsitingOutcome.dates[0]
        } else {
            return Date()
        }
    }
    
    func start() {
        if let exsitingOutcome = exsitingOutcome {
            didTapIncomeType(type: exsitingOutcome.type.rawValue)
        }
    }
    
    func didTapAdd(title: String, amountString: String, date: Date) {
        if validated(title: title, amount: amountString) {
            var dates = [Date]()
            dates.append(date)
            guard let currentUser = Auth.auth().currentUser?.uid else {return}
            guard let amount = Int(amountString) else {return}
            if let numberOfPayments = numberOfPayments  {
                if selectedType == .payments {
                    var dateHolder = date
                    for _ in 1..<numberOfPayments {
                        let paymentDate = Calendar.current.date(byAdding: .month, value: 1, to: dateHolder) ?? Date()
                        dates.append(paymentDate)
                       dateHolder = paymentDate
                    }
                }
            }
            if self.isNewOutcome {
                let outcome = Outcome(amount: amount, dates: dates, name: title, id: FinanceManager.shared.genrateIncomeID(), type: selectedType, numberOfPayments: numberOfPayments)
                FinanceManager.shared.saveOutcome(outcome: outcome, userName: currentUser) { [weak self] result in
                    guard let self = self else {return}
                    DispatchQueue.main.async {
                        switch result {
                        case .success():
                            self.delegate?.returnToFinanceVC(with: outcome)
                        case .failure(_):
                            self.delegate?.presentAlert(message: "שגיאה בשמירת המתעניין לשרת, אנא נסה שוב")
                        }
                    }
                }
            } else {
                guard let existingOutcome = exsitingOutcome else {return}
                let outcome = Outcome(amount: amount, dates: dates, name: title, id: existingOutcome.id, type: selectedType, numberOfPayments: numberOfPayments)
                FinanceManager.shared.editOutcome(outcome: outcome, userName: currentUser) { [weak self] result in
                    guard let self = self else {return}
                    DispatchQueue.main.async {
                        switch result {
                        case .success():
                            self.delegate?.returnToFinanceVC(with: outcome)
                        case .failure(_):
                            self.delegate?.presentAlert(message: "שגיאה בשמירת ההוצאה לשרת, אנא נסה שוב")
                        }
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
    
    func didTapIncomeType(type: String) {
        switch type {
        case IncomeType.oneTime.rawValue:
            self.delegate?.changeIncomeTypeButtonUI(currentSelectedButton: IncomeType.oneTime.rawValue)
            self.delegate?.changePaymentsPickerVisability(toPresent: false)
            self.selectedType = .oneTime
            self.numberOfPayments = nil
        case IncomeType.payments.rawValue:
            self.delegate?.changeIncomeTypeButtonUI(currentSelectedButton: IncomeType.payments.rawValue)
            self.delegate?.changePaymentsPickerVisability(toPresent: true)
            self.selectedType = .payments
            self.numberOfPayments = 4
        case IncomeType.permanent.rawValue:
            self.delegate?.changeIncomeTypeButtonUI(currentSelectedButton: IncomeType.permanent.rawValue)
            self.delegate?.changePaymentsPickerVisability(toPresent: false)
            self.selectedType = .permanent
            self.numberOfPayments = nil
        default:
            break
        }
    }
}
