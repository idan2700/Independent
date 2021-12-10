//
//  FinanceViewModel.swift
//  Independent
//
//  Created by Idan Levi on 10/12/2021.
//

import Foundation

protocol FinanceViewModelDelegate: AnyObject {
    func reloadData()
    func updateCurrentMonthLabel()
    func updateTotalIncomesLabel()
    func moveToCreateIncomeVC(with incomes: [Income])
}

class FinanceViewModel {
    
    private let dateFormatter = DateFormatter()
    private var date = Date()
    private var allIncomes = [Income]()
    private var currentMonthIncomes = [Income]()
    weak var delegate: FinanceViewModelDelegate?
    
    init(delegate: FinanceViewModelDelegate?, allIncomes: [Income]) {
        self.delegate = delegate
        self.allIncomes = allIncomes
    }
    
    func start() {
        checkIfIncomesAreEqualToCurrentPresentedMonth(currentPresentedMonth: date)
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
        delegate?.reloadData()
    }
    
    func didTapLastMonth() {
        currentMonthIncomes = []
        date = Calendar.current.date(byAdding: .month, value: -1, to: date) ?? Date()
        checkIfIncomesAreEqualToCurrentPresentedMonth(currentPresentedMonth: date)
        delegate?.updateCurrentMonthLabel()
        delegate?.reloadData()
    }
    
    func didTapAddIncome() {
        delegate?.moveToCreateIncomeVC(with: allIncomes)
    }
    
    func didPickNewIncome(income: Income) {
        self.allIncomes.append(income)
        checkIfIncomesAreEqualToCurrentPresentedMonth(currentPresentedMonth: date)
        delegate?.reloadData()
    }
    
    private func checkIfIncomesAreEqualToCurrentPresentedMonth(currentPresentedMonth: Date) {
        currentMonthIncomes = []
       for income in allIncomes {
           self.dateFormatter.dateFormat = "MMMM"
           self.dateFormatter.locale = Locale(identifier: "He")
           let currentMonth = self.dateFormatter.string(from: currentPresentedMonth)
           if self.dateFormatter.string(from: income.date) == currentMonth {
               self.currentMonthIncomes.append(income)
           }
       }
        delegate?.updateTotalIncomesLabel()
    }
}
