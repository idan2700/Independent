//
//  CalenderViewController.swift
//  Independent
//
//  Created by Idan Levi on 28/10/2021.
//

import UIKit
import CalendarKit

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var expandDatePickerButton: UIButton!
    @IBOutlet weak var datePickerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var presentedDayLabel: UILabel!
    @IBOutlet weak var addEventButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var createButtonsWidth: NSLayoutConstraint!
    @IBOutlet weak var presentedDayWidth: NSLayoutConstraint!
    var viewModel: CalendarViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.start()
        createButtonsWidth.constant = 0
        presentedDayWidth.constant = self.view.frame.width - 44
        dealButton.alpha = 0
        eventButton.alpha = 0
        eventButton.layer.borderWidth = 2
        eventButton.layer.borderColor = UIColor(named: "gold")!.cgColor
        dealButton.makeRoundCorners(radius: 10)
        eventButton.makeRoundCorners(radius: 10)
        datePicker.overrideUserInterfaceStyle = .dark
        datePicker.setValue(0.8, forKey: "alpha")
        datePicker.minimumDate = Date()
        datePickerViewHeight.constant = 25
        expandDatePickerButton.setTitle("", for: .normal)
        expandDatePickerButton.makeRoundCorners(radius: 5)
        presentedDayLabel.makeRoundCorners(radius: 7)
        addEventButton.setTitle("", for: .normal)
        addEventButton.makeRoundCorners(radius: 7)
        datePicker.addTarget(self, action: #selector(didSelectDate), for: .valueChanged)
        tableView.dataSource = self
        tableView.delegate = self
        viewModel.handleDatePresentation(with: datePicker.date)
    }
    
    @IBAction func didTapExpandDatePicker(_ sender: UIButton) {
        viewModel.didTapExpandDatePicker()
    }
    
    @objc func didSelectDate() {
        viewModel.handleDatePresentation(with: datePicker.date)
    }
    
    @IBAction func didTapAdd(_ sender: UIButton) {
        viewModel.didTapAdd()
    }
    
    @IBAction func didTapAddMission(_ sender: UIButton) {
        
    }
    @IBAction func didTapAddDeal(_ sender: UIButton) {
        viewModel.didTapAddDeal()
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
        case .mission:
            return UITableViewCell()
        }
    }
}

extension CalendarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension CalendarViewController: CalendarViewModelDelegate {
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
                self.eventButton.alpha = 1
                self.dealButton.makeBorder(width: 1, color: UIColor(named: "gold")!.cgColor)
                self.eventButton.makeBorder(width: 1, color: UIColor(named: "gold")!.cgColor)
            }
        } else {
            createButtonsWidth.constant = 0
            presentedDayWidth.constant = self.view.frame.width - 44
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
                self.dealButton.alpha = 0
                self.eventButton.alpha = 0
            }
        }
    }
    
    func moveToCreateDealVC(with currentEventID: Int) {
        let createDealVC: CreateDealViewController = storyBoard.instantiateViewController()
        createDealVC.delegate = self
        createDealVC.viewModel = CreateDealViewModel(delegate: createDealVC, currentEventID: currentEventID)
        createDealVC.modalPresentationStyle = .overFullScreen
        self.present(createDealVC, animated: true, completion: nil)
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
                buttonImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }
        } else {
            datePickerViewHeight.constant = 25
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
                buttonImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 180)
            }
        }
    }
}

extension CalendarViewController: CreateDealViewControllerDelegate {
    func didPick(newDeal: Deal) {
        viewModel.didPickNewDeal(newDeal: newDeal)
    }
}

extension CalendarViewController: DealTableViewCellDelegate {
    func updateCellHeight() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

