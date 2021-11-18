//
//  CreateEventViewController.swift
//  Independent
//
//  Created by Idan Levi on 16/11/2021.
//

import UIKit

protocol CreateDealViewControllerDelegate: AnyObject {
    func didPick(newDeal: Deal)
}

class CreateDealViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: CreateDealViewControllerDelegate?
    var viewModel: CreateDealViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }
}

extension CreateDealViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CreateDealCell", for: indexPath) as? CreateDealTableViewCell else {return UITableViewCell()}
        let cellViewModel = viewModel.getCellViewModel(cell: cell)
        cell.viewModel = cellViewModel
        cell.configure()
        cell.delegate = self
        return cell
    }
}

extension CreateDealViewController: CreateDealTableViewCellDelegate {
    func didPickNewDeal(newDeal: Deal) {
        viewModel.didPickNewDeal(newDeal: newDeal)
    }
    
    func updateCellHeight() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    func didTapCancel() {
        self.dismiss(animated: true)
    }
}

extension CreateDealViewController: CreateDealViewModelDelegate {
    func sendDealToCalendar(deal: Deal) {
        delegate?.didPick(newDeal: deal)
        self.dismiss(animated: true)
    }
}
