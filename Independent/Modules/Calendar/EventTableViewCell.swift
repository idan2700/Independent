//
//  EventTableViewCell.swift
//  Independent
//
//  Created by Idan Levi on 15/11/2021.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eventNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with viewModel: EventTableViewCellViewModel) {
        eventNameLabel.text = viewModel.eventName
    }
}
