//
//  Helpers.swift
//  Independent
//
//  Created by Idan Levi on 25/10/2021.
//

import Foundation
import UIKit

extension UIView {
    
    func makeTopRoundCorners() {
        layer.cornerRadius = 50
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    func makeButtonRound() {
        layer.borderWidth = 1
        layer.borderColor = CGColor(gray: 0, alpha: 0)
        layer.cornerRadius = 20
        clipsToBounds = true
    }
    
    func makeRound() {
        layer.cornerRadius = frame.height/2
    }
    
    func makeTextFieldRound() {
        layer.borderWidth = 1
        layer.borderColor = CGColor(gray: 0, alpha: 0)
        layer.cornerRadius = 20
        clipsToBounds = true
    }
    
    func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        endEditing(true)
    }
}

