//
//  IncomeTableViewCell.swift
//  Independent
//
//  Created by Idan Levi on 10/12/2021.
//

import UIKit

protocol IncomeTableViewCellDelegate: AnyObject {
    func didTapDelete(cell: IncomeTableViewCell)
    func didTapEdit(cell: IncomeTableViewCell)
}

class IncomeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    weak var delegate: IncomeTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        amountLabel.makeBorder(width: 1, color: UIColor(named: "darkgreen")!.cgColor)
        amountLabel.makeRound()
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

    func configure(with viewModel: IncomeTableViewCellViewModel) {
        amountLabel.text = viewModel.amount
        nameLabel.text = viewModel.name
        dateLabel.text = viewModel.date
    }
    
    @IBAction func didTapDelete(_ sender: UIButton) {
        delegate?.didTapDelete(cell: self)
        handleTap()
    }
    
    @IBAction func didTapEdit(_ sender: UIButton) {
        delegate?.didTapEdit(cell: self)
        handleTap()
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
