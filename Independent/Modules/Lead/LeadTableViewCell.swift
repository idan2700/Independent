//
//  LeadTableViewCell.swift
//  Independent
//
//  Created by Idan Levi on 29/10/2021.
//

import UIKit

class LeadTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var deleteLeadButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var whatsappButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        callButton.alpha = 0
        deleteLeadButton.alpha = 0
        whatsappButton.alpha = 0
        callButton.makeRoundCorners(radius: 20)
        deleteLeadButton.makeRoundCorners(radius: 20)
        whatsappButton.makeRoundCorners(radius: 20)
        callButton.setTitle("", for: .normal)
        deleteLeadButton.setTitle("", for: .normal)
        whatsappButton.setTitle("", for: .normal)
        infoButton.setTitle("", for: .normal)
        callButton.tintColor = UIColor(named: "myblue") ?? .blue
        whatsappButton.tintColor = UIColor(named: "darkgreen") ?? .systemGreen
        deleteLeadButton.tintColor = UIColor(named: "darkred") ?? .systemRed
        let swipeRegongnizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeRight))
        swipeRegongnizer.direction = .right
        swipeRegongnizer.delegate = self
        cellView.addGestureRecognizer(swipeRegongnizer)
        let tapRegongnizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tapRegongnizer.delegate = self
        cellView.addGestureRecognizer(tapRegongnizer)
    }
    
    func configure(with viewModel: LeadTableViewCellViewModel) {
        nameLabel.text = viewModel.nameLabel
        dateLabel.text = viewModel.dateLabel
    }
    
    @objc func handleSwipeRight() {
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
            self.cellView.frame.origin.x = self.deleteLeadButton.frame.origin.x + 50
            self.callButton.alpha = 1
            self.deleteLeadButton.alpha = 1
            self.whatsappButton.alpha = 1
        })
    }
    
    @objc func handleTap() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .beginFromCurrentState, animations: {
            self.cellView.frame.origin.x = self.callButton.frame.origin.x - 10
            self.callButton.alpha = 0
            self.deleteLeadButton.alpha = 0
            self.whatsappButton.alpha = 0
        })
    }
}


