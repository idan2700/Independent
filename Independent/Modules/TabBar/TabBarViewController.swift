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
        SOTabBarSetting.tabBarTintColor = UIColor(named: "gold")!
        SOTabBarSetting.tabBarBackground = .black
        SOTabBarSetting.tabBarCircleSize = CGSize(width: 60.0, height: 60.0)
        SOTabBarSetting.tabBarSelectedImageColor = .black
        SOTabBarSetting.tabBarImageColor = UIColor(named: "gold")!
        SOTabBarSetting.tabBarShadowColor = UIColor(named: "10white")!.cgColor
        SOTabBarSetting.tabBarTitleColor = UIColor(named: "gold")!
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let settingsVC: SettingsViewController = storyBoard.instantiateViewController()
        let leadVC: LeadViewController = storyBoard.instantiateViewController()
        let calendarVC: CalendarViewController = storyBoard.instantiateViewController()
        let financeVC: FinanceViewController = storyBoard.instantiateViewController()
        let mainVC: MainViewController = storyBoard.instantiateViewController()
        
        settingsVC.tabBarItem = UITabBarItem(title: "הגדרות", image: UIImage(systemName: "pencil"), selectedImage: nil)
        leadVC.tabBarItem = UITabBarItem(title: "לידים", image: UIImage(systemName: "questionmark"), selectedImage: nil)
        calendarVC.tabBarItem = UITabBarItem(title: "יומן", image: UIImage(systemName: "calendar"), selectedImage: nil)
        financeVC.tabBarItem = UITabBarItem(title: "כספים", image: UIImage(systemName: "banknote"), selectedImage: nil)
        mainVC.tabBarItem = UITabBarItem(title: "ראשי", image: UIImage(systemName: "house"), selectedImage: nil)
        
        leadVC.viewModel = LeadViewModel(delegate: leadVC)
        leadVC.tabBarVC = self
        calendarVC.viewModel = CalendarViewModel(delegate: calendarVC)
        financeVC.viewModel = FinanceViewModel(delegate: financeVC)
        mainVC.viewModel = MainViewModel(delegate: mainVC)
        viewControllers = [settingsVC, leadVC, calendarVC, financeVC, mainVC]
    }
    
}



