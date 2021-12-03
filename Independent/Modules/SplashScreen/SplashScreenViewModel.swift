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
    func moveToTabBarVC(leads: [Lead], deals: [Deal], missions: [Mission])
}

class SplashScreenViewModel {
    
    private var leadsManager: LeadManager
    private var eventsManager: EventsManager
    private var deals = [Deal]()
    private var missions = [Mission]()
    
    weak var delegate: SplashScreenViewModelDelegate?
    var allLeads = [Lead]()

    
    init(leadsManager: LeadManager, eventsManager: EventsManager, delegate: SplashScreenViewModelDelegate) {
        self.leadsManager = leadsManager
        self.eventsManager = eventsManager
        self.delegate = delegate
    }
    
    func start() {
        delegate?.changeLoaderState(isHidden: false)
        loadEvents()
    }
    
    func didFinishToFetchData() {
        delegate?.moveToTabBarVC(leads: allLeads, deals: deals, missions: missions)
    }
    
    private func loadEvents() {
        eventsManager.loadEventsFromStore {
            fetchDeals()
        }
    }
    
    private func fetchDeals() {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        eventsManager.loadDeals(userId: userId) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let deals):
                    self.deals = deals
                    self.fetchMissions()
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "נוצרה בעיה בטעינה מול השרת, אנא נסה שנית")
                }
            }
        }
    }
    
    private func fetchMissions() {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        eventsManager.loadMissions(userId: userId) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let missions):
                    self.missions = missions
                    self.fetchLeads()
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "נוצרה בעיה בטעינה מול השרת, אנא נסה שנית")
                }
            }
        }
    }
    
    private func fetchLeads() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        leadsManager.loadLeadCollection(userId: currentUserID) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let leads):
                    self.allLeads = leads
                    self.delegate?.changeLoaderState(isHidden: true)
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "נוצרה בעיה בטעינה מול השרת, אנא נסה שנית")
                }
            }
        }
    }
}
