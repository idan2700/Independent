//
//  AnimationManager.swift
//  Independent
//
//  Created by Idan Levi on 28/10/2021.
//

import Foundation
import Lottie
import UIKit

class AnimationManager {
    
    static let shared = AnimationManager()
    
    private init() {}
    
    func makeLottieAnimation(view: AnimationView) {
        view.contentMode = .scaleToFill
        view.loopMode = .loop
        view.animationSpeed = 1.0
        view.play()
    }
}
