//
//  CreateMissionViewController.swift
//  Independent
//
//  Created by Idan Levi on 22/11/2021.
//

import UIKit

protocol CreateMissionViewControllerDelegate: AnyObject {
    func didPick(mission: Mission, isNewMission: Bool)
}

class CreateMissionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: CreateMissionViewControllerDelegate?
    var viewModel: CreateMissionViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }
}

extension CreateMissionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CreateMissionCell", for: indexPath) as? CreateMissionTableViewCell else {return UITableViewCell()}
        let cellViewModel = viewModel.getCellViewModel(cell: cell)
        cell.viewModel = cellViewModel
        cellViewModel.existingMission = viewModel.exisitingMission
        cell.configure()
        cell.delegate = self
        return cell
    }
}

extension CreateMissionViewController: CreateMissionTableViewCellDelegate {
    func didTapReminder(cell: CreateMissionTableViewCell) {
        let reminderVC: ReminderViewController = storyBoard.instantiateViewController()
        reminderVC.viewModel = ReminderViewModel()
        reminderVC.delegate = cell
        reminderVC.modalPresentationStyle = .overFullScreen
        self.present(reminderVC, animated: true, completion: nil)
    }
    
    func didPickNewMission(newMission: Mission) {
        viewModel.didPickNewMission(newMission: newMission)
    }
    
    func presentErrorAlert(message: String) {
        presentErrorAlert(with: message)
    }

    func updateCellHeight() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    func didTapCancel() {
        self.dismiss(animated: true)
    }
}

extension CreateMissionViewController: CreateMissionViewModelDelegate {
    func sendMissionToCalendar(mission: Mission, isNewMission: Bool) {
        delegate?.didPick(mission: mission, isNewMission: isNewMission)
        self.dismiss(animated: true)
    }
}
