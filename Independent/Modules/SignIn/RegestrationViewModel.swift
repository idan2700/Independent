//
//  SignInViewModel.swift
//  Independent
//
//  Created by Idan Levi on 25/10/2021.
//

import Foundation
import FirebaseAuth
import Combine

protocol RegestrationViewModelDelegate: AnyObject {
   func moveToVerficationVC()
    func changeToLoginScreen()
    func changeToSignInScreen()
    func hideNameTextField()
    func showNameTextField()
    func textFieldEndEditing()
    func presentNameError(message: String)
    func presentPhoneError(message: String)
    func hideNameError()
    func hidePhoneError()
    func presentError(message: String)
    func hideError()
    func presentLoader()
    func hideLoader()
    func presentStartAnimation()
    func presentMainLoader()
}

class RegestrationViewModel {
    
    weak var delegate: RegestrationViewModelDelegate?
    
    private var allUsers: [String] = []
    private var isUserRegisteredBefore: Bool = true
    private var isNameVerifyd: Bool = false
    private var isPhoneVerifyd: Bool = false
    private var isLoading: Bool = false
//        didSet {
//            if self.isLoading {
//                return
//            } else {
//                delegate?.hideLoader()
//            }
//        }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(delegate: RegestrationViewModelDelegate?) {
        self.delegate = delegate
    }
    
    func start() {
        bind()
    }
    
    func validateName(name: String?) {
        delegate?.hideError()
        if let name = name {
            if name.count == 0 {
                self.delegate?.presentNameError(message: "לא הכנסת שם")
                return
            }
            if name.contains("^[a-zA-Z-]+ ?.* [a-zA-Z-]+$") {
                self.delegate?.presentNameError(message: "שם אינו יכול להכיל תווים מיוחדים, יש להשתמש באותיות בלבד")
                return
            }
            if name.count > 20 {
                self.delegate?.presentNameError(message: "שם יכול להכיל עד 20 תווים")
                return
            }
        }
        self.delegate?.hideNameError()
        self.isNameVerifyd = true
    }
    
    func validatePhone(phone: String?) {
        delegate?.hideError()
        if let phone = phone {
            if phone.count == 0 {
                self.delegate?.presentPhoneError(message: "לא הכנסת מספר טלפון")
                return
            }
            if phone.count != 10 {
                self.delegate?.presentPhoneError(message: "טלפון צריך להיות בעל 10 ספרות")
                return
            }
            if phone.count == 10 {
                self.delegate?.textFieldEndEditing()
            }
        }
        self.delegate?.hidePhoneError()
        self.isPhoneVerifyd = true
    }
    
    
    func didTapSendVerifaction(phone: String?, name: String?) {
        delegate?.hideError()
        guard let name = name, let phone = phone else { return }
        switch isUserRegisteredBefore {
        case true:
            if name.count == 0 {
                self.delegate?.presentNameError(message: "לא הכנסת שם")
            }
            if phone.count == 0 {
                self.delegate?.presentPhoneError(message: "לא הכנסת טלפון")
            }
            if allUsers.contains(phone) {
                self.delegate?.presentError(message: "המשתמש קיים במערכת עבור למסך הכניסה למערכת")
                return
            }
        case false:
            if !allUsers.contains(phone) {
                self.delegate?.presentError(message: "המשתמש לא קיים במערכת, עבור למסך ההרשמה")
                return
            }
        }
        delegate?.presentLoader()
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
                    if let verficationId = verificationID {
                        UserDefaults.standard.set(verficationId, forKey: "authVerificationID")
                        UserDefaults.standard.set(name, forKey: "userName")
                        UserDefaults.standard.set(phone, forKey: "phone")
                        self.delegate?.moveToVerficationVC()
                        self.delegate?.hideLoader()
                    }
                }
            }
        
    }
    
    func didTapLogin() {
        if isUserRegisteredBefore {
            delegate?.hideError()
            delegate?.hideNameTextField()
            delegate?.changeToLoginScreen()
            isUserRegisteredBefore = false
        } else {
            delegate?.hideError()
            delegate?.showNameTextField()
            delegate?.changeToSignInScreen()
            isUserRegisteredBefore = true
        }
    }
    
    func bind() {
        DataBaseManager.shared.$allUsers
            .sink { [weak self] users in
                self?.allUsers = users
            }
            .store(in: &cancellables)
        
        DataBaseManager.shared.$isLoading
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.delegate?.presentMainLoader()
                } else {
                    self?.delegate?.presentStartAnimation()
                }
            }
            .store(in: &cancellables)
    }
    
    func didFinishStartAnimation() {
   
    }
}





