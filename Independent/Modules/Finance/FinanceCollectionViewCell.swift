//
//  FinanceCollectionViewCell.swift
//  Independent
//
//  Created by Idan Levi on 10/12/2021.
//

import UIKit

class FinanceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var itemView: UIView!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor.black.cgColor
        self.contentView.layer.cornerRadius = 10
    }
    
    func configure(with viewModel: FinanceCollectionViewCellViewModel) {
        itemLabel.preferredMaxLayoutWidth = self.itemView.bounds.width
        itemLabel.text = viewModel.itemLabel
        amountLabel.text = viewModel.amount
        amountLabel.textColor = viewModel.amountLabelColor
    }
    
}
