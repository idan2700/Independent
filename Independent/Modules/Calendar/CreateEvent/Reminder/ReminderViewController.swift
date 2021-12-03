//
//  ReminderViewController.swift
//  Independent
//
//  Created by Idan Levi on 03/12/2021.
//

import UIKit

protocol ReminderViewControllerDelegate: AnyObject {
    func didPick(timeOfReminder: Int?, reminderTitle: String)
}

class ReminderViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var viewModel: ReminderViewModel!
    weak var delegate: ReminderViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.makeRoundCorners(radius: 5)
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension ReminderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRaws
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as? ReminderTableViewCell else {return UITableViewCell()}
        let cellViewModel = viewModel.getCellViewModel(at: indexPath)
        cell.configure(with: cellViewModel)
        return cell
    }
}

extension ReminderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//       guard let cell = tableView.cellForRow(at: indexPath) as? ReminderTableViewCell else {return}
        let cellViewModel = viewModel.getCellViewModel(at: indexPath)
        delegate?.didPick(timeOfReminder: cellViewModel.reminderTime, reminderTitle: cellViewModel.reminderTitle)
        self.dismiss(animated: true, completion: nil)
    }
}
