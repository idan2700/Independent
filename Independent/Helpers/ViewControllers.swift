//
//  ViewControllers.swift
//  Independent
//
//  Created by Idan Levi on 15/11/2021.
//

import Foundation

import UIKit

protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}

extension UIViewController: StoryboardIdentifiable {
    public var storyBoard: UIStoryboard {
            return UIStoryboard(name: "Main", bundle: nil)
        }
    
    public func presentErrorAlert(with message: String) {
        let errorAlertVC: ErrorAlertViewController = storyBoard.instantiateViewController()
        errorAlertVC.message = message
        errorAlertVC.modalPresentationStyle = .overFullScreen
        self.present(errorAlertVC, animated: true, completion: nil)
    }
}

extension UIStoryboard {
    
    func instantiateViewController<T: UIViewController>() -> T where T: StoryboardIdentifiable {
            guard let viewController = self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
                fatalError("Couldn't instantiate view controller with identifier \(T.storyboardIdentifier) ")
            }
            return viewController
        }
}
