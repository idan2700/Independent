//
//  LeadTableViewCell.swift
//  Independent
//
//  Created by Idan Levi on 29/10/2021.
//

import UIKit
import AudioToolbox

protocol LeadTableViewCellDelegate: AnyObject {
    func didTapInfo(cell: LeadTableViewCell, isInfoButtonOpen: Bool)
    func didTapOpenLead(cell: LeadTableViewCell)
    func didTapEditSummry(cell: LeadTableViewCell)
}

class LeadTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var summryLabel: UILabel!
    @IBOutlet weak var summaryLabelView: UIStackView!
    @IBOutlet weak var statusImageView: UIImageView!
    weak var delegate: LeadTableViewCellDelegate?
    private var isInfoButtonOpen: Bool = false
  
    var viewModel: LeadTableViewCellViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateUI()
    }
    
    
    @IBAction func didTapInfo(_ sender: UIButton) {
        isInfoButtonOpen = !isInfoButtonOpen
        delegate?.didTapInfo(cell: self, isInfoButtonOpen: self.isInfoButtonOpen)
    }
    
    func configure(with viewModel: LeadTableViewCellViewModel) {
        self.viewModel = viewModel
        handleCellView()
        nameLabel.text = viewModel.name
        dateLabel.text = viewModel.date
        let summryAttributed = NSMutableAttributedString(string: viewModel.summry)
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "pencil")
        imageAttachment.image = imageAttachment.image?.withTintColor(UIColor(named: "gold")!)
        let imageString = NSAttributedString(attachment: imageAttachment)
        summryAttributed.append(imageString)
        self.summryLabel.attributedText = summryAttributed
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTextEditTap))
        summryLabel.addGestureRecognizer(tapGesture)
        summryLabel.isUserInteractionEnabled = true
    }
    
    func configureCellExpend(toExpand: Bool) {
        summryLabel.isHidden = toExpand
        summaryLabelView.isHidden = toExpand
        infoButton.setImage(toExpand ? UIImage(systemName: "chevron.down") : UIImage(systemName: "chevron.up"), for: .normal)
    }
    
    @objc func handleTextEditTap() {
        delegate?.didTapEditSummry(cell: self)
        didTapInfo(infoButton)
    }
    
    @objc func handleLongPress() {
        delegate?.didTapOpenLead(cell: self)
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
    }
    
    private func handleCellView() {
        switch viewModel.lead.status {
        case .open:
            statusImageView.image = nil
            infoButton.backgroundColor = .systemOrange
        case .closed:
            statusImageView.image = UIImage(systemName: "lock")
            statusImageView.tintColor = UIColor(named: "ired") ?? .red
            infoButton.backgroundColor = UIColor(named: "ired") ?? .red
        case .deal:
            statusImageView.image = UIImage(systemName: "checkmark")
            statusImageView.tintColor = UIColor(named: "igreen") ?? .green
            infoButton.backgroundColor = UIColor(named: "igreen") ?? .green
        }
    }
    
    private func updateUI() {
        infoButton.setTitle("", for: .normal)
        let longPressRegongnizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressRegongnizer.delegate = self
        statusImageView.addGestureRecognizer(longPressRegongnizer)
        statusImageView.isUserInteractionEnabled = true
    }
}



