//
//  TabBarViewController.swift
//  Independent
//
//  Created by Idan Levi on 28/10/2021.
//

import UIKit
import SOTabBar


class TabBarViewController: SOTabBarController {

    override func loadView() {
           super.loadView()
        SOTabBarSetting.tabBarHeight = 50
        SOTabBarSetting.tabBarTintColor = UIColor.white
        SOTabBarSetting.tabBarBackground = UIColor(named: "darkblue")!
        SOTabBarSetting.tabBarCircleSize = CGSize(width: 60.0, height: 60.0)
       }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let firstVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainVC") as? MainViewController else {return}
        guard let secondVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "leadVC") as? LeadViewController else {return}
        guard let thirdVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "calenderVC") as? CalenderViewController else {return}
        guard let fourthVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "financeVC") as? FinanceViewController else {return}
        guard let fifthVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settingsVC") as? SettingsViewController else {return}
               
        firstVC.tabBarItem = UITabBarItem(title: "ראשי", image: UIImage(systemName: "house"), selectedImage: nil)
        secondVC.tabBarItem = UITabBarItem(title: "מתעניינים", image: UIImage(systemName: "questionmark"), selectedImage: nil)
        thirdVC.tabBarItem = UITabBarItem(title: "יומן", image: UIImage(systemName: "calendar"), selectedImage: nil)
        fourthVC.tabBarItem = UITabBarItem(title: "כספים", image: UIImage(systemName: "banknote"), selectedImage: nil)
        fifthVC.tabBarItem = UITabBarItem(title: "הגדרות", image: UIImage(systemName: "pencil"), selectedImage: nil)
            
                viewControllers = [firstVC, secondVC, thirdVC, fourthVC, fifthVC]
        
      
    }
}
