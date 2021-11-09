//
//  LeadViewController.swift
//  Independent
//
//  Created by Idan Levi on 28/10/2021.
//

import UIKit

class LeadViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var monthPickerView: UIView!
    @IBOutlet weak var nextMonthButton: UIButton!
    @IBOutlet weak var lastMonthButton: UIButton!
    @IBOutlet weak var currentMonthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newLeadButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addFromContactsButton: UIButton!
    @IBOutlet weak var addManualyButton: UIButton!
    @IBOutlet weak var newLeadButtonX: NSLayoutConstraint!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var leadsLoader: UIActivityIndicatorView!
    @IBOutlet weak var noLeadsLabel: UILabel!
    
    var viewModel: LeadViewModel!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.start()
        collectionView.dataSource = self
        collectionView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        buttonView.makeRoundCorners(radius: 10)
        currentMonthLabel.text = viewModel.stringDate
        lastMonthButton.setTitle("", for: .normal)
        nextMonthButton.setTitle("", for: .normal)
        addFromContactsButton.makeBorder(width: 2, color: UIColor(named: "gold")!.cgColor)
        addManualyButton.makeBorder(width: 2, color: UIColor(named: "gold")!.cgColor)
        newLeadButton.makeRoundCorners(radius: 10)
        monthPickerView.makeRoundCorners(radius: 10)
        monthView.makeRoundCorners(radius: 10)
        tableView.makeTopRoundCorners()
        addManualyButton.layer.cornerRadius = 10
        addFromContactsButton.layer.cornerRadius = 10
    }
    
    @IBAction func didTapNextMonth(_ sender: UIButton) {
        viewModel.didTapNextMonth(currentPresentedMonth: currentMonthLabel.text ?? "")
    }
    
    @IBAction func didTapLastMonth(_ sender: UIButton) {
        viewModel.didTapLastMonth()
    }
    
    @IBAction func didTapCreateNewLead(_ sender: UIButton) {
        viewModel.didTapCreateNewLead()
    }
                       
    
    @IBAction func didTapAddManualy(_ sender: UIButton) {
        viewModel.didTapAddManualy()
    }
}

extension LeadViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: "LeadItem", for: indexPath) as? LeadCollectionViewCell else {return UICollectionViewCell()}
        let itemViewModel = viewModel.getItemViewModel(at: indexPath)
        item.configure(with: itemViewModel)
        return item
    }
}

extension LeadViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 51) / 3
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension LeadViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LeadCell", for: indexPath) as? LeadTableViewCell else {return UITableViewCell()}
        let cellViewModel = viewModel.getCellViewModel(at: indexPath)
        cell.delegate = self
        cell.configure(with: cellViewModel)
        return cell
    }
}

extension LeadViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension LeadViewController: LeadViewModelDelegate {
    func setNextMonthButtonState(isHidden: Bool) {
        nextMonthButton.isHidden = isHidden
    }
    
    func removeCell(at indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .right)
        tableView.endUpdates()
    }
    
    func setNoLeadsLabelState(isHidden: Bool) {
        noLeadsLabel.isHidden = isHidden
    }
    
    func setLeadLoaderState(isHidden: Bool) {
        leadsLoader.isHidden = isHidden
        if isHidden {
            tableView.isHidden = false
        } else {
            tableView.isHidden = true
        }
    }
    
    func presentAlert(message: String) {
        
    }
    
    func reloadData() {
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func updateCurrentMonthLabel() {
        currentMonthLabel.text = viewModel.stringDate
    }
    
    func moveToCreateLeadVC() {
        if let createLeadVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateLeadViewController") as? CreateLeadViewController {
            createLeadVC.modalPresentationStyle = .overFullScreen
            createLeadVC.delegate = self
            createLeadVC.viewModel = CreateLeadViewModel(delegate: createLeadVC, leads: viewModel.leads)
        self.present(createLeadVC, animated: true, completion: nil)
        }
    }
    
    func animateNewLeadButton(toOpen: Bool) {
        if toOpen {
            newLeadButtonX.constant = addManualyButton.frame.maxX + 10
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        } else {
            newLeadButtonX.constant = 20
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension LeadViewController: LeadTableViewCellDelegate {
    func didTapCall(cell: LeadTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        viewModel.didTapCall(at: indexPath)
    }
    
    func didTapWhatsapp(cell: LeadTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        viewModel.didTapSendWhatsapp(at: indexPath)
    }
    
    func didTapDelete(cell: LeadTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        viewModel.didTapDelete(at: indexPath)
    }
    
    func didTapInfo(cell: LeadTableViewCell, isInfoButtonOpen: Bool) {
        self.tableView.beginUpdates()
        cell.configureCellExpend(toExpand: isInfoButtonOpen ? false : true)
        self.tableView.endUpdates()
    }
}

extension LeadViewController: CreateLeadViewControllerDelegate {
    func didPick(newLead: Lead) {
        viewModel.didPickNewLead(lead: newLead)
    }
}
