//
//  FinanceViewController.swift
//  Independent
//
//  Created by Idan Levi on 28/10/2021.
//

import UIKit

class FinanceViewController: UIViewController {

    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var monthPickerView: UIView!
    @IBOutlet weak var currentMonthLabel: UILabel!
    @IBOutlet weak var lastMonthButton: UIButton!
    @IBOutlet weak var nextMonthButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var incomeTableView: UITableView!
    @IBOutlet weak var outcomeTableView: UITableView!
    @IBOutlet weak var addIncomeButton: UIButton!
    @IBOutlet weak var addOutcomeButton: UIButton!
    @IBOutlet weak var incomeView: UIView!
    @IBOutlet weak var outcomeView: UIView!
    @IBOutlet weak var imcomeSumLabel: UILabel!
    @IBOutlet weak var outcomeSumLabel: UILabel!
    
    var viewModel: FinanceViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentMonthLabel.text = viewModel.stringDate
        lastMonthButton.setTitle("", for: .normal)
        nextMonthButton.setTitle("", for: .normal)
        monthPickerView.makeRoundCorners(radius: 10)
        monthView.makeRoundCorners(radius: 10)
        addIncomeButton.setTitle("", for: .normal)
        addOutcomeButton.setTitle("", for: .normal)
        incomeView.makeRoundCorners(radius: 5)
        outcomeView.makeRoundCorners(radius: 5)
        addIncomeButton.makeRoundCorners(radius: 5)
        addOutcomeButton.makeRoundCorners(radius: 5)
        collectionView.dataSource = self
        collectionView.delegate = self
        incomeTableView.dataSource = self
        imcomeSumLabel.text = viewModel.totalIncomes
        viewModel.start()
    }
    
    @IBAction func didTapLastMonth(_ sender: UIButton) {
        viewModel.didTapLastMonth()
    }
    @IBAction func didTapNextMonth(_ sender: UIButton) {
        viewModel.didTapNextMonth(currentPresentedMonth: currentMonthLabel.text ?? "")
    }
    
    @IBAction func didTapAddIncome(_ sender: UIButton) {
        viewModel.didTapAddIncome()
    }
    
    @IBAction func didTapAddOutcome(_ sender: UIButton) {
    }
}

extension FinanceViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: "FinanceItem", for: indexPath) as? FinanceCollectionViewCell else {return UICollectionViewCell()}
        let itemViewModel = viewModel.getItemViewModel(at: indexPath)
        item.configure(with: itemViewModel)
        return item
    }
}

extension FinanceViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 51) / 3
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension FinanceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfIncomeRaws
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = incomeTableView.dequeueReusableCell(withIdentifier: "IncomeCell", for: indexPath) as? IncomeTableViewCell else {return UITableViewCell()}
        let cellViewModel = viewModel.getIncomeCellViewModel(at: indexPath)
        cell.configure(with: cellViewModel)
        return cell
    }
}

extension FinanceViewController: FinanceViewModelDelegate {
    func moveToCreateIncomeVC(with incomes: [Income]) {
        let incomeVC: CreateIncomeViewController = storyBoard.instantiateViewController()
        incomeVC.delegate = self
        incomeVC.viewModel = CreateIncomeViewModel(incomes: incomes, financeManager: FinanceManager(), delegate: incomeVC)
        self.present(incomeVC, animated: true, completion: nil)
    }
    
    func updateTotalIncomesLabel() {
        imcomeSumLabel.text = viewModel.totalIncomes
    }
    
    func updateCurrentMonthLabel() {
        currentMonthLabel.text = viewModel.stringDate
    }
    
    func reloadData() {
        incomeTableView.reloadData()
        outcomeTableView.reloadData()
        collectionView.reloadData()
    }
}

extension FinanceViewController: CreateIncomeViewControllerDelegate {
    func didPick(newIncome: Income) {
        viewModel.didPickNewIncome(income: newIncome)
    }
}

