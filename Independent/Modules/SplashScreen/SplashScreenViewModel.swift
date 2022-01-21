//
//  SplashScreenViewModel.swift
//  Independent
//
//  Created by Idan Levi on 21/11/2021.
//

import Foundation
import Firebase

protocol SplashScreenViewModelDelegate: AnyObject {
    func changeLoaderState(isHidden: Bool)
    func presentErrorAlert(message: String)
    func moveToTabBarVC()
}

class SplashScreenViewModel {
    
    weak var delegate: SplashScreenViewModelDelegate?
    
    init(delegate: SplashScreenViewModelDelegate) {
        self.delegate = delegate
    }
    
    func start() {
        delegate?.changeLoaderState(isHidden: false)
        loadEvents()
    }
    
    func didFinishToFetchData() {
        delegate?.moveToTabBarVC()
    }
    
    private func loadEvents() {
        EventsManager.shared.loadEventsFromStore {
            fetchDeals()
        }
    }
    
    private func fetchDeals() {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        EventsManager.shared.loadDeals(userId: userId) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success():
                        self.fetchMissions()
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "נוצרה בעיה בטעינה מול השרת, אנא נסה שנית")
                }
            }
        }
    }
    
    private func fetchMissions() {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        EventsManager.shared.loadMissions(userId: userId) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success():
                    EventsManager.shared.appendEventsToAllEvents()
                    self.fetchLeads()
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "נוצרה בעיה בטעינה מול השרת, אנא נסה שנית")
                }
            }
        }
    }
    
    private func fetchLeads() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        LeadManager.shared.loadLeadCollection(userId: currentUserID) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.fetchIncomes()
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "נוצרה בעיה בטעינה מול השרת, אנא נסה שנית")
                }
            }
        }
    }
    
    private func fetchIncomes() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        FinanceManager.shared.loadIncomes(userId: currentUserID) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.fetchOutcomes()
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "נוצרה בעיה בטעינה מול השרת, אנא נסה שנית")
                }
            }
        }
    }
    
    private func fetchOutcomes() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        FinanceManager.shared.loadOutcomes(userId: currentUserID) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.delegate?.changeLoaderState(isHidden: true)
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "נוצרה בעיה בטעינה מול השרת, אנא נסה שנית")
                }
            }
        }
    }
}
