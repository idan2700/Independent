//
//  ViewController.swift
//  Independent
//
//  Created by Idan Levi on 25/10/2021.
//

import UIKit
import Lottie

class RegestrationViewController: UIViewController {
    

 

    @IBOutlet weak var titleLabelStack: UIStackView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var signInViewHeight: NSLayoutConstraint!
    @IBOutlet weak var nameTextField: ATCTextField!
    @IBOutlet weak var nameImage: UIImageView!
    @IBOutlet weak var phoneNumberTextField: ATCTextField!
    @IBOutlet weak var sendVerifacationButton: UIButton!
    @IBOutlet weak var systemEnterButton: UIButton!
    @IBOutlet weak var haveAccountLabel: UILabel!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var phoneErrorLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var mainLoader: AnimationView!
    @IBOutlet weak var sendingCodeLabel: UILabel!
    private var viewModel: RegestrationViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = RegestrationViewModel(delegate: self)
        viewModel.start()
        updateViewControllerUI()
    }
    
    @IBAction func didTapName(_ sender: ATCTextField) {
        viewModel.validateName(name: sender.text)
    }
    
    @IBAction func didTapPhoneNumber(_ sender: ATCTextField) {
        viewModel.validatePhone(phone: sender.text)
    }
    
    @IBAction func didTapSendVerifaction(_ sender: UIButton) {
        viewModel.didTapSendVerifaction(phone: phoneNumberTextField.text , name: nameTextField.text)
    }
    
    @IBAction func didTapLogin(_ sender: UIButton) {
        viewModel.didTapLogin()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SignInToVerifcation" {
            let verifyVC = segue.destination as? VerifcationViewController
            verifyVC?.viewModel = VerifcationViewModel(delegate: verifyVC)
        }
    }
    
    func updateViewControllerUI() {
        view.addGesture()
        sendVerifacationButton.makeRoundCorners(radius: 20)
        signInViewHeight.constant = self.view.bounds.height * 0.6
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: "שם העסק/ עוסק",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        phoneNumberTextField.attributedPlaceholder = NSAttributedString(
            string: "טלפון",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
    }
}

extension RegestrationViewController: RegestrationViewModelDelegate {
    func presentError(message: String) {
        errorLabel.isHidden = false
        errorLabel.text = message
    }
    
    func hideError() {
        errorLabel.isHidden = true
    }
    
    func presentPhoneError(message: String) {
        phoneNumberTextField.lineColor = .red
        phoneErrorLabel.isHidden = false
        phoneErrorLabel.text = message
    }
    
    func hidePhoneError() {
        phoneErrorLabel.isHidden = true
        phoneNumberTextField.lineColor = UIColor(named: "50white") ?? .white
    }
    
    func hideNameError() {
        nameErrorLabel.isHidden = true
        nameTextField.lineColor = UIColor(named: "50white") ?? .white
    }
    
    func presentNameError(message: String) {
        nameTextField.lineColor = .red
        nameErrorLabel.isHidden = false
        nameErrorLabel.text = message
    }
    
    func changeToLoginScreen() {
        errorLabel.isHidden = true
        nameErrorLabel.isHidden = true
        systemEnterButton.setTitle("הרשמה", for: .normal)
        haveAccountLabel.text = "אין לך חשבון?"
    }
    
    func changeToSignInScreen() {
        systemEnterButton.setTitle("כניסה למערכת", for: .normal)
        haveAccountLabel.text = "יש לך חשבון?"
    }
    
    func hideNameTextField() {
        UIView.animate(withDuration: 0.3) {
            self.nameTextField.alpha = 0
            self.nameImage.alpha = 0
        }
    }
    
    func showNameTextField() {
        UIView.animate(withDuration: 0.3) {
            self.nameTextField.alpha = 1
            self.nameImage.alpha = 1
        }
    }
    
    func textFieldEndEditing() {
        phoneNumberTextField.endEditing(true)
    }
    
    func moveToVerficationVC() {
        performSegue(withIdentifier: "SignInToVerifcation", sender: self)
    }
    
    func presentLoader() {
        middleView.isHidden = true
        loader.isHidden = false
        sendingCodeLabel.isHidden = false
    }
    
    func hideLoader() {
        loader.isHidden = true
        sendingCodeLabel.isHidden = true
        middleView.isHidden = false
    }
    
    func presentStartAnimation() {
        UIView.animate(withDuration: 0.5) {
            self.mainLoader.alpha = 0
        }
        mainLoader.isHidden = true
        middleView.isHidden = false
        titleLabelStack.isHidden = false
        let originalTitleTransform = self.titleLabelStack.transform
        let originalmiddleViewTransform = self.middleView.transform
        titleLabelStack.transform = CGAffineTransform(scaleX: 0, y: 0)
        middleView.transform = CGAffineTransform(scaleX: 0, y: 0)

        UIView.animate(withDuration: 1.5) {
            self.titleLabelStack.transform = originalTitleTransform
            self.middleView.transform = originalmiddleViewTransform
        }
    }
    
    func presentMainLoader() {
        AnimationManager.shared.makeLottieAnimation(view: mainLoader)
    }
}


