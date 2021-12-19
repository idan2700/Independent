//
//  CreateIncomeViewController.swift
//  Independent
//
//  Created by Idan Levi on 10/12/2021.
//

import UIKit

protocol CreateIncomeViewControllerDelegate: AnyObject {
    func didPick(newIncome: Income)
}

class CreateIncomeViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var titleErrorLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var amountErrorLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var delegate: CreateIncomeViewControllerDelegate?
    var viewModel: CreateIncomeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButton.makeRoundCorners(radius: 10)
        datePicker.overrideUserInterfaceStyle = .dark
        datePicker.setValue(0.8, forKey: "alpha")
        titleTextField.text = viewModel.title
        amountTextField.text = viewModel.amount
        datePicker.date = viewModel.date
    }
    
    @IBAction func didTapAdd(_ sender: UIButton) {
        viewModel.didTapAdd(title: titleTextField.text ?? "",
                            amount: amountTextField.text ?? "",
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
}

extension CreateIncomeViewController: CreateIncomeViewModelDelegate {
    func changeErrorNameVisability(toPresent: Bool) {
            if toPresent {
                self.titleErrorLabelHeight.constant = 15
                self.titleTextField.makeBorder(width: 1, color: UIColor(named: "darkred")!.cgColor)
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
            self.amountTextField.makeBorder(width: 1, color: UIColor(named: "darkred")!.cgColor)
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
    
    func returnToFinanceVC(with income: Income) {
        self.delegate?.didPick(newIncome: income)
        self.dismiss(animated: true, completion: nil)
    }
    
    func presentAlert(message: String) {
        self.presentErrorAlert(with: message)
    }
}
