//
//  ReminderTableViewCell.swift
//  Independent
//
//  Created by Idan Levi on 03/12/2021.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var cellSpace: NSLayoutConstraint!
    @IBOutlet weak var spaceView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with viewModel: ReminderTableViewCellViewModel) {
        timeLabel.text = viewModel.reminderTitle
        cellSpace.constant = CGFloat(viewModel.cellSpace)
        spaceView.backgroundColor = viewModel.cellSpaceColor
    }
}
