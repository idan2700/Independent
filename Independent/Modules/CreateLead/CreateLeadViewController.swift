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
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    weak var delegate: CreateLeadViewControllerDelegate?
    var viewModel: CreateLeadViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.text = viewModel.nameFromContact ?? ""
        phoneTextField.text = viewModel.phoneFromContact ?? ""
        summryTextView.layer.cornerRadius = 10
        nameTextField.layer.cornerRadius = 10
        phoneTextField.layer.cornerRadius = 10
        addLeadButton.makeRoundCorners(radius: 10)
        addLeadView.makeRoundCorners(radius: 10)
        nameTextField.attributedPlaceholder = NSAttributedString(string: "שם מלא", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "30white")!])
        phoneTextField.attributedPlaceholder = NSAttributedString(string: "טלפון", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "30white")!])
    }

    @IBAction func didTapCancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func didTapAdd(_ sender: UIButton) {
        viewModel.didTapAdd(name: nameTextField.text ?? "", date: Date(), summary: summryTextView.text, phoneNumber: phoneTextField.text ?? "")
    }
}

extension CreateLeadViewController: CreateLeadViewModelDelegate {
    func returnToLeadVC(with newLead: Lead) {
        self.delegate?.didPick(newLead: newLead)
        self.dismiss(animated: true, completion: nil)
    }
    
    func presentAlert(message: String) {
        
    }
}
