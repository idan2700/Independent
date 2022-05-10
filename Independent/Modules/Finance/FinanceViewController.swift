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
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var addIncomeButton: UIButton!
    @IBOutlet weak var addOutcomeButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var noLabel: UILabel!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var viewModel: FinanceViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        outcomeTableView.isHidden = true
        currentMonthLabel.text = viewModel.stringDate
        lastMonthButton.setTitle("", for: .normal)
        nextMonthButton.setTitle("", for: .normal)
        monthPickerView.makeRoundCorners(radius: 10)
        monthView.makeRoundCorners(radius: 10)
        incomeTableView.makeTopRoundCorners(radius: 20)
        incomeTableView.clipsToBounds = true
        outcomeTableView.makeTopRoundCorners(radius: 20)
        borderView.makeRoundCorners(radius: 20)
        borderView.addShadow(color: UIColor(named: "50gold")!, opacity: 1, radius: 1, size: CGSize(width: -1.1, height: -1.1))
        outcomeTableView.clipsToBounds = true
        collectionView.dataSource = self
        collectionView.delegate = self
        incomeTableView.dataSource = self
        outcomeTableView.dataSource = self
        incomeTableView.delegate = self
        outcomeTableView.delegate = self
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(named: "30white")!], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        addButton.makeRound()
        addButton.setTitle("", for: .normal)
        addButton.addShadow(color: UIColor(named: "50gold")!, opacity: 0.2, radius: 5, size: CGSize(width: 0, height: 0))
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
    
    @IBAction func didTapAdd(_ sender: UIButton) {
        viewModel.didTapAdd(index: segmentedControl.selectedSegmentIndex)
    }
    
    @IBAction func didChangeSegmant(_ sender: UISegmentedControl) {
        viewModel.didChangeSegmant()
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
        let width = (view.frame.width - 31) / 3
        let height = width
        collectionViewHeight.constant = height
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
            cell.configure(with: cellViewModel)
            return cell
        case outcomeTableView:
            guard let cell = outcomeTableView.dequeueReusableCell(withIdentifier: "OutcomeCell", for: indexPath) as? OutcomeTableViewCell else {return UITableViewCell()}
            let cellViewModel = viewModel.getOutcomeCellViewModel(at: indexPath)
            cell.configure(with: cellViewModel)
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension FinanceViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch tableView {
        case incomeTableView:
            let delete = createTableViewAction(title: "", image: UIImage(systemName: "trash")!) {
                self.viewModel.didTapDeleteIncome(at: indexPath)
            }
            return UISwipeActionsConfiguration(actions: [delete])
        case outcomeTableView:
            let delete = createTableViewAction(title: "", image: UIImage(systemName: "trash")!) {
                self.viewModel.didTapDeleteOutcome(at: indexPath)
            }
            return UISwipeActionsConfiguration(actions: [delete])
        default:
            return UISwipeActionsConfiguration()
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch tableView {
        case incomeTableView:
            let edit = createTableViewAction(title: "", image: UIImage(systemName: "pencil")!) {
                self.viewModel.didTapEditIncome(at: indexPath)
            }
            return UISwipeActionsConfiguration(actions: [edit])
        case outcomeTableView:
            let edit = createTableViewAction(title: "", image: UIImage(systemName: "pencil")!) {
                self.viewModel.didTapEditOutcome(at: indexPath)
            }
            return UISwipeActionsConfiguration(actions: [edit])
        default:
            return UISwipeActionsConfiguration()
        }
    }
}


extension FinanceViewController: FinanceViewModelDelegate {
    func manageSegmantApperance() {
        if outcomeTableView.isHidden {
            outcomeTableView.isHidden = false
            incomeTableView.isHidden = true
            noLabel.text = "אין הוצאות"
            noLabel.isHidden = !viewModel.presentOutcomeNoLabel()
            addButton.backgroundColor = UIColor(named: "ired")!
        } else {
            outcomeTableView.isHidden = true
            incomeTableView.isHidden = false
            noLabel.text = "אין הכנסות"
            noLabel.isHidden = !viewModel.presentIncomeNoLabel()
            addButton.backgroundColor = UIColor(named: "igreen")!
        }
    }
    
    func moveToCreateOutcomeVC(isNewOutcome: Bool, exsitingOutcome: Outcome?) {
        let outcomeVC: CreateOutcomeViewController = storyBoard.instantiateViewController()
        outcomeVC.modalPresentationStyle = .overFullScreen
        outcomeVC.delegate = self
        outcomeVC.viewModel = CreateOutcomeViewModel(delegate: outcomeVC, isNewOutcome: isNewOutcome)
        outcomeVC.viewModel.exsitingOutcome = exsitingOutcome
        self.present(outcomeVC, animated: true, completion: nil)
    }
    
    func presentIsDealError(message: String) {
        presentErrorAlert(with: message, buttonTitle: "אישור")
    }
    
    func presentErrorAlert(message: String) {
        presentErrorAlert(with: message)
    }
    
    func moveToCreateIncomeVC(isNewIncome: Bool, exsitingIncome: Income?) {
        let incomeVC: CreateIncomeViewController = storyBoard.instantiateViewController()
        incomeVC.modalPresentationStyle = .overFullScreen
        incomeVC.delegate = self
        incomeVC.viewModel = CreateIncomeViewModel(delegate: incomeVC, isNewIncome: isNewIncome)
        incomeVC.viewModel.exsitingIncome = exsitingIncome
        self.present(incomeVC, animated: true, completion: nil)
    }
    
    func updateCurrentMonthLabel() {
        currentMonthLabel.text = viewModel.stringDate
    }
    
    func reloadData() {
        incomeTableView.reloadData()
        outcomeTableView.reloadData()
        collectionView.reloadData()
    }
    
    func deleteOutcomeRow(at indexPath: IndexPath) {
        outcomeTableView.beginUpdates()
        outcomeTableView.deleteRows(at: [indexPath], with: .right)
        outcomeTableView.endUpdates()
    }
    
    func deleteIncomeRow(at indexPath: IndexPath) {
        incomeTableView.beginUpdates()
        incomeTableView.deleteRows(at: [indexPath], with: .right)
        incomeTableView.endUpdates()
    }
}

extension FinanceViewController: CreateIncomeViewControllerDelegate {
    func didPick(newIncome: Income) {
        viewModel.didPickNewIncome(income: newIncome)
    }
}


extension FinanceViewController: CreateOutcomeViewControllerDelegate {
    func didPick(newOutcome: Outcome) {
        viewModel.didPickNewOutcome(outcome: newOutcome)
    }
}


