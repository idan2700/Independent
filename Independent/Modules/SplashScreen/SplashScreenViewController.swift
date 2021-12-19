//
//  SplashScreenViewController.swift
//  Independent
//
//  Created by Idan Levi on 21/11/2021.
//

import UIKit
import Lottie

class SplashScreenViewController: UIViewController {
    
    @IBOutlet weak var loader: AnimationView!
    var viewModel: SplashScreenViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.start()
    }
}

extension SplashScreenViewController: SplashScreenViewModelDelegate {
    func moveToTabBarVC() {
        let tabBarVC: TabBarViewController = storyBoard.instantiateViewController()
        tabBarVC.modalPresentationStyle = .overFullScreen
        self.present(tabBarVC, animated: true, completion: nil)
    }
    
    func presentErrorAlert(message: String) {
        let errorAlertVC: ErrorAlertViewController = storyBoard.instantiateViewController()
        errorAlertVC.delegate = self
        errorAlertVC.message = message
        errorAlertVC.modalPresentationStyle = .overFullScreen
        self.present(errorAlertVC, animated: true, completion: nil)
    }
    
    func changeLoaderState(isHidden: Bool) {
        if isHidden {
            viewModel.didFinishToFetchData()
        } else {
            AnimationManager.shared.makeLottieAnimation(view: loader)
        }
    }
}

extension SplashScreenViewController: ErrorAlertViewControllerDelegate {
    func didTapTryAgain() {
        viewModel.start()
    }
}
