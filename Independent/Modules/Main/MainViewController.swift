//
//  MainViewController.swift
//  Independent
//
//  Created by Idan Levi on 25/10/2021.
//

import UIKit


class MainViewController: UIViewController {

    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var viewModel: MainViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userLabel.text = viewModel.userName
        currentDateLabel.text = viewModel.currentDate
        tableView.dataSource = self
        tableView.delegate = self
        viewModel.start()
    }
}

extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRaws(at: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.getItemForCell(at: indexPath)
        switch item {
        case .finance(let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "financeCell") as? FinanceTableViewCell else {return UITableViewCell()}
            cell.viewModel = FinanceTableViewCellViewModel()
            return cell
        case .goals(let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "goalsCell") as? GoalsTableViewCell else {return UITableViewCell()}
            return cell
        case .fu(viewModel: let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "fuSectionCell") as? FuSectionTableViewCell else {return UITableViewCell()}
            viewModel.delegate = self
            cell.configure(with: viewModel)
            return cell
        }
    }
}

extension MainViewController: FuSectionTableViewCellViewModelDelegate {
    func presentErrAlert(message: String) {
        self.presentErrorAlert(with: message)
    }
    
    func moveToFuDateVC(lead: Lead) {
        let fuDateVC: FuDateViewController = storyBoard.instantiateViewController()
        fuDateVC.delegate = self
        fuDateVC.viewModel = FuDateViewModel(delegate: fuDateVC, lead: lead)
        fuDateVC.modalPresentationStyle = .overFullScreen
        self.present(fuDateVC, animated: true, completion: nil)
    }
}

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//    }
}

extension MainViewController: MainViewModelDelegate {
    func reloadData() {
        tableView.reloadData()
    }
    
    func presentAlert(message: String) {
        self.presentErrorAlert(with: message)
    }
}

extension MainViewController: FuDateViewControllerDelegate {
    func didPick(updatedLead: Lead) {
        viewModel.didPickUpdatedLead(lead: updatedLead)
    }
}


