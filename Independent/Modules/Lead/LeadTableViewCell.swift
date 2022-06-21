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
    func didTapFu(cell: LeadTableViewCell)
}

class LeadTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var summryLabel: UILabel!
    @IBOutlet weak var summaryLabelView: UIStackView!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var fuStackView: UIStackView!
    @IBOutlet weak var fuButton: UIButton!
    
    weak var delegate: LeadTableViewCellDelegate?
    private var isInfoButtonOpen: Bool = false
  
    var viewModel: LeadTableViewCellViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateUI()
    }
    
    @IBAction func didTapFu(_ sender: UIButton) {
        delegate?.didTapFu(cell: self)
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
        let space = NSMutableAttributedString(string: "  ")
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "pencil")
        imageAttachment.image = imageAttachment.image?.withTintColor(.gold)
        let imageString = NSAttributedString(attachment: imageAttachment)
        summryAttributed.append(space)
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
            fuStackView.isHidden = false
            fuButton.tintColor = viewModel.lead.fuDate != nil ? .systemPink : .veryDarkGray
        case .closed:
            statusImageView.image = UIImage(systemName: "lock")
            statusImageView.tintColor = .iRed
            infoButton.backgroundColor = .iRed
            fuStackView.isHidden = true
        case .deal:
            statusImageView.image = UIImage(systemName: "checkmark")
            statusImageView.tintColor = .iGreen
            infoButton.backgroundColor = .iGreen
            fuStackView.isHidden = true
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



