//
//  VerifcationViewModel.swift
//  Independent
//
//  Created by Idan Levi on 25/10/2021.
//

import Foundation
import FirebaseAuth

protocol VerifcationViewModelDelegate: AnyObject {
    func moveToMainTab()
    func presentCodeError(message: String)
    func hideCodeError()
    func presentError(message: String)
    func hideError()
    func presentLoader()
    func hideLoader()
    func updateConectingLabel(text: String)
}

class VerifcationViewModel {
    
    weak var delegate: VerifcationViewModelDelegate?
    
    init(delegate: VerifcationViewModelDelegate?) {
        self.delegate = delegate
    }
    
    func validateCode(code: String?) {
        if let code = code {
            if code.count == 0 {
                self.delegate?.presentCodeError(message: "לא הכנסת קוד אימות")
                return
            }
        }
        delegate?.hideCodeError()
    }
    
    func didTapVerify(code: String?) {
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else { return }
        guard let code = code else { return }
        if code.count == 0 {
            self.delegate?.presentCodeError(message: "לא הכנסת קוד אימות")
            return
        }
        delegate?.updateConectingLabel(text: "מתחבר")
        delegate?.presentLoader()
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code)
        AuthManager.shared.signIn(with: credential) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    if let userName = UserDefaults.standard.string(forKey: "userName") {
                        self.updateUserName(name: userName)
                    }
                case .failure(_):
                    self.delegate?.hideLoader()
                    self.delegate?.presentError(message: "בעיה בהתקשרות לשרת, אנא נסה שנית")
                }
            }
        }
    }
    
    func didTapResendCode() {
        delegate?.updateConectingLabel(text: "שולח קוד")
        delegate?.presentLoader()
        guard let phone = UserDefaults.standard.string(forKey: "phone") else { return }
        let phoneNumber = "+972\(phone)"
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationID, error in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    if let _ = error {
                        self.delegate?.hideLoader()
                        self.delegate?.presentError(message: "בעיה בהתקשרות לשרת, אנא נסה שנית")
                        return
                    }
                    if let _ = verificationID {
                        self.delegate?.hideLoader()
                    }
                }
            }
    }
    
    private func updateUserName(name: String) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.commitChanges { [weak self] error in
            guard let self = self else {return}
            DispatchQueue.main.async {
                if let _ = error {
                    self.delegate?.hideLoader()
                    self.delegate?.presentError(message: "בעיה בהתקשרות לשרת, אנא נסה שנית")
                    return
                } else {
                    if let phone = UserDefaults.standard.string(forKey: "phone") {
                        DataBaseManager.shared.saveUser(user: phone) { [weak self] result in
                            guard let self = self else {return}
                            DispatchQueue.main.async {
                                switch result {
                                case .success(_):
                                    self.delegate?.moveToMainTab()
                                    self.delegate?.hideLoader()
                                case .failure(_):
                                    self.delegate?.hideLoader()
                                    self.delegate?.presentError(message: "בעיה בהתקשרות לשרת, אנא נסה שנית")
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
