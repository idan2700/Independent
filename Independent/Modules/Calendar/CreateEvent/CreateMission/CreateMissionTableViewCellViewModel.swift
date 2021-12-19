//
//  CreateEventTableViewCellViewModel.swift
//  Independent
//
//  Created by Idan Levi on 16/11/2021.
//

import Foundation
import MapKit

protocol CreateMissionTableViewCellViewModelDelegate: AnyObject {
    func changeStartDatePickerVisability(toOpen: Bool)
    func changeEndDatePickerVisability(toOpen: Bool)
    func changePlacesTableViewVisability(toOpen: Bool)
    func updateButtonTitleToSelectedDate(with date: String, toStartButton: Bool)
    func changeErrorNameVisability(toPresent: Bool)
    func didPickNewMission(mission: Mission)
    func updateExisitingMission(event: Event)
    func presentError()
    func reloadData()
}

class CreateMissionTableViewCellViewModel {
    
    private var isStartDateIsOpen: Bool = false
    private var isEndDateIsOpen: Bool = false
    private var isPlacesTableViewIsOpen: Bool = false
    private let dateFormatter = DateFormatter()
    var matchingItems:[MKMapItem] = []
    var existingMission: Event?
    var currentDate: Date
    var reminder: Int?
    var reminderTitle = String()
    
    weak var delegate: CreateMissionTableViewCellViewModelDelegate?
    
    init(delegate: CreateMissionTableViewCellViewModelDelegate?, currentDate: Date) {
        self.delegate = delegate
        self.currentDate = currentDate
    }
    
    var numberOfRows: Int {
        return matchingItems.count
    }
    
    func getCellViewModel(at indexPath: IndexPath)-> PlacesTableViewCellViewModel {
        return PlacesTableViewCellViewModel(matchingItem: matchingItems[indexPath.row])
    }
    
    func checkForExistingMission() {
        if let existingMission = existingMission {
            delegate?.updateExisitingMission(event: existingMission)
        }
    }
    
    func didTapStartDate() {
        if isStartDateIsOpen {
            delegate?.changeStartDatePickerVisability(toOpen: false)
        } else {
            delegate?.changeStartDatePickerVisability(toOpen: true)
        }
        isStartDateIsOpen = !isStartDateIsOpen
    }
    
    func didTapEndDate() {
        if isEndDateIsOpen {
            delegate?.changeEndDatePickerVisability(toOpen: false)
        } else {
            delegate?.changeEndDatePickerVisability(toOpen: true)
        }
        isEndDateIsOpen = !isEndDateIsOpen
    }
    
    func handleDatePresentation(with date: Date, toStartButton: Bool) {
        dateFormatter.locale = Locale(identifier: "He")
        dateFormatter.dateFormat = "EEEE, d MMMM | HH:mm"
        let stringDate = dateFormatter.string(from: date)
        delegate?.updateButtonTitleToSelectedDate(with: stringDate, toStartButton: toStartButton)
    }
    
    func didStartToSearchLocation(searchText: String) {
        let initialLocation = CLLocation(latitude: 31.771959, longitude: 35.217018)
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        let region = MKCoordinateRegion(center: initialLocation.coordinate, span: MKCoordinateSpan())
        request.region = region
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, _ in
            guard let self = self else {return}
            guard let response = response else {return}
            DispatchQueue.main.async {
                self.matchingItems = response.mapItems
                self.delegate?.reloadData()
                self.delegate?.changePlacesTableViewVisability(toOpen: true)
            }
        }
    }
    
    func didEndToSearchLocation() {
        delegate?.changePlacesTableViewVisability(toOpen: false)
    }
    
    func didTapAdd(name: String, location: String, startDate: Date, endDate: Date, notes: String) {
        if validated(name: name) {
            if let existingMission = existingMission {
                switch existingMission {
                case .deal(viewModel:):
                    break
                case .mission(viewModel: let viewModel):
                    EventsManager.shared.updateMissionToStore(mission: viewModel.mission, name: name, location: location, start: startDate, end: endDate, notes: notes, reminder: self.reminder) { [weak self] result in
                        guard let self = self else {return}
                        DispatchQueue.main.async {
                            switch result {
                            case .success(_):
                                let mission = Mission(name: name, location: location, startDate: startDate, endDate: endDate, notes: notes, missionID: viewModel.mission.missionID, eventStoreID: viewModel.mission.eventStoreID, reminder: self.reminderTitle)
                                self.delegate?.didPickNewMission(mission: mission)
                            case .failure(_):
                                self.delegate?.presentError()
                            }
                        }
                    }
                }
            } else {
                EventsManager.shared.saveEventToStore(name: name, location: location, start: startDate, end: endDate, notes: notes, reminder: self.reminder) { [weak self] result in
                    guard let self = self else {return}
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let eventID):
                            let mission = Mission(name: name,
                                                  location: location,
                                                  startDate: startDate,
                                                  endDate: endDate,
                                                  notes: notes,
                                                  missionID: EventsManager.shared.genrateEventID(),
                                                  eventStoreID: eventID,
                                                  reminder: self.reminderTitle)
                            self.delegate?.didPickNewMission(mission: mission)
                        case .failure(_):
                            self.delegate?.presentError()
                        }
                    }
                }
            }
        } else {
            return
        }
    }
    
    private func validated(name: String)-> Bool {
        if name.isEmpty {
            self.delegate?.changeErrorNameVisability(toPresent: true)
            return false
        }
       return true
    }
    
    func didEditName(name: String) {
        if name.isEmpty {
            self.delegate?.changeErrorNameVisability(toPresent: true)
            return
        } else {
            self.delegate?.changeErrorNameVisability(toPresent: false)
            return
        }
    }
}
