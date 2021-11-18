//
//  EventTableViewCell.swift
//  Independent
//
//  Created by Idan Levi on 15/11/2021.
//

import UIKit

protocol DealTableViewCellDelegate: AnyObject {
    func updateCellHeight()
}

class DealTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var notesButton: UIButton!
    @IBOutlet weak var notesButtonView: UIView!
    @IBOutlet weak var notesLabel: UILabel!
 
    
    var viewModel: DealTableViewCellViewModel!
  
    weak var delegate: DealTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        notesButtonView.makeRoundCorners(radius: 10)
        cellView.makeRoundCorners(radius: 10)
        timeLabel.makeRoundCorners(radius: 10)
        notesButton.setTitle("", for: .normal)
    }
    
    @IBAction func didTapNotesButton(_ sender: UIButton) {
        viewModel.didTapNotesButton()
    }
    
    func configure() {
        eventNameLabel.text = viewModel.eventName
        locationLabel.text = viewModel.location
        notesLabel.text = viewModel.notes
        timeLabel.text = viewModel.time
    }
}

extension DealTableViewCell: DealTableViewCellViewModelDelegate {
    func changeNotesLabelVisability(toPresent: Bool) {
        notesLabel.isHidden = !toPresent
        delegate?.updateCellHeight()
        notesButton.setImage(toPresent ? UIImage(systemName: "chevron.up") : UIImage(systemName: "chevron.down"), for: .normal)
    }
}
