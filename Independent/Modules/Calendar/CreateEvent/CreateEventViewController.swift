//
//  CdealViewController.swift
//  Independent
//
//  Created by Idan Levi on 01/05/2022.
//

import UIKit

protocol CreateEventViewControllerDelegate: AnyObject {
    func didPick(deal: Deal, isNewDeal: Bool)
    func didPick(mission: Mission, isNewMission: Bool)
}

class CreateEventViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var reminderView: UIView!
    @IBOutlet weak var startTimeButton: UIButton!
    @IBOutlet weak var startDateButton: UIButton!
    @IBOutlet weak var endTimeButton: UIButton!
    @IBOutlet weak var endDateButton: UIButton!
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var startDatePickerHeight: NSLayoutConstraint!
    @IBOutlet weak var endDatePickerHeight: NSLayoutConstraint!
    @IBOutlet weak var startDateSeprator: UIView!
    @IBOutlet weak var endDateSeprator: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet var dealViews: [UIView]!
    
    var viewModel: CreateEventViewModel!
    weak var delegate: CreateEventViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailsView.makeRoundCorners(radius: 5)
        locationView.makeRoundCorners(radius: 5)
        dateView.makeRoundCorners(radius: 5)
        reminderView.makeRoundCorners(radius: 5)
        startTimeButton.makeRoundCorners(radius: 5)
        startDateButton.makeRoundCorners(radius: 5)
        endDateButton.makeRoundCorners(radius: 5)
        endTimeButton.makeRoundCorners(radius: 5)
        reminderButton.makeRoundCorners(radius: 5)
        notesTextView.makeRoundCorners(radius: 5)
        startDatePicker.addTarget(self, action: #selector(didSelectStartDate), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(didSelectEndDate), for: .valueChanged)
        startDateButton.makeRoundCorners(radius: 5)
        endDateButton.makeRoundCorners(radius: 5)
        startTimeButton.makeRoundCorners(radius: 5)
        endTimeButton.makeRoundCorners(radius: 5)
        startDateButton.setTitle(viewModel.startDate, for: .normal)
        endDateButton.setTitle(viewModel.endDate, for: .normal)
        startTimeButton.setTitle(viewModel.startTime, for: .normal)
        endTimeButton.setTitle(viewModel.endTime, for: .normal)
        startDatePicker.overrideUserInterfaceStyle = .dark
        endDatePicker.overrideUserInterfaceStyle = .dark
        startDatePicker.minimumDate = Date()
        endDatePicker.minimumDate = Date()
        startDatePicker.date = Calendar.current.date(byAdding: .minute , value: 15, to: Date()) ?? Date()
        viewModel.didSelectStartDate(date: startDatePicker.date)
        endDatePicker.date = Calendar.current.date(byAdding: .hour, value: 1, to: startDatePicker.date) ?? Date()
        setTextFields()
        viewModel.checkForExisitingEvent()
        viewModel.start()
    }
    
    @IBAction func didTapStartTime(_ sender: UIButton) {
        viewModel.didTapStart(fromDate: false)
    }
    @IBAction func didTapStartDate(_ sender: UIButton) {
        viewModel.didTapStart(fromDate: true)
    }
    @IBAction func didTapEndTime(_ sender: UIButton) {
        viewModel.didTapEnd(fromDate: false)
    }
    @IBAction func didTapEndDate(_ sender: UIButton) {
        viewModel.didTapEnd(fromDate: true)
    }
    @IBAction func didToggleSwitcher(_ sender: UISwitch) {
        viewModel.didToggleSwitcher(isOn: sender.isOn)
    }
    @IBAction func didTapReminder(_ sender: UIButton) {
        viewModel.didTapReminder()
    }
    @IBAction func didEditName(_ sender: UITextField) {
        viewModel.didEditName(name: sender.text ?? "")
    }
    @IBAction func didEditPhone(_ sender: UITextField) {
        viewModel.didEditPhone(phone: sender.text ?? "")
    }
    @IBAction func didEditPrice(_ sender: UITextField) {
        viewModel.didEditPrice(price: sender.text ?? "")
    }
    
    @IBAction func didTapAdd(_ sender: UIButton) {
        var notes = notesTextView.text
        if notes == "הערות" {
            notes = ""
        }
        viewModel.didTapAdd(name: nameTextField.text ?? "",
                            phone: phoneTextField.text ?? "",
                            location: locationTextField.text ?? "",
                            startDate: startDatePicker.date,
                            endDate: endDatePicker.date,
                            price: priceTextField.text ?? "",
                            notes: notes ?? "")
    }

    @IBAction func didTapCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func didSelectStartDate() {
        viewModel.didSelectStartDate(date: startDatePicker.date)
        endDatePicker.date = Calendar.current.date(byAdding: .hour, value: 1, to: startDatePicker.date) ?? Date()
    }
    
    @objc func didSelectEndDate() {
        viewModel.didSelectEndDate(date: endDatePicker.date)
    }
    
    private func setTextFields() {
        nameTextField.attributedPlaceholder = NSAttributedString(string: "שם הלקוח", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "30white")!])
        phoneTextField.attributedPlaceholder = NSAttributedString(string: "טלפון", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "30white")!])
        priceTextField.attributedPlaceholder = NSAttributedString(string: "מחיר", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "30white")!])
        locationTextField.attributedPlaceholder = NSAttributedString(string: "מיקום", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "30white")!])
        locationTextField.delegate = self
        nameTextField.borderStyle = .none
        phoneTextField.borderStyle = .none
        priceTextField.borderStyle = .none
        locationTextField.borderStyle = .none
        notesTextView.delegate = self
        phoneTextField.delegate = self
        phoneTextField.text = viewModel.phone
        nameTextField.text = viewModel.name
    }
}

extension CreateEventViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case locationTextField:
            viewModel.didTapLocation()
        default:
            break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case phoneTextField:
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= 10
        default:
            return false
        }
    }
}

extension CreateEventViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "  הערות     " {
            textView.text = nil
            textView.textColor = UIColor(named: "50white")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "  הערות     "
            textView.textColor = UIColor(named: "30white")
        }
    }
}

extension CreateEventViewController: CreateEventViewModelDelegate {
    func presentAlert(message: String) {
        presentErrorAlert(with: message)
    }
    
    
    func updateStartButtonsTitle(date: String, time: String) {
        startDateButton.setTitle(date, for: .normal)
        startTimeButton.setTitle(time, for: .normal)
    }
    
    func updateEndButtonsTitle(date: String, time: String) {
        endDateButton.setTitle(date, for: .normal)
        endTimeButton.setTitle(time, for: .normal)
    }
    
    func setStartDatePicker(toDate: Bool) {
        if toDate {
            startDatePicker.datePickerMode = .date
            if #available(iOS 14.0, *) {
                startDatePicker.preferredDatePickerStyle = .inline
            }
        } else {
            startDatePicker.datePickerMode = .time
            if #available(iOS 13.4, *) {
                startDatePicker.preferredDatePickerStyle = .wheels
            }
        }
    }
    
    func setEndDatePicker(toDate: Bool) {
        if toDate {
            endDatePicker.datePickerMode = .date
            if #available(iOS 14.0, *) {
                endDatePicker.preferredDatePickerStyle = .inline
            }
        } else {
            endDatePicker.datePickerMode = .time
            if #available(iOS 13.4, *) {
                endDatePicker.preferredDatePickerStyle = .wheels
            }
        }
    }
    
    func changeStartDatePickerVisability(isHidden: Bool, fromDate: Bool) {
        if isHidden {
            startDatePickerHeight.constant = 0
            startDateSeprator.isHidden = true
            startDateButton.tintColor = UIColor(named: "50white")!
            startTimeButton.tintColor = UIColor(named: "50white")!
            UIView.animate(withDuration: 0.1) {
                self.startDatePicker.alpha = 0
                self.view.layoutIfNeeded()
            }
        } else {
            startDatePickerHeight.constant = fromDate ? 280 : 150
            if fromDate {
                startDateButton.tintColor = UIColor(named: "gold")!
                startTimeButton.tintColor = UIColor(named: "50white")!
            } else {
                startTimeButton.tintColor = UIColor(named: "gold")!
                startDateButton.tintColor = UIColor(named: "50white")!
            }
            startDateSeprator.isHidden = false
            UIView.animate(withDuration: 0.1) {
                self.startDatePicker.alpha = 1
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func changeEndDatePickerVisability(isHidden: Bool, fromDate: Bool) {
        if isHidden {
            endDatePickerHeight.constant = 0
            endDateSeprator.isHidden = true
            endDateButton.tintColor = UIColor(named: "50white")!
            endTimeButton.tintColor = UIColor(named: "50white")!
            UIView.animate(withDuration: 0.1) {
                self.endDatePicker.alpha = 0
                self.view.layoutIfNeeded()
            }
        } else {
            endDatePickerHeight.constant = fromDate ? 280 : 150
            if fromDate {
                endDateButton.tintColor = UIColor(named: "gold")!
                endTimeButton.tintColor = UIColor(named: "50white")!
            } else {
                endTimeButton.tintColor = UIColor(named: "gold")!
                endDateButton.tintColor = UIColor(named: "50white")!
            }
            endDateSeprator.isHidden = false
            UIView.animate(withDuration: 0.1) {
                self.endDatePicker.alpha = 1
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func changeTimeButtonsVisability(isHidden: Bool) {
        startTimeButton.isHidden = isHidden
        endTimeButton.isHidden = isHidden
    }
    
    func moveToReminderVC() {
        let reminderVC: ReminderViewController = storyBoard.instantiateViewController()
        reminderVC.viewModel = ReminderViewModel()
        reminderVC.delegate = viewModel
        reminderVC.modalPresentationStyle = .overFullScreen
        self.present(reminderVC, animated: true, completion: nil)
    }
    
    func updateReminderButtonTitle(title: String) {
        self.reminderButton.setTitle(title, for: .normal)
    }
    
    func presentAlertThatLeadIsExist() {
        presentErrorAlert(with: "הלקוח קיים במסך הלידים, להבא יהיה נוח יותר לפתוח עסקה ממסך הלידים. ניתן להמשיך כרגיל", buttonTitle: "המשך")
    }
    
    func changeAddButtonAvailability(isEnabled: Bool) {
        self.addButton.isEnabled = isEnabled
    }
    
    func moveToLocationVC() {
        let locationVC: LocationViewController = storyBoard.instantiateViewController()
        locationVC.viewModel = LocationViewModel(delegate: locationVC, currentLocation: locationTextField.text ?? "")
        locationVC.delegate = viewModel
        locationVC.modalPresentationStyle = .overFullScreen
        self.present(locationVC, animated: true, completion: nil)
    }
    
    func updateLoactionToTextField(location: String) {
        self.locationTextField.text = location
    }
    
    func updateExisitingEvent(event: Event) {
        switch event {
        case .deal(viewModel: let viewModel):
            nameTextField.text = viewModel.eventName
            phoneTextField.text = viewModel.phone
            locationTextField.text = viewModel.location
            startDatePicker.date = viewModel.deal.startDate
            endDatePicker.date = viewModel.deal.endDate
            priceTextField.text = viewModel.deal.price
            notesTextView.text = viewModel.notes
            reminderButton.setTitle(viewModel.reminderTitle, for: .normal)
            self.viewModel.didSelectStartDate(date: startDatePicker.date)
            self.viewModel.didSelectEndDate(date: endDatePicker.date)
            self.addButton.isEnabled = true
        case .mission(viewModel: let viewModel):
            nameTextField.text = viewModel.eventName
            locationTextField.text = viewModel.location
            startDatePicker.date = viewModel.mission.startDate
            endDatePicker.date = viewModel.mission.endDate
            notesTextView.text = viewModel.notes
            reminderButton.setTitle(viewModel.reminderTitle, for: .normal)
            self.viewModel.didSelectStartDate(date: startDatePicker.date)
            self.viewModel.didSelectEndDate(date: endDatePicker.date)
            self.addButton.isEnabled = true
        }
    }
    
    func sendDealToCalendar(deal: Deal, isNewDeal: Bool) {
        delegate?.didPick(deal: deal, isNewDeal: isNewDeal)
        self.dismiss(animated: true)
    }
    
    func sendMissionToCalendar(mission: Mission, isNewMission: Bool) {
        delegate?.didPick(mission: mission, isNewMission: isNewMission)
        self.dismiss(animated: true)
    }
    
    func returnToPrevious() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateUItoMission(isEdit: Bool) {
        for v in dealViews {
            v.isHidden = true
        }
        titleLabel.text = isEdit ? "עריכת משימה" : "משימה חדשה"
        nameTextField.attributedPlaceholder = NSAttributedString(string: "כותרת", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "30white")!])
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: detailsView.topAnchor, constant: 5),
            nameTextField.leftAnchor.constraint(equalTo: detailsView.leftAnchor, constant: 5),
            detailsView.bottomAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 5),
            detailsView.rightAnchor.constraint(equalTo: nameTextField.rightAnchor, constant: 15)])
        if isEdit {
            addButton.setTitle("עדכן", for: .normal)
        }
    }
    
    func updateUItoDeal() {
        titleLabel.text = "עריכת עסקה"
        addButton.setTitle("עדכן", for: .normal)
    }
}


