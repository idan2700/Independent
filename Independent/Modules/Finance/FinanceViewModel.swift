//
//  FinanceViewModel.swift
//  Independent
//
//  Created by Idan Levi on 10/12/2021.
//

import Foundation
import Firebase

protocol FinanceViewModelDelegate: AnyObject {
    func reloadData()
    func updateCurrentMonthLabel()
    func moveToCreateIncomeVC(isNewIncome: Bool, exsitingIncome: Income?)
    func presentErrorAlert(message: String)
    func presentIsDealError(title: String, message: String)
    func moveToCreateOutcomeVC(isNewOutcome: Bool, exsitingOutcome: Outcome?)
    func deleteOutcomeRow(at indexPath: IndexPath)
    func deleteIncomeRow(at indexPath: IndexPath)
    func manageSegmantApperance()
}

class FinanceViewModel {
    
    private let dateFormatter = DateFormatter()
    private var date = Date()
    private var currentMonthIncomes = [Income]()
    private var currentMonthOutcomes = [Outcome]()
    private var currentMonthCounter: Int = 0
    weak var delegate: FinanceViewModelDelegate?
    
    init(delegate: FinanceViewModelDelegate?) {
        self.delegate = delegate
    }
    
    func start() {
        checkIfIncomesAreEqualToCurrentPresentedMonth()
        checkIfOutcomesAreEqualToCurrentPresentedMonth()
        delegate?.reloadData()
    }
    
    var numberOfItems: Int {
        return FinanceItems.allCases.count
    }
    
    func getItemViewModel(at indexPath: IndexPath) -> FinanceCollectionViewCellViewModel {
        return FinanceCollectionViewCellViewModel(item: FinanceItems(rawValue: indexPath.row), incomes: currentMonthIncomes, outcomes: currentMonthOutcomes)
    }
    
    var numberOfIncomeRaws: Int {
        return currentMonthIncomes.count
    }
    
    func getIncomeCellViewModel(at indexPath: IndexPath) -> IncomeTableViewCellViewModel {
        return IncomeTableViewCellViewModel(income: currentMonthIncomes[indexPath.row], currentPresentedMonth: date)
    }
    
    var numberOfOutcomeRaws: Int {
        return currentMonthOutcomes.count
    }
    
    func getOutcomeCellViewModel(at indexPath: IndexPath) -> OutcomeTableViewCellViewModel {
        return OutcomeTableViewCellViewModel(outcome: currentMonthOutcomes[indexPath.row], currentPresentedMonth: date)
    }
    
    var totalIncomes: String {
        var total = 0
        for income in currentMonthIncomes {
            if income.type == .payments {
                guard let numberOfPayments = income.numberOfPayments else {return "0"}
                total += income.amount / numberOfPayments
            } else {
                total += income.amount
            }
        }
        return "סה״כ:  \(String(total)) שח"
    }
    
    var totalOutcomes: String {
        var total = 0
        for outcome in currentMonthOutcomes {
            if outcome.type == .payments {
                guard let numberOfPayments = outcome.numberOfPayments else {return "0"}
                total += outcome.amount / numberOfPayments
            } else {
                total += outcome.amount
            }
        }
        return "סה״כ:  \(String(total)) שח"
    }
    
    var stringDate: String {
        dateFormatter.dateFormat = "MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "He")
         return dateFormatter.string(from: date)
    }
    
    func didTapNextMonth(currentPresentedMonth: String) {
        currentMonthCounter += 1
        currentMonthIncomes = []
        currentMonthOutcomes = []
        date = Calendar.current.date(byAdding: .month, value: 1, to: date) ?? Date()
        checkIfIncomesAreEqualToCurrentPresentedMonth()
        checkIfOutcomesAreEqualToCurrentPresentedMonth()
        delegate?.updateCurrentMonthLabel()
        delegate?.reloadData()
    }
    
    func didTapLastMonth() {
        currentMonthCounter -= 1
        currentMonthIncomes = []
        currentMonthOutcomes = []
        date = Calendar.current.date(byAdding: .month, value: -1, to: date) ?? Date()
        checkIfIncomesAreEqualToCurrentPresentedMonth()
        checkIfOutcomesAreEqualToCurrentPresentedMonth()
        delegate?.updateCurrentMonthLabel()
        delegate?.reloadData()
    }
    
    func didTapAdd(index: Int) {
        switch index {
        case 0:
            didTapAddIncome()
        case 1:
            didTapAddOutcome()
        default:
            break
        }
    }
    
    func didTapAddIncome() {
        delegate?.moveToCreateIncomeVC(isNewIncome: true, exsitingIncome: nil)
    }
    
    func didTapAddOutcome() {
        delegate?.moveToCreateOutcomeVC(isNewOutcome: true, exsitingOutcome: nil)
    }
    
    func didPickNewIncome(income: Income) {
        FinanceManager.shared.allIncomes.removeAll(where: {$0.id == income.id})
        FinanceManager.shared.allIncomes.append(income)
        checkIfIncomesAreEqualToCurrentPresentedMonth()
        delegate?.reloadData()
    }
    
    func didPickNewOutcome(outcome: Outcome) {
        FinanceManager.shared.allOutcomes.removeAll(where: {$0.id == outcome.id})
        FinanceManager.shared.allOutcomes.append(outcome)
        checkIfOutcomesAreEqualToCurrentPresentedMonth()
        delegate?.reloadData()
    }
    
    func didChangeSegmant() {
        delegate?.manageSegmantApperance()
    }
    
    func didTapDeleteIncome(at indexPath: IndexPath) {
        let income = currentMonthIncomes[indexPath.row]
        if income.isDeal {
            delegate?.presentIsDealError(title: "לא ניתן למחוק הכנסה מעסקה", message: "יש לבצע ביטול עסקה ביומן")
        } else {
            guard let currentUserID = Auth.auth().currentUser?.uid else {return}
            FinanceManager.shared.deleteIncome(incomeId: String(income.id), userID: currentUserID) { [weak self] result in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        FinanceManager.shared.allIncomes.removeAll(where: {$0.id == income.id})
                        self.checkIfIncomesAreEqualToCurrentPresentedMonth()
                        self.delegate?.deleteIncomeRow(at: indexPath)
                    case .failure(_):
                        self.delegate?.presentErrorAlert(message: "נוצרה בעיה בפניה לשרת לצורך המחיקה, אנא נסה שנית")
                    }
                }
            }
        }
    }
    
    func presentIncomeNoLabel() -> Bool {
        if currentMonthIncomes.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    func presentOutcomeNoLabel() -> Bool {
        if currentMonthOutcomes.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    func didTapDeleteOutcome(at indexPath: IndexPath) {
        let outcome = currentMonthOutcomes[indexPath.row]
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        FinanceManager.shared.deleteOutcome(outcomeId: String(outcome.id), userID: currentUserID) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success():
                    FinanceManager.shared.allOutcomes.removeAll(where: {$0.id == outcome.id})
                    self.checkIfOutcomesAreEqualToCurrentPresentedMonth()
                    self.delegate?.deleteOutcomeRow(at: indexPath)
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "נוצרה בעיה בפניה לשרת לצורך המחיקה, אנא נסה שנית")
                }
            }
        }
    }
    
    func didTapEditIncome(at indexPath: IndexPath) {
        let income = currentMonthIncomes[indexPath.row]
            delegate?.moveToCreateIncomeVC(isNewIncome: false, exsitingIncome: income)
    }
    
    func didTapEditOutcome(at indexPath: IndexPath) {
        let outcome = currentMonthOutcomes[indexPath.row]
        delegate?.moveToCreateOutcomeVC(isNewOutcome: false, exsitingOutcome: outcome)
    }
    
    private func checkIfIncomesAreEqualToCurrentPresentedMonth() {
        currentMonthIncomes = []
        for income in FinanceManager.shared.allIncomes {
            self.dateFormatter.dateFormat = "MMMM, yyyy"
            self.dateFormatter.locale = Locale(identifier: "He")
            let currentMonth = self.dateFormatter.string(from: date)
            for date in income.dates {
                if self.dateFormatter.string(from: date) == currentMonth {
                    self.currentMonthIncomes.append(income)
                } else if income.type == .permanent {
                    self.currentMonthIncomes.append(income)
                }
            }
        }
    }
    
    private func checkIfOutcomesAreEqualToCurrentPresentedMonth() {
        currentMonthOutcomes = []
        for outcome in FinanceManager.shared.allOutcomes {
            self.dateFormatter.dateFormat = "MMMM, yyyy"
            self.dateFormatter.locale = Locale(identifier: "He")
            let currentMonth = self.dateFormatter.string(from: date)
            for date in outcome.dates {
                if self.dateFormatter.string(from: date) == currentMonth {
                    self.currentMonthOutcomes.append(outcome)
                } else if outcome.type == .permanent {
                    self.currentMonthOutcomes.append(outcome)
                }
            }
        }
    }
}
