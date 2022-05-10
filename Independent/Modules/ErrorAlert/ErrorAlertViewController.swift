//
//  ErrorAlertViewController.swift
//  Independent
//
//  Created by Idan Levi on 15/11/2021.
//

import UIKit

class ErrorAlertViewController: UIViewController {
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    var message: String?
    var buttonAction: (()->())?
    var buttonTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorView.makeRoundCorners(radius: 10)
        actionButton.makeRoundCorners(radius: 10)
        messageLabel.text = message
        self.actionButton.setTitle(buttonTitle ?? "נסה שנית", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let original = errorView.transform
        errorView.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.3) {
            self.errorView.transform = original
        }
    }
    
    @IBAction func didTapAction(_ sender: UIButton) {
        buttonAction?()
        self.dismiss(animated: true)
    }
}
