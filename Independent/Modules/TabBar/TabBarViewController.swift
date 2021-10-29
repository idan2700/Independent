//
//  TabBarViewController.swift
//  Independent
//
//  Created by Idan Levi on 28/10/2021.
//

import UIKit
import Lottie

class TabBarViewController: SOTabBarController {
    
    override func loadView() {
           super.loadView()
        SOTabBarSetting.tabBarHeight = 50
        SOTabBarSetting.tabBarTintColor = UIColor.white
        SOTabBarSetting.tabBarBackground = UIColor(named: "darkblue") ?? .systemBlue
        SOTabBarSetting.tabBarCircleSize = CGSize(width: 60.0, height: 60.0)
        SOTabBarSetting.tabBarSelectedImageColor = UIColor(named: "darkblue") ?? .systemBlue
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
       }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let settingsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settingsVC") as? SettingsViewController else {return}
        guard let leadVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "leadVC") as? LeadViewController else {return}
        guard let calendarVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "calenderVC") as? CalenderViewController else {return}
        guard let financeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "financeVC") as? FinanceViewController else {return}
        guard let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainVC") as? MainViewController else {return}
        
        settingsVC.tabBarItem = UITabBarItem(title: "הגדרות", image: UIImage(systemName: "pencil"), selectedImage: nil)
        leadVC.tabBarItem = UITabBarItem(title: "מתעניינים", image: UIImage(systemName: "questionmark"), selectedImage: nil)
        calendarVC.tabBarItem = UITabBarItem(title: "יומן", image: UIImage(systemName: "calendar"), selectedImage: nil)
        financeVC.tabBarItem = UITabBarItem(title: "כספים", image: UIImage(systemName: "banknote"), selectedImage: nil)
        mainVC.tabBarItem = UITabBarItem(title: "ראשי", image: UIImage(systemName: "house"), selectedImage: nil)
        
        leadVC.viewModel = LeadViewModel(delegate: leadVC)
        viewControllers = [settingsVC, leadVC, calendarVC, financeVC, mainVC]
    }
}


