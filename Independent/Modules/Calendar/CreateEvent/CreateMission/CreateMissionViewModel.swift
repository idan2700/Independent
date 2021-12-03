//
//  CreateEventViewModel.swift
//  Independent
//
//  Created by Idan Levi on 16/11/2021.
//

import Foundation

protocol CreateMissionViewModelDelegate: AnyObject {
    func sendMissionToCalendar(mission: Mission, isNewMission: Bool)
}

class CreateMissionViewModel {
    
    private var allEvents: [Event]
    private var isNewMission: Bool
    weak var delegate: CreateMissionViewModelDelegate?
    
    var currentDate: Date?
    var exisitingMission: Event?

    init(delegate: CreateMissionViewModelDelegate, allEvents: [Event], isNewMission: Bool) {
        self.delegate = delegate
        self.allEvents = allEvents
        self.isNewMission = isNewMission
    }
    
    func getCellViewModel(cell: CreateMissionTableViewCell)-> CreateMissionTableViewCellViewModel {
        return CreateMissionTableViewCellViewModel(delegate: cell, allEvents: allEvents, eventsManager: EventsManager(), currentDate: currentDate ?? Date())
    }
    
    func didPickNewMission(newMission: Mission) {
        delegate?.sendMissionToCalendar(mission: newMission, isNewMission: isNewMission)
    }
}


