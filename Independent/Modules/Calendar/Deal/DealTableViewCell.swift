//
//  EventTableViewCell.swift
//  Independent
//
//  Created by Idan Levi on 15/11/2021.
//

import UIKit

protocol DealTableViewCellDelegate: AnyObject {
    func updateCellHeight()
    func didTapCancelDeal(cell: DealTableViewCell, phone: String)
    func didTapSendWhatsapp(cell: DealTableViewCell, phone: String)
    func didTapEdit(cell: DealTableViewCell)
    func didTapCall(cell: DealTableViewCell, phone: String)
}

class DealTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var notesButton: UIButton!
    @IBOutlet weak var notesButtonView: UIView!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var whatsappButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var cancelDealButton: UIButton!
    
    var viewModel: DealTableViewCellViewModel!
    
    weak var delegate: DealTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        notesButtonView.makeRoundCorners(radius: 10)
        cellView.makeRoundCorners(radius: 10)
        timeLabel.makeRoundCorners(radius: 10)
        cancelDealButton.makeBorder(width: 1, color: UIColor(named: "50gold")!.cgColor)
        cancelDealButton.makeRoundCorners(radius: 10)
        notesButton.setTitle("", for: .normal)
        callButton.setTitle("", for: .normal)
        whatsappButton.setTitle("", for: .normal)
        editButton.setTitle("", for: .normal)
        cancelDealButton.setTitle("ביטול עסקה", for: .normal)
        disappearSwipeRightButtons()
        disappearSwipeLeftButtons()
        let swipeLeftRegongnizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeLeft))
        swipeLeftRegongnizer.direction = .left
        swipeLeftRegongnizer.delegate = self
        cellView.addGestureRecognizer(swipeLeftRegongnizer)
        let swipeRightRegongnizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeRight))
        swipeRightRegongnizer.direction = .right
        swipeRightRegongnizer.delegate = self
        cellView.addGestureRecognizer(swipeRightRegongnizer)
        let tapRegongnizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tapRegongnizer.delegate = self
        cellView.addGestureRecognizer(tapRegongnizer)
    }
    
    @IBAction func didTapNotesButton(_ sender: UIButton) {
        viewModel.didTapNotesButton()
    }
        
    @IBAction func didTapCancelDeal(_ sender: UIButton) {
        delegate?.didTapCancelDeal(cell: self, phone: viewModel.phone)
        handleTap()
    }
    
    @IBAction func didTapCall(_ sender: UIButton) {
        delegate?.didTapCall(cell: self, phone: viewModel.phone)
        handleTap()
    }
    
    @IBAction func didTapSendWhatsapp(_ sender: UIButton) {
        delegate?.didTapSendWhatsapp(cell: self, phone: viewModel.phone)
        handleTap()
    }
    
    @IBAction func didTapEdit(_ sender: UIButton) {
        delegate?.didTapEdit(cell: self)
        handleTap()
    }
    
    func configure() {
        cancelDealButton.makeBorder(width: 1, color: UIColor(named: "50gold")!.cgColor)
        eventNameLabel.text = viewModel.eventName
        locationLabel.text = viewModel.location
        notesLabel.text = viewModel.notes
        timeLabel.text = viewModel.time
    }
    
    @objc func handleSwipeRight() {
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
            self.cellView.frame.origin.x = self.whatsappButton.frame.origin.x + 50
            self.presentSwipeRightButtons()
            self.disappearSwipeLeftButtons()
        })
    }
    
    @objc func handleSwipeLeft() {
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
            self.cellView.frame.origin.x = self.contentView.frame.origin.x - self.cancelDealButton.frame.width - 20
            self.disappearSwipeRightButtons()
            self.presentSwipeLeftButtons()
        })
    }
    
    @objc func handleTap() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .beginFromCurrentState, animations: {
            self.cellView.frame.origin.x = 0
            self.disappearSwipeRightButtons()
            self.disappearSwipeLeftButtons()
        })
    }
    
    private func disappearSwipeRightButtons() {
        self.callButton.alpha = 0
        self.whatsappButton.alpha = 0
        self.editButton.alpha = 0
    }
    
    private func presentSwipeRightButtons() {
        self.callButton.alpha = 1
        self.whatsappButton.alpha = 1
        self.editButton.alpha = 1
    }
    
    private func disappearSwipeLeftButtons() {
        self.cancelDealButton.alpha = 0
    }
    
    private func presentSwipeLeftButtons() {
        self.cancelDealButton.alpha = 1
    }
}

extension DealTableViewCell: DealTableViewCellViewModelDelegate {
    func changeNotesLabelVisability(toPresent: Bool) {
        notesLabel.isHidden = !toPresent
        delegate?.updateCellHeight()
        notesButton.setImage(toPresent ? UIImage(systemName: "chevron.up") : UIImage(systemName: "chevron.down"), for: .normal)
    }
}
