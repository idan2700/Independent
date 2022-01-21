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
        outcomeTableView.dataSource = self
        imcomeSumLabel.text = viewModel.totalIncomes
//        viewModel.start()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        viewModel.didTapAddOutcome()
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
        switch tableView {
        case incomeTableView:
            return viewModel.numberOfIncomeRaws
        case outcomeTableView:
            return viewModel.numberOfOutcomeRaws
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case incomeTableView:
            guard let cell = incomeTableView.dequeueReusableCell(withIdentifier: "IncomeCell", for: indexPath) as? IncomeTableViewCell else {return UITableViewCell()}
            let cellViewModel = viewModel.getIncomeCellViewModel(at: indexPath)
            cell.delegate = self
            cell.configure(with: cellViewModel)
            return cell
        case outcomeTableView:
            guard let cell = outcomeTableView.dequeueReusableCell(withIdentifier: "OutcomeCell", for: indexPath) as? OutcomeTableViewCell else {return UITableViewCell()}
            let cellViewModel = viewModel.getOutcomeCellViewModel(at: indexPath)
            cell.delegate = self
            cell.configure(with: cellViewModel)
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension FinanceViewController: FinanceViewModelDelegate {
    func moveToCreateOutcomeVC(isNewOutcome: Bool, exsitingOutcome: Outcome?) {
        let outcomeVC: CreateOutcomeViewController = storyBoard.instantiateViewController()
        outcomeVC.delegate = self
        outcomeVC.viewModel = CreateOutcomeViewModel(delegate: outcomeVC, isNewOutcome: isNewOutcome)
        outcomeVC.viewModel.exsitingOutcome = exsitingOutcome
        self.present(outcomeVC, animated: true, completion: nil)
    }
    
    func presentIsDealError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentErrorAlert(message: String) {
        presentErrorAlert(with: message)
    }
    
    func moveToCreateIncomeVC(isNewIncome: Bool, exsitingIncome: Income?) {
        let incomeVC: CreateIncomeViewController = storyBoard.instantiateViewController()
        incomeVC.delegate = self
        incomeVC.viewModel = CreateIncomeViewModel(delegate: incomeVC, isNewIncome: isNewIncome)
        incomeVC.viewModel.exsitingIncome = exsitingIncome
        self.present(incomeVC, animated: true, completion: nil)
    }
    
    func updateTotalIncomesLabel() {
        imcomeSumLabel.text = viewModel.totalIncomes
    }
    
    func updateTotalOutcomesLabel() {
        outcomeSumLabel.text = viewModel.totalOutcomes
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

extension FinanceViewController: IncomeTableViewCellDelegate {
    func didTapDelete(cell: IncomeTableViewCell) {
        guard let indexPath = incomeTableView.indexPath(for: cell) else {return}
        viewModel.didTapDeleteIncome(at: indexPath)
    }
    
    func didTapEdit(cell: IncomeTableViewCell) {
        guard let indexPath = incomeTableView.indexPath(for: cell) else {return}
        viewModel.didTapEditIncome(at: indexPath)
    }
}

extension FinanceViewController: CreateOutcomeViewControllerDelegate {
    func didPick(newOutcome: Outcome) {
        viewModel.didPickNewOutcome(outcome: newOutcome)
    }
}

extension FinanceViewController: OutcomeTableViewCellDelegate {
    func didTapDelete(cell: OutcomeTableViewCell) {
        guard let indexPath = outcomeTableView.indexPath(for: cell) else {return}
        viewModel.didTapDeleteOutcome(at: indexPath)
    }
    
    func didTapEdit(cell: OutcomeTableViewCell) {
        guard let indexPath = outcomeTableView.indexPath(for: cell) else {return}
        viewModel.didTapEditOutcome(at: indexPath)
    }
}

