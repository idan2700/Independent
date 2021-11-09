//
//  LeadTableViewCell.swift
//  Independent
//
//  Created by Idan Levi on 29/10/2021.
//

import UIKit

protocol LeadTableViewCellDelegate: AnyObject {
    func didTapInfo(cell: LeadTableViewCell, isInfoButtonOpen: Bool)
    func didTapDelete(cell: LeadTableViewCell)
    func didTapWhatsapp(cell: LeadTableViewCell)
    func didTapCall(cell: LeadTableViewCell)
}

class LeadTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var deleteLeadButton: UIButton!
    @IBOutlet weak var closeDealButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var whatsappButton: UIButton!
    @IBOutlet weak var summryLabel: UILabel!
    weak var delegate: LeadTableViewCellDelegate?
    private var isInfoButtonOpen: Bool = false
  
    var viewModel: LeadTableViewCellViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        cellView.makeRoundCorners(radius: 10)
        callButton.alpha = 0
        deleteLeadButton.alpha = 0
        whatsappButton.alpha = 0
        closeDealButton.alpha = 0
        callButton.makeRoundCorners(radius: 20)
        deleteLeadButton.makeRoundCorners(radius: 20)
        whatsappButton.makeRoundCorners(radius: 20)
        closeDealButton.makeRoundCorners(radius: 10)
        callButton.setTitle("", for: .normal)
        deleteLeadButton.setTitle("", for: .normal)
        whatsappButton.setTitle("", for: .normal)
        infoButton.setTitle("", for: .normal)
        closeDealButton.setTitle("סגור עסקה", for: .normal)
        let swipeRegongnizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeRight))
        swipeRegongnizer.direction = .right
        swipeRegongnizer.delegate = self
        cellView.addGestureRecognizer(swipeRegongnizer)
        let tapRegongnizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tapRegongnizer.delegate = self
        cellView.addGestureRecognizer(tapRegongnizer)
    }
    
    func configure(with viewModel: LeadTableViewCellViewModel) {
        self.viewModel = viewModel
        nameLabel.text = viewModel.name
        dateLabel.text = viewModel.date
        summryLabel.text = viewModel.summry
    }
    
    @objc func handleSwipeRight() {
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
            self.cellView.frame.origin.x = self.deleteLeadButton.frame.origin.x + 50
            self.presentButtons()
        })
    }
    
    @objc func handleTap() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .beginFromCurrentState, animations: {
            self.cellView.frame.origin.x = self.closeDealButton.frame.origin.x - 10
            self.disappearButtons()
        })
    }
    
    @IBAction func didTapCloseDeal(_ sender: UIButton) {
        print("close deal")
    }
    
    @IBAction func didTapCall(_ sender: UIButton) {
        handleTap()
        delegate?.didTapCall(cell: self)
    }
    
    @IBAction func didTapSendWhatsapp(_ sender: UIButton) {
        handleTap()
        delegate?.didTapWhatsapp(cell: self)
    }
    
    @IBAction func didTapDelete(_ sender: UIButton) {
        delegate?.didTapDelete(cell: self)
    }
    
    @IBAction func didTapInfo(_ sender: UIButton) {
        isInfoButtonOpen = !isInfoButtonOpen
        delegate?.didTapInfo(cell: self, isInfoButtonOpen: self.isInfoButtonOpen)
    }
    
    func configureCellExpend(toExpand: Bool) {
        summryLabel.isHidden = toExpand
        infoButton.setImage(toExpand ? UIImage(systemName: "chevron.down") : UIImage(systemName: "chevron.up"), for: .normal)
    }
    
    private func disappearButtons() {
        self.callButton.alpha = 0
        self.deleteLeadButton.alpha = 0
        self.whatsappButton.alpha = 0
        self.closeDealButton.alpha = 0
    }
    
    private func presentButtons() {
        self.callButton.alpha = 1
        self.deleteLeadButton.alpha = 1
        self.whatsappButton.alpha = 1
        self.closeDealButton.alpha = 1
    }
}


