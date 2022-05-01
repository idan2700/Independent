//
//  OutcomeTableViewCell.swift
//  Independent
//
//  Created by Idan Levi on 31/12/2021.
//

import UIKit

class OutcomeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var paymentsLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with viewModel: OutcomeTableViewCellViewModel) {
        amountLabel.text = viewModel.amount
        nameLabel.text = viewModel.name
        dateLabel.text = viewModel.date
        if viewModel.payments != nil {
            paymentsLabel.text = viewModel.payments
            paymentsLabel.isHidden = false
        } else {
            paymentsLabel.isHidden = true
        }
    }
}
