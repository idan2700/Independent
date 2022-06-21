//
//  FuTableViewCell.swift
//  Independent
//
//  Created by Idan Levi on 21/06/2022.
//

import UIKit

protocol FuTableViewCellDelegate: AnyObject {
    func updateCell()
}

class FuTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var summaryLabelView: UIStackView!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    
    private var isInfoButtonOpen: Bool = false
    weak var delegate: FuTableViewCellDelegate?
    private var viewModel: FuTableViewCellViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(with viewModel: FuTableViewCellViewModel) {
        self.viewModel = viewModel
        nameLabel.text = viewModel.name
    }

    @IBAction func didTapCall(_ sender: UIButton) {
        viewModel.didTapCall()
    }
    
    @IBAction func didTapMessage(_ sender: UIButton) {
        viewModel.didTapMessage()
    }
    
    @IBAction func didTapExpand(_ sender: UIButton) {
        isInfoButtonOpen = !isInfoButtonOpen
        configureCellExpand()
    }
    
    private func configureCellExpand() {
        summaryLabel.isHidden = !isInfoButtonOpen
        summaryLabelView.isHidden = !isInfoButtonOpen
        infoButton.setImage(!isInfoButtonOpen ? UIImage(systemName: "chevron.down") : UIImage(systemName: "chevron.up"), for: .normal)
        delegate?.updateCell()
    }
}
