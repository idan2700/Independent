//
//  CalenderViewController.swift
//  Independent
//
//  Created by Idan Levi on 28/10/2021.
//

import UIKit
import CalendarKit
import EventKit
import EventKitUI

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var expandDatePickerButton: UIButton!
    @IBOutlet weak var datePickerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var presentedDayLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let store = EKEventStore()
    var viewModel: CalendarViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.overrideUserInterfaceStyle = .dark
        datePicker.setValue(0.8, forKey: "alpha")
        datePicker.minimumDate = Date()
        datePickerViewHeight.constant = 25
        expandDatePickerButton.setTitle("", for: .normal)
        expandDatePickerButton.makeRoundCorners(radius: 5)
        presentedDayLabel.makeRoundCorners(radius: 7)
        viewModel.updateCurrentPresentedDate(date: datePicker.date)
        datePicker.addTarget(self, action: #selector(handleDatePicker), for: .valueChanged)
        tableView.dataSource = self
    }
    
    @IBAction func didTapExpandDatePicker(_ sender: UIButton) {
        viewModel.didTapExpandDatePicker()
    }
    
    @objc func handleDatePicker() {
        viewModel.updateCurrentPresentedDate(date: datePicker.date)
    }
    
    @IBAction func didTapAddEvent(_ sender: UIButton) {
    }
   
}

extension CalendarViewController: CalendarViewModelDelegate {
 
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

extension CalendarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as? EventTableViewCell else {return UITableViewCell()}
        let cellViewModel = viewModel.getCellViewModel(at: indexPath)
        cell.configure(with: cellViewModel)
        return cell
    }
    
    
}

