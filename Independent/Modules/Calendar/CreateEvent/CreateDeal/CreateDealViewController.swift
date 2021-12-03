//
//  CreateEventViewController.swift
//  Independent
//
//  Created by Idan Levi on 16/11/2021.
//

import UIKit

protocol CreateDealViewControllerDelegate: AnyObject {
    func didPick(deal: Deal, isNewDeal: Bool)
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
        cell.viewModel.exisitingDeal = viewModel.existingDeal
        cell.configure(name: viewModel.name, phone: viewModel.phone)
        cell.delegate = self
        return cell
    }
}

extension CreateDealViewController: CreateDealTableViewCellDelegate {
    func didTapReminder(cell: CreateDealTableViewCell) {
        let reminderVC: ReminderViewController = storyBoard.instantiateViewController()
        reminderVC.viewModel = ReminderViewModel()
        reminderVC.delegate = cell
        reminderVC.modalPresentationStyle = .overFullScreen
        self.present(reminderVC, animated: true, completion: nil)
    }
    
    func presentErrorAlert(message: String) {
        presentErrorAlert(with: message)
    }
    
    func presentAlertThatLeadIsExist() {
        let alert = UIAlertController(title: "שים לב", message: "הלקוח קיים במסך הלידים, להבא יהיה נוח יותר לפתוח עסקה ממסך הלידים. ניתן להמשיך כרגיל", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "המשך", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
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
    func sendDealToCalendar(deal: Deal, isNewDeal: Bool) {
        delegate?.didPick(deal: deal, isNewDeal: isNewDeal)
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "newDealAddedFromLeads"), object: nil)
        }
    }
}
