//
//  LeadCollectionViewCell.swift
//  Independent
//
//  Created by Idan Levi on 28/10/2021.
//

import UIKit

class LeadCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var itemView: UIView!
    @IBOutlet weak var amountLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor.black.cgColor
        self.contentView.layer.cornerRadius = 10
    }
    
    func configure(with viewModel: LeadCollectionViewCellViewModel) {
        typeLabel.preferredMaxLayoutWidth = self.itemView.bounds.width
        typeLabel.text = viewModel.itemTypeLabel
        
    }
   
}
