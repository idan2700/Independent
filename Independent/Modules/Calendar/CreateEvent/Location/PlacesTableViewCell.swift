//
//  PlacesTableViewCell.swift
//  Independent
//
//  Created by Idan Levi on 17/11/2021.
//

import UIKit

class PlacesTableViewCell: UITableViewCell {
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var adressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with viewModel: PlacesTableViewCellViewModel) {
        placeLabel.text = viewModel.place
        adressLabel.text = viewModel.address
    }


}
