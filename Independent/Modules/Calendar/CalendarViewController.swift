//
//  CalenderViewController.swift
//  Independent
//
//  Created by Idan Levi on 28/10/2021.
//

import UIKit
import CalendarKit

class CalendarViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var expandDatePickerButton: UIButton!
    @IBOutlet weak var datePickerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var presentedDayLabel: UILabel!
    @IBOutlet weak var addEventButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var missionButton: UIButton!
    @IBOutlet weak var createButtonsWidth: NSLayoutConstraint!
    @IBOutlet weak var noEventsLabel: UILabel!
    @IBOutlet weak var presentedDayWidth: NSLayoutConstraint!
    @IBOutlet weak var lastDayButton: UIButton!
    @IBOutlet weak var nextDayButton: UIButton!
    @IBOutlet weak var presentedDayView: UIView!
    var viewModel: CalendarViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        viewModel.start()
        lastDayButton.isHidden = true
        createButtonsWidth.constant = 0
        presentedDayWidth.constant = self.view.frame.width - 44
        dealButton.alpha = 0
        missionButton.alpha = 0
        missionButton.layer.borderWidth = 2
        missionButton.layer.borderColor = UIColor(named: "gold")!.cgColor
        dealButton.makeRoundCorners(radius: 10)
        missionButton.makeRoundCorners(radius: 10)
        datePicker.overrideUserInterfaceStyle = .dark
        datePicker.setValue(0.8, forKey: "alpha")
        datePicker.minimumDate = Date()
        datePickerViewHeight.constant = 25
        datePicker.alpha = 0
        expandDatePickerButton.setTitle("", for: .normal)
        expandDatePickerButton.makeRoundCorners(radius: 5)
        presentedDayView.makeRoundCorners(radius: 7)
        addEventButton.setTitle("", for: .normal)
        lastDayButton.setTitle("", for: .normal)
        nextDayButton.setTitle("", for: .normal)
        addEventButton.makeRoundCorners(radius: 7)
        datePicker.addTarget(self, action: #selector(didSelectDate), for: .valueChanged)
        tableView.dataSource = self
        tableView.delegate = self
        let swipeLeftRegongnizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeLeft))
        swipeLeftRegongnizer.direction = .left
        swipeLeftRegongnizer.delegate = self
        tableView.addGestureRecognizer(swipeLeftRegongnizer)
        let swipeRightRegongnizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeRight))
        swipeRightRegongnizer.direction = .right
        swipeRightRegongnizer.delegate = self
        tableView.addGestureRecognizer(swipeRightRegongnizer)
        viewModel.handleDatePresentation(with: datePicker.date)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.start()
    }
    
    @IBAction func didTapExpandDatePicker(_ sender: UIButton) {
        viewModel.didTapExpandDatePicker()
    }
    
    @objc func didSelectDate() {
        viewModel.didSelectDate(date: datePicker.date)
    }
    
    @IBAction func didTapAdd(_ sender: UIButton) {
        viewModel.didTapAdd()
    }
    
    @IBAction func didTapAddMission(_ sender: UIButton) {
        viewModel.didTapAddMission()
    }
    
    @IBAction func didTapAddDeal(_ sender: UIButton) {
        viewModel.didTapAddDeal()
    }
    
    @objc func handleSwipeLeft() {
        viewModel.didSwipeLeft()
    }
    
    @objc func handleSwipeRight() {
        viewModel.didSwipeRight()
    }
    
    @IBAction func didTapLastDay(_ sender: UIButton) {
        viewModel.didSwipeLeft()
    }
    
    @IBAction func didTapNextDay(_ sender: UIButton) {
        viewModel.didSwipeRight()
    }
}

extension CalendarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = viewModel.getEvent(at: indexPath)
        switch event {
        case .deal(let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DealCell", for: indexPath) as? DealTableViewCell else {return UITableViewCell()}
            cell.viewModel = viewModel
            cell.configure()
            viewModel.delegate = cell
            cell.delegate = self
            return cell
        case .mission(let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MissionCell", for: indexPath) as? MissionTableViewCell else {return UITableViewCell()}
            cell.viewModel = viewModel
            cell.configure()
            viewModel.delegate = cell
            cell.delegate = self
            return cell
        }
    }
}

extension CalendarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension CalendarViewController: CalendarViewModelDelegate {
    func changeLastDayButtonVisability(isHidden: Bool) {
        lastDayButton.isHidden = isHidden
    }
    
    func moveToCreateMissionVC(currentDate: Date, isNewMission: Bool, existingMission: Event?) {
        let createMissionVC: CreateMissionViewController = storyBoard.instantiateViewController()
        createMissionVC.delegate = self
        createMissionVC.viewModel = CreateMissionViewModel(delegate: createMissionVC, isNewMission: isNewMission)
        createMissionVC.viewModel.exisitingMission = existingMission
        createMissionVC.viewModel.currentDate = currentDate
        createMissionVC.modalPresentationStyle = .overFullScreen
        self.present(createMissionVC, animated: true, completion: nil)
    }
    
    func moveToCreateDealVC(currentDate: Date, isNewDeal: Bool, existingDeal: Event?) {
        let createDealVC: CreateDealViewController = storyBoard.instantiateViewController()
        createDealVC.delegate = self
        createDealVC.viewModel = CreateDealViewModel(delegate: createDealVC, isLaunchedFromLead: false, isNewDeal: isNewDeal)
        createDealVC.viewModel.existingDeal = existingDeal
        createDealVC.viewModel.currentDate = currentDate
        createDealVC.viewModel.isLaunchedFromLead = false
        createDealVC.modalPresentationStyle = .overFullScreen
        self.present(createDealVC, animated: true, completion: nil)
    }
    
    func removeCell(at indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .right)
        tableView.endUpdates()
    }
    
    func setNoEventsLabelState(isHidden: Bool) {
        self.noEventsLabel.isHidden = isHidden
    }
    
    func presentErrorAlert(message: String) {
        self.presentErrorAlert(with: message)
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func changeCreateButtonsVisability(toPresent: Bool) {
        if toPresent {
            createButtonsWidth.constant = 150
            presentedDayWidth.constant = self.view.frame.width - 44 - 150 - 5
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
                self.dealButton.alpha = 1
                self.missionButton.alpha = 1
                self.dealButton.makeBorder(width: 1, color: UIColor(named: "gold")!.cgColor)
                self.missionButton.makeBorder(width: 1, color: UIColor(named: "gold")!.cgColor)
            }
        } else {
            createButtonsWidth.constant = 0
            presentedDayWidth.constant = self.view.frame.width - 44
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
                self.dealButton.alpha = 0
                self.missionButton.alpha = 0
            }
        }
    }
    
    func updatePresentedDayLabel(with date: String) {
        self.presentedDayLabel.text = date
    }
    
    func changeDatePickerVisability(toPresent: Bool) {
        guard let buttonImage = self.expandDatePickerButton.imageView else {return}
        if toPresent {
            datePickerViewHeight.constant = 360
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
                self.datePicker.alpha = 1
                buttonImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }
        } else {
            datePickerViewHeight.constant = 25
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
                self.datePicker.alpha = 0
                buttonImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 180)
            }
        }
    }
}

extension CalendarViewController: CreateDealViewControllerDelegate {
    func didPick(deal: Deal, isNewDeal: Bool) {
        if isNewDeal {
            viewModel.didPickNewDeal(newDeal: deal)
        } else {
            viewModel.didPickEditedDeal(deal: deal)
        }
    }
}

extension CalendarViewController: DealTableViewCellDelegate {
    func didTapEdit(cell: DealTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        viewModel.didTapEditDeal(at: indexPath)
    }
    
    func didTapSendWhatsapp(cell: DealTableViewCell, phone: String) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        viewModel.didTapSendWhatsapp(at: indexPath, phone: phone)
    }
    
    func didTapCall(cell: DealTableViewCell, phone: String) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        viewModel.didTapCall(at: indexPath, phone: phone)
    }
    
    func didTapCancelDeal(cell: DealTableViewCell, phone: String) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        viewModel.didTapCancelDeal(at: indexPath, phone: phone)
    }
    
    func updateCellHeight() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

extension CalendarViewController: CreateMissionViewControllerDelegate {
    func didPick(mission: Mission, isNewMission: Bool) {
        if isNewMission {
            viewModel.didPickNewMission(newMission: mission)
        } else {
            viewModel.didPickEditedMission(mission: mission)
        }
    }
}

extension CalendarViewController: MissionTableViewCellDelegate {
    func didTapEdit(cell: MissionTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        viewModel.didTapEditMission(at: indexPath)
    }
    
    func didTapDelete(cell: MissionTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        viewModel.didTapDelete(at: indexPath)
    }
    
    func updateCell() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

