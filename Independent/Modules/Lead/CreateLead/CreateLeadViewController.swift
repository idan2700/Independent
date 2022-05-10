//
//  CreateLeadViewController.swift
//  Independent
//
//  Created by Idan Levi on 31/10/2021.
//

import UIKit

protocol CreateLeadViewControllerDelegate: AnyObject {
    func didPick(newLead: Lead)
}

class CreateLeadViewController: UIViewController {

    @IBOutlet weak var addLeadButton: UIButton!
    @IBOutlet weak var addLeadView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var summryTextView: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    weak var delegate: CreateLeadViewControllerDelegate?
    var viewModel: CreateLeadViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneTextField.delegate = self
        nameTextField.text = viewModel.nameFromContact ?? ""
        phoneTextField.text = viewModel.phoneFromContact ?? ""
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let original = addLeadView.transform
        addLeadView.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.3) {
            self.addLeadView.transform = original
        }
    }

    @IBAction func didTapCancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func didTapAdd(_ sender: UIButton) {
        viewModel.didTapAdd(name: nameTextField.text ?? "", date: Date(), summary: summryTextView.text, phoneNumber: phoneTextField.text ?? "")
    }
    
    @IBAction func didEditPhone(_ sender: UITextField) {
       viewModel.didEditPhone(phone: sender.text ?? "")
    }
    
    private func updateUI() {
        summryTextView.layer.cornerRadius = 10
        nameTextField.layer.cornerRadius = 10
        phoneTextField.layer.cornerRadius = 10
        addLeadButton.makeRoundCorners(radius: 10)
        addLeadView.makeRoundCorners(radius: 10)
        nameTextField.attributedPlaceholder = NSAttributedString(string: "שם מלא", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "30white")!])
        phoneTextField.attributedPlaceholder = NSAttributedString(string: "טלפון", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "30white")!])
    }
}

extension CreateLeadViewController: CreateLeadViewModelDelegate {
    func returnToLeadVC(with newLead: Lead) {
        self.delegate?.didPick(newLead: newLead)
        self.dismiss(animated: true, completion: nil)
    }
    
    func presentAlert(message: String) {
        self.presentErrorAlert(with: message)
    }
    
    func restartPhoneTextField() {
        self.phoneTextField.text = ""
    }
}

extension CreateLeadViewController: UITextFieldDelegate {
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
