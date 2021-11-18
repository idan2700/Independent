//
//  VerficationViewController.swift
//  Independent
//
//  Created by Idan Levi on 25/10/2021.
//

import UIKit

class VerifcationViewController: UIViewController {
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var verficationViewHight: NSLayoutConstraint!
    @IBOutlet weak var verifyTextField: ATCTextField!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var codeErrorLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var connectingLabel: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    var viewModel: VerifcationViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGesture()
        verficationViewHight.constant = self.view.bounds.height * 0.5
        verifyButton.makeRoundCorners(radius: 20)
        verifyTextField.attributedPlaceholder = NSAttributedString(
            string: "הקלד קוד אימות",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
    }
    
    @IBAction func didEditCode(_ sender: ATCTextField) {
        viewModel.validateCode(code: sender.text)
    }
    
    @IBAction func didTapVerify(_ sender: UIButton) {
        viewModel.didTapVerify(code: verifyTextField.text)
    }
    
    @IBAction func didTapResendCode(_ sender: UIButton) {
        viewModel.didTapResendCode()
    }
    
    @IBAction func didTapBackToRegistration(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension VerifcationViewController: VerifcationViewModelDelegate {
    func presentLoader() {
        middleView.isHidden = true
        loader.isHidden = false
        connectingLabel.isHidden = false
    }
    
    func hideLoader() {
        loader.isHidden = true
        connectingLabel.isHidden = true
        middleView.isHidden = false
    }
    
    func updateConectingLabel(text: String) {
        connectingLabel.text = text
    }
    
    func presentError(message: String) {
        errorLabel.isHidden = false
        errorLabel.text = message
    }
    
    func hideError() {
        errorLabel.isHidden = true
    }
    
    func presentCodeError(message: String) {
        codeErrorLabel.isHidden = false
        codeErrorLabel.text = message
        verifyTextField.lineColor = UIColor(named: "darkred") ?? .red
    }
    
    func hideCodeError() {
        codeErrorLabel.isHidden = true
        verifyTextField.lineColor = UIColor(named: "50white") ?? .white
    }
    
    func moveToMainTab() {
        performSegue(withIdentifier: "VerifyToMainTabBar", sender: self)
    }
}
