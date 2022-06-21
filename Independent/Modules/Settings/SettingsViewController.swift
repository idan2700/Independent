//
//  SettingsViewController.swift
//  Independent
//
//  Created by Idan Levi on 28/10/2021.
//

import UIKit
import FSCalendar

class SettingsViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
    }

    @IBAction func tap(_ sender: Any) {
        let createDealVC: CreateEventViewController = storyBoard.instantiateViewController()
        createDealVC.viewModel = CreateEventViewModel(delegate: createDealVC, isLaunchedFromLead: true, isNewEvent: true, currentDate: Date(), eventType: .deal)
//        createDealVC.viewModel.name = lead.fullName
//        createDealVC.viewModel.phone = lead.phoneNumber
        createDealVC.modalPresentationStyle = .overFullScreen
        self.present(createDealVC, animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
