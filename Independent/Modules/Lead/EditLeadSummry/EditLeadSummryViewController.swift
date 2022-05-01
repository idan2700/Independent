//
//  EditLeadSummryViewController.swift
//  Independent
//
//  Created by Idan Levi on 14/11/2021.
//

import UIKit

protocol EditLeadSummryViewControllerDelegate: AnyObject {
    func didPick(updatedLead: Lead, indexPath: IndexPath)
}

class EditLeadSummryViewController: UIViewController {
    
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var editButton: UIButton!
    
    weak var delegate: EditLeadSummryViewControllerDelegate?
    var viewModel: EditLeadSummryViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.start()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let original = editView.transform
        editView.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.3) {
            self.editView.transform = original
        }
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        viewModel.didTapCancel()
    }
    
    @IBAction func didTapEdit(_ sender: UIButton) {
        viewModel.didTapEdit(with: textView.text)
    }
    
    private func updateUI() {
        editView.makeRoundCorners(radius: 10)
        editButton.makeRoundCorners(radius: 10)
    }
}

extension EditLeadSummryViewController: EditLeadSummryViewModelDelegate {
    func returnToLeadVC(with updatedLead: Lead, indexPath: IndexPath) {
        delegate?.didPick(updatedLead: updatedLead, indexPath: indexPath)
        self.dismiss(animated: true)
    }
    
    func presentErrorAlert(message: String) {
        self.presentErrorAlert(with: message)
    }
    
    func updateTextViewText(with currentSummry: String) {
        textView.text = currentSummry
    }
    
    func returnToLeadVC() {
        self.dismiss(animated: true)
    }
}
