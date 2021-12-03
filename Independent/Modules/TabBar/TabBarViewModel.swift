//
//  TabBarViewModel.swift
//  Independent
//
//  Created by Idan Levi on 21/11/2021.
//


class TabVarViewModel {
    
    var allLeads: [Lead]
    var deals: [Deal]
    var missions: [Mission]
    
    init(allLeads: [Lead], deals: [Deal], missions: [Mission]) {
        self.allLeads = allLeads
        self.deals = deals
        self.missions = missions
    }
}
