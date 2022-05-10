//
//  MissionTableViewCellViewModel.swift
//  Independent
//
//  Created by Idan Levi on 22/11/2021.
//

import Foundation

protocol MissionTableViewCellViewModelDelegate: AnyObject {
    func changeNotesLabelVisability(toPresent: Bool)
}

class MissionTableViewCellViewModel {
    
    var mission: Mission
    private var dateFormatter = DateFormatter()
    private var isNotesButtonIsOpen: Bool = false
    
    weak var delegate: MissionTableViewCellViewModelDelegate?
    
    init(mission: Mission) {
        self.mission = mission
    }
    
    var eventName: String {
        return mission.name
    }
    
    var missionID: String {
        return mission.missionID
    }
    
    var notes: String {
        if mission.notes == "" {
            return "אין הערות"
        } else {
            return mission.notes ?? "אין הערות"
        }
    }

    var location: String {
        return mission.location ?? ""
    }
    
    var time: String {
        dateFormatter.locale = Locale(identifier: "He")
        dateFormatter.dateFormat = "HH:mm"
        let startTime = dateFormatter.string(from: mission.startDate)
        let endTime = dateFormatter.string(from: mission.endDate)
        return "\(startTime) : \(endTime)"
    }
    
    func didTapNotesButton() {
        if isNotesButtonIsOpen {
            self.delegate?.changeNotesLabelVisability(toPresent: false)
        } else {
            self.delegate?.changeNotesLabelVisability(toPresent: true)
        }
        isNotesButtonIsOpen = !isNotesButtonIsOpen
    }
    
    var reminderTitle: String {
        return mission.reminder
    }
}


