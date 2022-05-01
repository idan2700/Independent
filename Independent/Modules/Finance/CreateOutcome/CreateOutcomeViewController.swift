//
//  CreateOutcomeViewController.swift
//  Independent
//
//  Created by Idan Levi on 23/12/2021.
//

import UIKit

protocol CreateOutcomeViewControllerDelegate: AnyObject {
    func didPick(newOutcome: Outcome)
}

class CreateOutcomeViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var titleErrorLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var amountErrorLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var outcomeTypeStackView: UIStackView!
    @IBOutlet weak var paymentsPicker: UIPickerView!
    @IBOutlet var outcomeTypeButtons: [UIButton]!
    @IBOutlet weak var paymentsPickerWidth: NSLayoutConstraint!
    @IBOutlet weak var paymentsPickerHeight: NSLayoutConstraint!
    @IBOutlet weak var outcomeView: UIView!
    
    weak var delegate: CreateOutcomeViewControllerDelegate?
    var viewModel: CreateOutcomeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.start()
        addButton.makeRoundCorners(radius: 10)
        datePicker.overrideUserInterfaceStyle = .dark
        datePickerView.makeRoundCorners(radius: 10)
        datePicker.setValue(0.8, forKey: "alpha")
        titleTextField.text = viewModel.title
        amountTextField.text = viewModel.amount
        datePicker.date = viewModel.date
        outcomeTypeStackView.makeRoundCorners(radius: 10)
        paymentsPickerWidth.constant = (outcomeTypeStackView.bounds.width / 3) - 10
        paymentsPickerHeight.constant = 0
        paymentsPicker.overrideUserInterfaceStyle = .dark
        paymentsPicker.dataSource = self
        paymentsPicker.delegate = self
        paymentsPicker.selectRow(2, inComponent: 0, animated: false)
        outcomeView.makeRoundCorners(radius: 10)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let origin = self.view.transform
        self.view.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.3) {
            self.view.transform = origin
        }
    }
    
    @IBAction func didTapAdd(_ sender: UIButton) {
        viewModel.didTapAdd(title: titleTextField.text ?? "",
                            amountString: amountTextField.text ?? "",
                            date: datePicker.date)
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func didEditTitle(_ sender: UITextField) {
        viewModel.didEditTitle(title: titleTextField.text ?? "")
    }
    
    @IBAction func didEditAmount(_ sender: UITextField) {
        viewModel.didEditAmount(amount: amountTextField.text ?? "")
    }
    
    
    @IBAction func didTapOutcomeType(_ sender: UIButton) {
        if let titleLabel = sender.titleLabel?.text {
        viewModel.didTapIncomeType(type: titleLabel)
        }
    }
}

extension CreateOutcomeViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.numberOfRaws
    }
}

extension CreateOutcomeViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.payments[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.numberOfPayments = Int(viewModel.payments[row])
    }
}

extension CreateOutcomeViewController: CreateOutcomeViewModelDelegate {
    func changePaymentsPickerVisability(toPresent: Bool) {
        if toPresent {
            paymentsPickerHeight.constant = 100
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        } else {
            paymentsPickerHeight.constant = 0
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func changeIncomeTypeButtonUI(currentSelectedButton: String) {
        for button in outcomeTypeButtons {
            if button.titleLabel?.text == currentSelectedButton {
                button.backgroundColor = UIColor(named: "10white") ?? .white
                button.tintColor = UIColor(named: "gold") ?? .white
            } else {
                button.backgroundColor = UIColor(named: "5white") ?? .white
                button.tintColor = UIColor(named: "30white") ?? .white
            }
        }
    }
    
    func changeErrorNameVisability(toPresent: Bool) {
            if toPresent {
                self.titleErrorLabelHeight.constant = 15
                self.titleTextField.makeBorder(width: 1, color: UIColor(named: "ired")!.cgColor)
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
            } else {
                self.titleErrorLabelHeight.constant = 0
                self.titleTextField.makeBorder(width: 0, color: UIColor.clear.cgColor)
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
            }
    }
    
    func changePriceErrorVisability(toPresent: Bool) {
        if toPresent {
            self.amountErrorLabelHeight.constant = 15
            self.amountTextField.makeBorder(width: 1, color: UIColor(named: "ired")!.cgColor)
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        } else {
            self.amountErrorLabelHeight.constant = 0
            self.amountTextField.makeBorder(width: 0, color: UIColor.clear.cgColor)
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func returnToFinanceVC(with outcome: Outcome) {
        self.delegate?.didPick(newOutcome: outcome)
        self.dismiss(animated: true, completion: nil)
    }
    
    func presentAlert(message: String) {
        self.presentErrorAlert(with: message)
    }
}

