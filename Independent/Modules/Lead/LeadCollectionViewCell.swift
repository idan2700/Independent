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
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    
    }
    
    func configure(with viewModel: LeadCollectionViewCellViewModel) {
        itemView.makeRoundCorners(radius: 20)
        typeLabel.preferredMaxLayoutWidth = self.itemView.bounds.width
        typeLabel.text = viewModel.itemTypeLabel    }
   
}
