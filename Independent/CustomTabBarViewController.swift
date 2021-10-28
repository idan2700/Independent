//
//  CustomTabBarViewController.swift
//  Independent
//
//  Created by Idan Levi on 28/10/2021.
//

import UIKit
import SOTabBar

class CustomTabBarViewController: SOTabBarController {
    
    override func loadView() {
           super.loadView()
        SOTabBarSetting.tabBarHeight = 80
        SOTabBarSetting.tabBarTintColor = UIColor.white
        SOTabBarSetting.tabBarBackground = UIColor.purple
        SOTabBarSetting.tabBarCircleSize = CGSize(width: 50.0, height: 50.0)

       }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let firstVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainVC") as? MainViewController else {return}
        guard let secondVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "leadVC") as? LeadViewController else {return}
               
        firstVC.tabBarItem = UITabBarItem(title: "Home", image: nil, selectedImage: nil)
                secondVC.tabBarItem = UITabBarItem(title: "lead", image: nil, selectedImage: nil)
            
                viewControllers = [firstVC, secondVC]
    }
    
}
