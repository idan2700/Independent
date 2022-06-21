//
//  FuDateViewController.swift
//  Independent
//
//  Created by Idan Levi on 21/06/2022.
//

import UIKit

protocol FuDateViewControllerDelegate: AnyObject {
    func didPick(updatedLead: Lead)
}

class FuDateViewController: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var setButton: UIButton!
    
    var viewModel: FuDateViewModel!
    weak var delegate: FuDateViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.overrideUserInterfaceStyle = .dark
        datePicker.minimumDate = Date()
        mainView.makeRoundCorners(radius: 10)
        dateButton.makeRoundCorners(radius: 5)
        setButton.makeRoundCorners(radius: 10)
        dateButton.setTitle(viewModel.currentDateTitle, for: .normal)
        datePicker.addTarget(self, action: #selector(didSelectDate), for: .valueChanged)
        datePicker.setDate(viewModel.lead.fuDate ?? Date(), animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let original = mainView.transform
        mainView.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.3) {
            self.mainView.transform = original
        }
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func didTapSet(_ sender: UIButton) {
        viewModel.didTapSet()
    }
    
    @IBAction func didTapRemoveFuDate(_ sender: UIButton) {
        viewModel.didTapRemoveFuDate()
    }
    
    @objc private func didSelectDate() {
        viewModel.didSelectDate(date: datePicker.date)
    }
}

extension FuDateViewController: FuDateViewModelDelegate {
    func presentAlert(message: String) {
        self.presentErrorAlert(with: message)
    }
    
    func returnToLeadVC(with updatedLead: Lead) {
        self.dismiss(animated: true) {
            self.delegate?.didPick(updatedLead: updatedLead)
        }
    }
    
    func updateDateButtonTitle() {
        dateButton.setTitle(viewModel.selectedDateTitle, for: .normal)
    }
}
