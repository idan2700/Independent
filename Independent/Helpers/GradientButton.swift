////
////  GradientButton.swift
////  Independent
////
////  Created by Idan Levi on 25/10/2021.
////
//
//import Foundation
//import UIKit
//
//@IBDesignable
//class GradientButton: UIButton {
//    let gradientLayer = CAGradientLayer()
//
//    @IBInspectable
//    var topGradientColor: UIColor? {
//        didSet {
//            setGradient(topGradientColor: topGradientColor, bottomGradientColor: bottomGradientColor)
//        }
//    }
//
//    @IBInspectable
//    var bottomGradientColor: UIColor? {
//        didSet {
//            setGradient(topGradientColor: topGradientColor, bottomGradientColor: bottomGradientColor)
//        }
//    }
//
//    @IBInspectable
//    var isHorizontal: Bool = true {
//       didSet {
//          updateDirection()
//       }
//    }
//
//
//    private func setGradient(topGradientColor: UIColor?, bottomGradientColor: UIColor?) {
//        if let topGradientColor = topGradientColor, let bottomGradientColor = bottomGradientColor {
//            gradientLayer.frame = bounds
//            gradientLayer.colors = [topGradientColor.cgColor, bottomGradientColor.cgColor]
//            gradientLayer.borderColor = layer.borderColor
//            gradientLayer.borderWidth = layer.borderWidth
//            gradientLayer.cornerRadius = layer.cornerRadius
//            layer.insertSublayer(gradientLayer, at: 0)
//        } else {
//            gradientLayer.removeFromSuperlayer()
//        }
//    }
//
//    private func updateDirection() {
//        if (self.isHorizontal) {
//            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
//            gradientLayer.endPoint = CGPoint (x: 1, y: 0.5)
//        } else {
//            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
//            gradientLayer.endPoint = CGPoint (x: 0.5, y: 1)
//        }
//    }
//}
