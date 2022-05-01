//
//  ContextualActions.swift
//  Independent
//
//  Created by Idan Levi on 21/01/2022.
//

import Foundation
import UIKit

extension UIViewController {
    func createTableViewAction(title: String, image: UIImage?, function: @escaping ()-> Void = {})-> UIContextualAction {
        let newAction = UIContextualAction(style: .normal, title: title) { (action, view, completion) in
            function()
            completion(true)
        }
        newAction.backgroundColor = UIColor(named: "5white")!
        if let image = image {
            newAction.image = image.colored(in: UIColor(named: "gold")!)
        }
        return newAction
    }
}



