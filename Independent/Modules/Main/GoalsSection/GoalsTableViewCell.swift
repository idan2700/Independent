//
//  GoalsTableViewCell.swift
//  Independent
//
//  Created by Idan Levi on 14/01/2022.
//

import UIKit

class GoalsTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView.makeRoundCorners(radius: 20)
        cellView.addShadow(color: UIColor(named: "50gold")!, opacity: 1, radius: 1, size: CGSize(width: -1.1, height: -1.1))
    }


}
