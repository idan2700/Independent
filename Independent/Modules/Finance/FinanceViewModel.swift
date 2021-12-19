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
    func updateTotalIncomesLabel()
    func moveToCreateIncomeVC(isNewIncome: Bool, exsitingIncome: Income?)
    func presentErrorAlert(message: String)
    func presentIsDealError(title: String, message: String)
}

class FinanceViewModel {
    
    private let dateFormatter = DateFormatter()
    private var date = Date()
    private var currentMonthIncomes = [Income]()
    weak var delegate: FinanceViewModelDelegate?
    
    init(delegate: FinanceViewModelDelegate?) {
        self.delegate = delegate
    }
    
    func start() {
        checkIfIncomesAreEqualToCurrentPresentedMonth(currentPresentedMonth: date)
        delegate?.updateTotalIncomesLabel()
        delegate?.reloadData()
    }
    
    var numberOfItems: Int {
        return FinanceItems.allCases.count
    }
    
    func getItemViewModel(at indexPath: IndexPath) -> FinanceCollectionViewCellViewModel {
        return FinanceCollectionViewCellViewModel(item: FinanceItems(rawValue: indexPath.row), incomes: currentMonthIncomes)
    }
    
    var numberOfIncomeRaws: Int {
        return currentMonthIncomes.count
    }
    
    func getIncomeCellViewModel(at indexPath: IndexPath) -> IncomeTableViewCellViewModel {
        return IncomeTableViewCellViewModel(income: currentMonthIncomes[indexPath.row])
    }
    
    var totalIncomes: String {
        var total = 0
        for income in currentMonthIncomes {
            total += income.amount
        }
        return "סה״כ:  \(String(total)) שח"
    }
    
    var stringDate: String {
        dateFormatter.dateFormat = "MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "He")
         return dateFormatter.string(from: date)
    }
    
    func didTapNextMonth(currentPresentedMonth: String) {
        currentMonthIncomes = []
        date = Calendar.current.date(byAdding: .month, value: 1, to: date) ?? Date()
        checkIfIncomesAreEqualToCurrentPresentedMonth(currentPresentedMonth: date)
        delegate?.updateCurrentMonthLabel()
        delegate?.updateTotalIncomesLabel()
        delegate?.reloadData()
    }
    
    func didTapLastMonth() {
        currentMonthIncomes = []
        date = Calendar.current.date(byAdding: .month, value: -1, to: date) ?? Date()
        checkIfIncomesAreEqualToCurrentPresentedMonth(currentPresentedMonth: date)
        delegate?.updateCurrentMonthLabel()
        delegate?.updateTotalIncomesLabel()
        delegate?.reloadData()
    }
    
    func didTapAddIncome() {
        delegate?.moveToCreateIncomeVC(isNewIncome: true, exsitingIncome: nil)
    }
    
    func didPickNewIncome(income: Income) {
        FinanceManager.shared.allIncomes.append(income)
        checkIfIncomesAreEqualToCurrentPresentedMonth(currentPresentedMonth: date)
        delegate?.updateTotalIncomesLabel()
        delegate?.reloadData()
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
                        FinanceManager.shared.allIncomes.removeAll(where: {$0.eventStoreId == income.eventStoreId})
                        self.checkIfIncomesAreEqualToCurrentPresentedMonth(currentPresentedMonth: self.date)
                        self.delegate?.updateTotalIncomesLabel()
                        self.delegate?.reloadData()
                    case .failure(_):
                        self.delegate?.presentErrorAlert(message: "נוצרה בעיה בפניה לשרת לצורך המחיקה, אנא נסה שנית")
                    }
                }
            }
        }
    }
    
    func didTapEditIncome(at indexPath: IndexPath) {
        let income = currentMonthIncomes[indexPath.row]
        if income.isDeal {
            delegate?.presentIsDealError(title: "לא ניתן לערוך הכנסה מעסקה", message: "יש לבצע עריכה לעסקה ביומן")
        } else {
            delegate?.moveToCreateIncomeVC(isNewIncome: false, exsitingIncome: income)
        }
    }
    
    private func checkIfIncomesAreEqualToCurrentPresentedMonth(currentPresentedMonth: Date) {
        currentMonthIncomes = []
       for income in FinanceManager.shared.allIncomes {
           self.dateFormatter.dateFormat = "MMMM"
           self.dateFormatter.locale = Locale(identifier: "He")
           let currentMonth = self.dateFormatter.string(from: currentPresentedMonth)
           if self.dateFormatter.string(from: income.date) == currentMonth {
               self.currentMonthIncomes.append(income)
           }
       }
    }
}
