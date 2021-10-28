//
//  ATCTextfield.swift
//  Independent
//
//  Created by Idan Levi on 26/10/2021.
//

import Foundation
import UIKit

class ATCTextField: UITextField, UITextFieldDelegate {
    
    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 8)
    let border = CALayer()
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    @IBInspectable open var lineColor : UIColor = UIColor.black {
        didSet{
            border.borderColor = lineColor.cgColor
        }
    }

    @IBInspectable open var selectedLineColor : UIColor = UIColor.black {
        didSet{
        }
    }


    @IBInspectable open var lineHeight : CGFloat = CGFloat(1.0) {
        didSet{
            border.frame = CGRect(x: 0, y: self.frame.size.height - lineHeight, width:  self.frame.size.width, height: self.frame.size.height)
        }
    }
    

    func setup() {
        font = UIFont(name: "ArialHebrew", size: 15)
    }
 
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        required public init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setup()
            self.delegate=self;
                    border.borderColor = lineColor.cgColor
                    self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "",
                                                                           attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            border.frame = CGRect(x: 0, y: self.frame.size.height - lineHeight, width:  self.frame.size.width, height: self.frame.size.height)
                    border.borderWidth = lineHeight
                    self.layer.addSublayer(border)
                    self.layer.masksToBounds = true
        }
    override func draw(_ rect: CGRect) {
            border.frame = CGRect(x: 0, y: self.frame.size.height - lineHeight, width:  self.frame.size.width, height: self.frame.size.height)
        }

        override func awakeFromNib() {
            super.awakeFromNib()
            border.frame = CGRect(x: 0, y: self.frame.size.height - lineHeight, width:  self.frame.size.width, height: self.frame.size.height)
            self.delegate = self
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            border.borderColor = selectedLineColor.cgColor
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            border.borderColor = lineColor.cgColor
        }
    
}

