//
//  IncomeTableViewCell.swift
//  Independent
//
//  Created by Idan Levi on 10/12/2021.
//

import UIKit

class IncomeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var paymentsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(with viewModel: IncomeTableViewCellViewModel) {
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
