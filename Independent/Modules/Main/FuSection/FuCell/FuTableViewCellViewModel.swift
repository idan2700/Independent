//
//  FuTableViewCellViewModel.swift
//  Independent
//
//  Created by Idan Levi on 21/06/2022.
//

import Foundation
import UIKit

protocol FuTableViewCellViewModelDelegate: AnyObject {
    func presentAlert(message: String)
}

class FuTableViewCellViewModel {
    
    private var lead: Lead
    weak var delegate: FuTableViewCellViewModelDelegate?
    
    init(lead: Lead, delegate: FuTableViewCellViewModelDelegate?) {
        self.lead = lead
        self.delegate = delegate
    }
    
    var name: String {
        return lead.fullName
    }
    
    func didTapCall() {
        guard let phoneCallURL = URL(string: "tel://\(lead.phoneNumber)") else { return }
        if UIApplication.shared.canOpenURL(phoneCallURL) {
            UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
        }
    }
    
    func didTapMessage() {
        guard let url  = URL(string: "https://wa.me/972\(lead.phoneNumber)") else {return}
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url as URL, options: [:]) { (success) in
                       if success {
                           print("WhatsApp accessed successfully")
                       } else {
                           self.delegate?.presentAlert(message: "אני לא מוצא את הווטסאפ, בטוח שהוא מותקן על המכשיר?")
                       }
                   }
           }
    }
}
