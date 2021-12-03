//
//  CreateEventTableViewCellViewModel.swift
//  Independent
//
//  Created by Idan Levi on 16/11/2021.
//

import Foundation
import MapKit
import Firebase

protocol CreateDealTableViewCellViewModelDelegate: AnyObject {
    func changeStartDatePickerVisability(toOpen: Bool)
    func changeEndDatePickerVisability(toOpen: Bool)
    func changePlacesTableViewVisability(toOpen: Bool)
    func updateButtonTitleToSelectedDate(with date: String, toStartButton: Bool)
    func changeErrorNameVisability(toPresent: Bool)
    func changePriceErrorVisability(toPresent: Bool)
    func changePhoneErrorVisability(toPresent: Bool, message: String)
    func didPickNewDeal(deal: Deal)
    func updateExisitingDeal(event: Event)
    func presentError()
    func thereIsLeadInLeadsVC()
    func reloadData()
}

class CreateDealTableViewCellViewModel {
    
    private var eventID: Int = 0
    private var allEvents: [Event]
    private var allLeads: [Lead]
    private var isStartDateIsOpen: Bool = false
    private var isEndDateIsOpen: Bool = false
    private var isPlacesTableViewIsOpen: Bool = false
    private let dateFormatter = DateFormatter()
    private var eventsManager: EventsManager
    var matchingItems:[MKMapItem] = []
    var currentDate: Date
    var exisitingDeal: Event?
    var exsitingLeadIndex: Int?
    var reminder: Int?
    var reminderTitle = String()
    
    weak var delegate: CreateDealTableViewCellViewModelDelegate?
    
    init(delegate: CreateDealTableViewCellViewModelDelegate?, allEvents: [Event], allLeads: [Lead], eventsManager: EventsManager, currentDate: Date) {
        self.delegate = delegate
        self.allEvents = allEvents
        self.allLeads = allLeads
        self.eventsManager = eventsManager
        self.currentDate = currentDate
        updateEventID()
    }
    
    var numberOfRows: Int {
        return matchingItems.count
    }
    
    func getCellViewModel(at indexPath: IndexPath)-> PlacesTableViewCellViewModel {
        return PlacesTableViewCellViewModel(matchingItem: matchingItems[indexPath.row])
    }
    
    func checkForExisitingDeal() {
        if let exisitingDeal = exisitingDeal {
            delegate?.updateExisitingDeal(event: exisitingDeal)
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
    
    func didTapAdd(name: String, phone: String, location: String, startDate: Date, endDate: Date, price: String, notes: String) {
        if validated(name: name, price: price, phone: phone) {
            if let exisitingDeal = exisitingDeal {
                switch exisitingDeal {
                case .deal(viewModel: let viewModel):
                    eventsManager.updateDealToStore(deal: viewModel.deal, name: name, location: location, start: startDate, end: endDate, notes: notes, reminder: self.reminder) { [weak self] result in
                        guard let self = self else {return}
                        DispatchQueue.main.async {
                            switch result {
                            case .success(_):
                                let deal = Deal(name: name, phone: phone, location: location, startDate: startDate, endDate: endDate, price: price, notes: notes, dealID: viewModel.deal.dealID, eventStoreID: viewModel.deal.eventStoreID, reminder: self.reminderTitle)
                                self.delegate?.didPickNewDeal(deal: deal)
                            case .failure(_):
                                self.delegate?.presentError()
                            }
                        }
                    }
                case .mission(viewModel:):
                    break
                }
            } else {
                eventsManager.saveEventToStore(name: name, location: location, start: startDate, end: endDate, notes: notes, reminder: self.reminder) { [weak self] result in
                    guard let self = self else {return}
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let eventID):
                            let deal = Deal(name: name,
                                            phone: phone,
                                            location: location,
                                            startDate: startDate,
                                            endDate: endDate,
                                            price: price,
                                            notes: notes,
                                            dealID: self.genrateEventID(),
                                            eventStoreID: eventID,
                                            reminder: self.reminderTitle)
                            if self.exsitingLeadIndex != nil {
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "dealOnExistingLead"), object: self.exsitingLeadIndex)
                                self.exsitingLeadIndex = nil
                            }
                            self.delegate?.didPickNewDeal(deal: deal)
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
    
    private func validated(name: String, price: String, phone: String)-> Bool {
        if name.isEmpty {
            self.delegate?.changeErrorNameVisability(toPresent: true)
            return false
        }
        if phone.isEmpty {
            self.delegate?.changePhoneErrorVisability(toPresent: true, message: "לא הכנסת טלפון")
            return false
        }
        if phone.count > 10 || phone.count < 9 {
            self.delegate?.changePhoneErrorVisability(toPresent: true, message: "הפורמט של מספר הטלפון לא תקין")
            return false
        }
        if price.isEmpty {
            self.delegate?.changePriceErrorVisability(toPresent: true)
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
    
    func didEditPrice(price: String) {
        if price.isEmpty {
            self.delegate?.changePriceErrorVisability(toPresent: true)
            return
        } else {
            self.delegate?.changePriceErrorVisability(toPresent: false)
            return
        }
    }
    
    func didEditPhone(phone: String) {
        if let index = allLeads.firstIndex(where: {$0.phoneNumber == phone}) {
            self.delegate?.thereIsLeadInLeadsVC()
            self.exsitingLeadIndex = index
        } else {
            self.exsitingLeadIndex = nil
        }
        if phone.isEmpty {
            self.delegate?.changePhoneErrorVisability(toPresent: true, message: "לא הכנסת טלפון")
        } else {
            self.delegate?.changePhoneErrorVisability(toPresent: false, message: "")
        }
    }
    
    private func updateEventID() {
        if let eventID = UserDefaults.standard.value(forKey: "eventID") as? Int {
            self.eventID = eventID
        } else {
            var allEventIds = [Int]()
            for event in allEvents {
                switch event {
                case .deal(viewModel: let viewModel):
                    allEventIds.append(viewModel.dealID)
                case .mission(viewModel: let viewModel):
                    allEventIds.append(viewModel.missionID)
                }
            }
            if let maxID = allEventIds.max() {
                eventID = maxID
            }
        }
    }
    
    private func genrateEventID()-> Int {
        let newId = eventID + 1
        eventID = newId
        UserDefaults.standard.set(newId, forKey: "eventID")
        return eventID
    }
}
