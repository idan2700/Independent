//
//  CreateEventTableViewCell.swift
//  Independent
//
//  Created by Idan Levi on 16/11/2021.
//

import UIKit
import MapKit

protocol CreateDealTableViewCellDelegate: AnyObject {
    func didTapCancel()
    func updateCellHeight()
    func didTapReminder(cell: CreateDealTableViewCell)
    func didPickNewDeal(newDeal: Deal)
    func presentErrorAlert(message: String)
    func presentAlertThatLeadIsExist()
}

class CreateDealTableViewCell: UITableViewCell {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var startDateButton: UIButton!
    @IBOutlet weak var startDatePickerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var endDateButton: UIButton!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePickerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var locationSearchBar: UISearchBar!
    @IBOutlet weak var placesTableView: UITableView!
    @IBOutlet weak var placesTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var nameErrorLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var priceErrorLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var phoneErrorLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var phoneErrorLabel: UILabel!
    @IBOutlet weak var reminderButton: UIButton!
    private let locationManager = CLLocationManager()
    
    weak var delegate: CreateDealTableViewCellDelegate?
    var viewModel: CreateDealTableViewCellViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        placesTableView.estimatedRowHeight = 48
        placesTableView.dataSource = self
        placesTableView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        startDatePickerViewHeight.constant = 0
        startDatePicker.overrideUserInterfaceStyle = .dark
        startDatePicker.setValue(0.8, forKey: "alpha")
        startDatePicker.minimumDate = Date()
        startDatePicker.alpha = 0
        endDatePickerViewHeight.constant = 0
        endDatePicker.overrideUserInterfaceStyle = .dark
        endDatePicker.setValue(0.8, forKey: "alpha")
        endDatePicker.minimumDate = Date()
        endDatePicker.alpha = 0
        startDateButton.makeRoundCorners(radius: 5)
        endDateButton.makeRoundCorners(radius: 5)
        notesTextView.makeRoundCorners(radius: 5)
        reminderButton.makeRoundCorners(radius: 5)
        nameTextField.attributedPlaceholder = NSAttributedString(string: "שם הלקוח", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "30white")!])
        phoneTextField.attributedPlaceholder = NSAttributedString(string: "טלפון", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "30white")!])
        startDatePicker.addTarget(self, action: #selector(didSelectStartDate), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(didSelectEndDate), for: .valueChanged)
        notesTextView.delegate = self
        if let textfield = locationSearchBar.value(forKey: "searchField") as? UITextField {
            let atrbString = NSAttributedString(string: "מיקום", attributes: [.foregroundColor : UIColor(named: "30white")!, .font : UIFont.systemFont(ofSize: 15)])
            textfield.attributedPlaceholder = atrbString
            textfield.textColor = UIColor(named: "50white") ?? .white
            textfield.backgroundColor = UIColor(named: "10white") ?? .white
            textfield.makeRoundCorners(radius: 5)
        }
        placesTableViewHeight.constant = 0
        locationSearchBar.delegate = self
    }
    
    func configure(name: String?, phone: String?) {
        viewModel.exsitingLeadIndex = nil
        if let name = name,
           let phone = phone {
            self.nameTextField.text = name
            self.phoneTextField.text = phone
        }
        startDatePicker.date = Calendar.current.date(byAdding: .minute , value: 15, to: viewModel.currentDate) ?? Date()
        viewModel.handleDatePresentation(with: startDatePicker.date, toStartButton: true)
        endDatePicker.date = Calendar.current.date(byAdding: .hour, value: 1, to: startDatePicker.date) ?? Date()
        viewModel.handleDatePresentation(with: endDatePicker.date, toStartButton: false)
        viewModel.checkForExisitingDeal()
    }

    @IBAction func didTapAdd(_ sender: UIButton) {
        var notes = notesTextView.text
        if notes == "הערות" {
            notes = ""
        }
        viewModel.didTapAdd(name: nameTextField.text ?? "",
                            phone: phoneTextField.text ?? "",
                            location: locationSearchBar.text ?? "",
                            startDate: startDatePicker.date,
                            endDate: endDatePicker.date,
                            price: priceTextField.text ?? "",
                            notes: notes ?? "")
    }
    
    @IBAction func didTapStartDate(_ sender: UIButton) {
        viewModel.didTapStartDate()
    }
    
    @IBAction func didTapEndDate(_ sender: UIButton) {
        viewModel.didTapEndDate()
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        viewModel.exsitingLeadIndex = nil
        delegate?.didTapCancel()
    }
    
    @IBAction func didEditName(_ sender: UITextField) {
        viewModel.didEditName(name: sender.text ?? "")
    }
    
    @IBAction func didEditPrice(_ sender: UITextField) {
        viewModel.didEditPrice(price: sender.text ?? "")
    }
    
    @IBAction func didEditPhone(_ sender: UITextField) {
        viewModel.didEditPhone(phone: sender.text ?? "")
    }
    
    @IBAction func didTapReminder(_ sender: UIButton) {
        delegate?.didTapReminder(cell: self)
    }
    
    @objc func didSelectStartDate() {
        endDatePicker.date = Calendar.current.date(byAdding: .hour, value: 1, to: startDatePicker.date) ?? Date()
        viewModel.handleDatePresentation(with: startDatePicker.date, toStartButton: true)
        viewModel.handleDatePresentation(with: endDatePicker.date, toStartButton: false)
    }
    
    @objc func didSelectEndDate() {
        viewModel.handleDatePresentation(with: endDatePicker.date, toStartButton: false)
    }
}

extension CreateDealTableViewCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "הערות" {
            textView.text = nil
            textView.textColor = UIColor(named: "50white")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "הערות"
            textView.textColor = UIColor(named: "30white")
        }
    }
}

extension CreateDealTableViewCell: CreateDealTableViewCellViewModelDelegate {
    func updateExisitingDeal(event: Event) {
        switch event {
        case .deal(viewModel: let viewModel):
            nameTextField.text = viewModel.eventName
            phoneTextField.text = viewModel.phone
            locationSearchBar.text = viewModel.location
            startDatePicker.date = viewModel.deal.startDate
            endDatePicker.date = viewModel.deal.endDate
            priceTextField.text = viewModel.deal.price
            notesTextView.text = viewModel.notes
            reminderButton.setTitle(viewModel.reminderTitle, for: .normal)
            self.viewModel.handleDatePresentation(with: startDatePicker.date, toStartButton: true)
            self.viewModel.handleDatePresentation(with: endDatePicker.date, toStartButton: false)
        case .mission(viewModel:):
            break
        }
    }
    
    func presentError() {
        self.delegate?.presentErrorAlert(message: "נוצרה בעיה מול השרת בשמירת העסקה, אנא נסה שנית ")
    }
    
    func thereIsLeadInLeadsVC() {
        self.delegate?.presentAlertThatLeadIsExist()
    }
    
    func didPickNewDeal(deal: Deal) {
        delegate?.didPickNewDeal(newDeal: deal)
    }
    
    func changeErrorNameVisability(toPresent: Bool) {
        if toPresent {
            self.nameErrorLabelHeight.constant = 15
            self.nameTextField.makeBorder(width: 1, color: UIColor(named: "darkred")!.cgColor)
            UIView.animate(withDuration: 0.5) {
                self.contentView.layoutIfNeeded()
                self.delegate?.updateCellHeight()
            }
        } else {
            self.nameErrorLabelHeight.constant = 0
            self.nameTextField.makeBorder(width: 0, color: UIColor.clear.cgColor)
            UIView.animate(withDuration: 0.5) {
                self.contentView.layoutIfNeeded()
                self.delegate?.updateCellHeight()
            }
        }
    }
    
    func changePhoneErrorVisability(toPresent: Bool, message: String) {
        if toPresent {
            self.phoneErrorLabel.text = message
            self.phoneErrorLabelHeight.constant = 15
            self.phoneTextField.makeBorder(width: 1, color: UIColor(named: "darkred")!.cgColor)
            UIView.animate(withDuration: 0.5) {
                self.contentView.layoutIfNeeded()
                self.delegate?.updateCellHeight()
            }
        } else {
            self.phoneErrorLabelHeight.constant = 0
            self.phoneTextField.makeBorder(width: 0, color: UIColor.clear.cgColor)
            UIView.animate(withDuration: 0.5) {
                self.contentView.layoutIfNeeded()
                self.delegate?.updateCellHeight()
            }
        }
    }
    
    func changePriceErrorVisability(toPresent: Bool) {
        if toPresent {
            self.priceErrorLabelHeight.constant = 15
            self.priceTextField.makeBorder(width: 1, color: UIColor(named: "darkred")!.cgColor)
            UIView.animate(withDuration: 0.5) {
                self.contentView.layoutIfNeeded()
                self.delegate?.updateCellHeight()
            }
        } else {
            self.priceErrorLabelHeight.constant = 0
            self.priceTextField.makeBorder(width: 0, color: UIColor.clear.cgColor)
            UIView.animate(withDuration: 0.5) {
                self.contentView.layoutIfNeeded()
                self.delegate?.updateCellHeight()
            }
        }
    }
    
    func reloadData() {
        self.placesTableView.reloadData()
    }

    func changePlacesTableViewVisability(toOpen: Bool) {
        if toOpen {
            if viewModel.matchingItems.count == 0 {
                placesTableViewHeight.constant = 0
            } else if viewModel.matchingItems.count > 5 {
                placesTableViewHeight.constant = self.placesTableView.estimatedRowHeight * 5
            } else {
                placesTableViewHeight.constant = self.placesTableView.estimatedRowHeight * CGFloat(viewModel.matchingItems.count)
            }
            UIView.animate(withDuration: 0.5) {
                self.contentView.layoutIfNeeded()
                self.delegate?.updateCellHeight()
            }
        } else {
            placesTableViewHeight.constant = 0
            UIView.animate(withDuration: 0.5) {
                self.contentView.layoutIfNeeded()
                self.delegate?.updateCellHeight()
            }
        }
    }
    
    func updateButtonTitleToSelectedDate(with date: String, toStartButton: Bool) {
        if toStartButton {
            startDateButton.setTitle(date, for: .normal)
        } else {
            endDateButton.setTitle(date, for: .normal)
        }
    }
    
    func changeStartDatePickerVisability(toOpen: Bool) {
        if toOpen {
            startDatePickerViewHeight.constant = 360
            UIView.animate(withDuration: 0.5) {
                self.contentView.layoutIfNeeded()
                self.startDatePicker.alpha = 1
                self.delegate?.updateCellHeight()
            }
        } else {
            startDatePickerViewHeight.constant = 0
            UIView.animate(withDuration: 0.5) {
                self.contentView.layoutIfNeeded()
                self.startDatePicker.alpha = 0
                self.delegate?.updateCellHeight()
            }
        }
    }
    
    func changeEndDatePickerVisability(toOpen: Bool) {
        if toOpen {
            endDatePickerViewHeight.constant = 360
            UIView.animate(withDuration: 0.5) {
                self.contentView.layoutIfNeeded()
                self.endDatePicker.alpha = 1
                self.delegate?.updateCellHeight()
            }
        } else {
            endDatePickerViewHeight.constant = 0
            UIView.animate(withDuration: 0.5) {
                self.contentView.layoutIfNeeded()
                self.endDatePicker.alpha = 0
                self.delegate?.updateCellHeight()
            }
        }
    }
}

extension CreateDealTableViewCell: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.didStartToSearchLocation(searchText: searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.locationSearchBar.text = nil
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.changePlacesTableViewVisability(toOpen: false)
    }
}

extension CreateDealTableViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = placesTableView.dequeueReusableCell(withIdentifier: "PlacesCell") as? PlacesTableViewCell else {return UITableViewCell()}
        let cellViewModel = viewModel.getCellViewModel(at: indexPath)
        cell.configure(with: cellViewModel)
        return cell
    }
}

extension CreateDealTableViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellViewModel = viewModel.getCellViewModel(at: indexPath)
        if cellViewModel.place == cellViewModel.city {
            self.locationSearchBar.text = cellViewModel.city
        } else {
            self.locationSearchBar.text = "\(cellViewModel.place), \(cellViewModel.city)"
        }
        viewModel.didEndToSearchLocation()
    }
}

extension CreateDealTableViewCell: CLLocationManagerDelegate {
}

extension CreateDealTableViewCell: ReminderViewControllerDelegate {
    func didPick(timeOfReminder: Int?, reminderTitle: String) {
        self.viewModel.reminder = timeOfReminder
        self.viewModel.reminderTitle = reminderTitle
        self.reminderButton.setTitle(String(reminderTitle), for: .normal)
    }
}
