//
//  ErrorAlertViewController.swift
//  Independent
//
//  Created by Idan Levi on 15/11/2021.
//

import UIKit

protocol ErrorAlertViewControllerDelegate: AnyObject {
    func didTapTryAgain()
}

class ErrorAlertViewController: UIViewController {
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    var message: String?
    var delegate: ErrorAlertViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorView.makeRoundCorners(radius: 10)
        tryAgainButton.makeRoundCorners(radius: 10)
        messageLabel.text = message
    }
    
    @IBAction func didTapTryAgain(_ sender: UIButton) {
        delegate?.didTapTryAgain()
        self.dismiss(animated: true)
    }
}
