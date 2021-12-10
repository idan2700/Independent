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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        amountLabel.makeBorder(width: 1, color: UIColor(named: "darkgreen")!.cgColor)
        amountLabel.makeRound()
    }

    func configure(with viewModel: IncomeTableViewCellViewModel) {
        amountLabel.text = viewModel.amount
        nameLabel.text = viewModel.name
        dateLabel.text = viewModel.date
    }
}
