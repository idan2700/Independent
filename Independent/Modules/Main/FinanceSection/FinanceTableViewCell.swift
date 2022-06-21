//
//  MainTableViewCell.swift
//  Independent
//
//  Created by Idan Levi on 07/01/2022.
//

import UIKit

class FinanceTableViewCell: UITableViewCell {

    var viewModel: FinanceTableViewCellViewModel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var incomesView: UIView!
    @IBOutlet weak var outcomesView: UIView!
    @IBOutlet weak var profitView: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView.makeRoundCorners(radius: 20)
        cellView.addShadow(color: UIColor(named: "50gold")!, opacity: 1, radius: 1, size: CGSize(width: -1.1, height: -1.1))
        incomesView.makeRoundCorners(radius: 10)
        outcomesView.makeRoundCorners(radius: 10)
        profitView.makeRoundCorners(radius: 10)
    }

}
