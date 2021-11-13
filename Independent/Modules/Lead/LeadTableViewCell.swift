//
//  LeadTableViewCell.swift
//  Independent
//
//  Created by Idan Levi on 29/10/2021.
//

import UIKit
import AudioToolbox

protocol LeadTableViewCellDelegate: AnyObject {
    func didTapInfo(cell: LeadTableViewCell, isInfoButtonOpen: Bool)
    func didTapDelete(cell: LeadTableViewCell)
    func didTapWhatsapp(cell: LeadTableViewCell)
    func didTapCall(cell: LeadTableViewCell)
    func didTapMakeDeal(cell: LeadTableViewCell)
    func didTapLockLead(cell: LeadTableViewCell)
    func didTapOpenLead(cell: LeadTableViewCell)
}

class LeadTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var deleteLeadButton: UIButton!
    @IBOutlet weak var closeDealButton: UIButton!
    @IBOutlet weak var lockLeadButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var whatsappButton: UIButton!
    @IBOutlet weak var summryLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    weak var delegate: LeadTableViewCellDelegate?
    private var isInfoButtonOpen: Bool = false
  
    var viewModel: LeadTableViewCellViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView.makeRoundCorners(radius: 10)
        disappearSwipeRightButtons()
        disappearSwipeLeftButton()
        closeDealButton.makeRoundCorners(radius: 10)
        callButton.setTitle("", for: .normal)
        deleteLeadButton.setTitle("", for: .normal)
        whatsappButton.setTitle("", for: .normal)
        infoButton.setTitle("", for: .normal)
        lockLeadButton.setTitle("", for: .normal)
        closeDealButton.setTitle("סגור עסקה", for: .normal)
        let swipeRightRegongnizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeRight))
        swipeRightRegongnizer.direction = .right
        swipeRightRegongnizer.delegate = self
        cellView.addGestureRecognizer(swipeRightRegongnizer)
        let swipeLeftRegongnizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeLeft))
        swipeLeftRegongnizer.direction = .left
        swipeLeftRegongnizer.delegate = self
        cellView.addGestureRecognizer(swipeLeftRegongnizer)
        let tapRegongnizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tapRegongnizer.delegate = self
        cellView.addGestureRecognizer(tapRegongnizer)
        let longPressRegongnizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressRegongnizer.delegate = self
        statusImageView.addGestureRecognizer(longPressRegongnizer)
        statusImageView.isUserInteractionEnabled = true
    }
    
    func configure(with viewModel: LeadTableViewCellViewModel) {
        self.viewModel = viewModel
        handleCellView()
        nameLabel.text = viewModel.name
        dateLabel.text = viewModel.date
        summryLabel.text = viewModel.summry
    }
    
    @objc func handleSwipeRight() {
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
            self.cellView.frame.origin.x = self.lockLeadButton.frame.origin.x + 50
            self.presentSwipeRightButtons()
            self.disappearSwipeLeftButton()
        })
    }
    
    @objc func handleSwipeLeft() {
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
            self.cellView.frame.origin.x = -70
            self.presentSwipeLeftButton()
            self.disappearSwipeRightButtons()
        })
    }
    
    @objc func handleTap() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .beginFromCurrentState, animations: {
            self.cellView.frame.origin.x = self.closeDealButton.frame.origin.x - 10
            self.disappearSwipeRightButtons()
            self.disappearSwipeLeftButton()
        })
    }
    
    @objc func handleLongPress() {
        delegate?.didTapOpenLead(cell: self)
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
    }
    
    @IBAction func didTapCloseDeal(_ sender: UIButton) {
        handleTap()
        delegate?.didTapMakeDeal(cell: self)
    }
    
    @IBAction func didTapCall(_ sender: UIButton) {
        handleTap()
        delegate?.didTapCall(cell: self)
    }
    
    @IBAction func didTapSendWhatsapp(_ sender: UIButton) {
        handleTap()
        delegate?.didTapWhatsapp(cell: self)
    }
    
    @IBAction func didTapLockLead(_ sender: UIButton) {
        handleTap()
        delegate?.didTapLockLead(cell: self)
    }
    
    @IBAction func didTapDelete(_ sender: UIButton) {
        delegate?.didTapDelete(cell: self)
        handleTap()
    }
    
    @IBAction func didTapInfo(_ sender: UIButton) {
        isInfoButtonOpen = !isInfoButtonOpen
        delegate?.didTapInfo(cell: self, isInfoButtonOpen: self.isInfoButtonOpen)
    }
    
    func configureCellExpend(toExpand: Bool) {
        summryLabel.isHidden = toExpand
        infoButton.setImage(toExpand ? UIImage(systemName: "chevron.down") : UIImage(systemName: "chevron.up"), for: .normal)
    }
    
    private func disappearSwipeRightButtons() {
        self.callButton.alpha = 0
        self.whatsappButton.alpha = 0
        self.closeDealButton.alpha = 0
        self.lockLeadButton.alpha = 0
    }
    
    private func presentSwipeRightButtons() {
        self.callButton.alpha = 1
        self.whatsappButton.alpha = 1
        self.closeDealButton.alpha = 1
        self.lockLeadButton.alpha = 1
    }
    
    private func presentSwipeLeftButton() {
        self.deleteLeadButton.alpha = 1
    }
    
    private func disappearSwipeLeftButton() {
        self.deleteLeadButton.alpha = 0
    }
    
    private func handleCellView() {
        switch viewModel.lead.status {
        case .open:
            statusImageView.image = nil
            infoButton.tintColor = UIColor(named: "50gold")!
        case .closed:
            statusImageView.image = UIImage(systemName: "lock")
            statusImageView.tintColor = UIColor(named: "50darkred") ?? .red
            infoButton.tintColor = UIColor(named: "50darkred") ?? .red
        case .deal:
            statusImageView.image = UIImage(systemName: "checkmark")
            statusImageView.tintColor = UIColor(named: "50darkgreen") ?? .green
            infoButton.tintColor = UIColor(named: "50darkgreen") ?? .green
        }
    }
}



