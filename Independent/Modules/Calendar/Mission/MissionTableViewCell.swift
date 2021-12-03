//
//  MissionTableViewCell.swift
//  Independent
//
//  Created by Idan Levi on 22/11/2021.
//

import UIKit

protocol MissionTableViewCellDelegate: AnyObject {
    func didTapDelete(cell: MissionTableViewCell)
    func didTapEdit(cell: MissionTableViewCell)
    func updateCell()
}

class MissionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var notesButton: UIButton!
    @IBOutlet weak var notesButtonView: UIView!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var viewModel: MissionTableViewCellViewModel!
    
    weak var delegate: MissionTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        notesButtonView.makeRoundCorners(radius: 10)
        cellView.makeRoundCorners(radius: 10)
        timeLabel.makeRoundCorners(radius: 10)
        notesButton.setTitle("", for: .normal)
        deleteButton.setTitle("", for: .normal)
        editButton.setTitle("", for: .normal)
        deleteButton.alpha = 0
        editButton.alpha = 0
        let swipeRightRegongnizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeRight))
        swipeRightRegongnizer.direction = .right
        swipeRightRegongnizer.delegate = self
        cellView.addGestureRecognizer(swipeRightRegongnizer)
        let swipeLeftRegongnizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeLeft))
        swipeLeftRegongnizer.direction = .left
        swipeLeftRegongnizer.delegate = self
        cellView.addGestureRecognizer(swipeLeftRegongnizer)
        let tapRegongnizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tapRegongnizer.delegate = self
        cellView.addGestureRecognizer(tapRegongnizer)
    }
    
    @IBAction func didTapNotesButton(_ sender: UIButton) {
        viewModel.didTapNotesButton()
    }
    
    @IBAction func didTapDelete(_ sender: UIButton) {
        delegate?.didTapDelete(cell: self)
        handleTap()
    }
    
    @IBAction func didTapEdit(_ sender: UIButton) {
        delegate?.didTapEdit(cell: self)
        handleTap()
    }
    
    func configure() {
        eventNameLabel.text = viewModel.eventName
        locationLabel.text = viewModel.location
        notesLabel.text = viewModel.notes
        timeLabel.text = viewModel.time
    }
    
    @objc func handleSwipeLeft() {
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
            self.cellView.frame.origin.x = -70
            self.deleteButton.alpha = 1
            self.editButton.alpha = 0
        })
    }
    
    @objc func handleSwipeRight() {
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
            self.cellView.frame.origin.x = self.editButton.frame.maxX + 10
            self.deleteButton.alpha = 0
            self.editButton.alpha = 1
        })
    }
    
    @objc func handleTap() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .beginFromCurrentState, animations: {
            self.cellView.frame.origin.x = 0
            self.deleteButton.alpha = 0
            self.editButton.alpha = 0
        })
    }
}

extension MissionTableViewCell: MissionTableViewCellViewModelDelegate {
    func changeNotesLabelVisability(toPresent: Bool) {
        notesLabel.isHidden = !toPresent
        delegate?.updateCell()
        notesButton.setImage(toPresent ? UIImage(systemName: "chevron.up") : UIImage(systemName: "chevron.down"), for: .normal)
    }
}
