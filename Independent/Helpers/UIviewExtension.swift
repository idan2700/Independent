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
    
    func makeRightEdgesCornred() {
        layer.cornerRadius = 10
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    }
    
    func makeLeftEdgesCornred() {
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    }
    
    func makeRoundCorners(radius: CGFloat) {
        layer.borderWidth = 1
        layer.borderColor = CGColor(gray: 0, alpha: 0)
        layer.cornerRadius = radius
        clipsToBounds = true
    }
    
    func makeRound() {
        layer.cornerRadius = bounds.size.width * 0.5
    }
    
    func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        endEditing(true)
    }
}

