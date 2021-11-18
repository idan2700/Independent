//
//  CalendarViewModel.swift
//  Independent
//
//  Created by Idan Levi on 15/11/2021.
//

import Foundation
import EventKit
import Firebase

protocol CalendarViewModelDelegate: AnyObject {
    func changeDatePickerVisability(toPresent: Bool)
    func updatePresentedDayLabel(with date: String)
    func changeCreateButtonsVisability(toPresent: Bool)
    func reloadData()
    func moveToCreateDealVC(with currentEventID: Int)
    func presentErrorAlert(message: String)
}

class CalendarViewModel {
    
    private var eventID = 0
    private var dateFormatter = DateFormatter()
    private let store = EKEventStore()
    private var isAddButtonSelected: Bool = false
    private var eventsManager: EventsManager
    private var events = [Event]()

    weak var delegate: CalendarViewModelDelegate?
    var isDatePickerOpen: Bool = false
    
    init(delegate: CalendarViewModelDelegate?, eventsManager: EventsManager) {
        self.delegate = delegate
        self.eventsManager = eventsManager
    }
    
    var numberOfRows: Int {
        return events.count
    }
    
    func start() {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        eventsManager.loadDeals(userId: userId) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let deals):
                    for deal in deals {
                        self.events.append(.deal(viewModel: DealTableViewCellViewModel(deal: deal)))
                    }
                    self.updateEventID()
                    self.delegate?.reloadData()
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "נוצרה בעיה מול השרת בטעינת האירועים")
                }
            }
        }
    }
    
    func getEvent(at indexPath: IndexPath)-> Event {
        return events[indexPath.row]
    }
    
    func didTapAdd() {
        isAddButtonSelected = !isAddButtonSelected
        if isAddButtonSelected {
            delegate?.changeCreateButtonsVisability(toPresent: true)
        } else {
            delegate?.changeCreateButtonsVisability(toPresent: false)
        }
    }
    
    func didTapAddDeal() {
        delegate?.moveToCreateDealVC(with: eventID)
        delegate?.changeCreateButtonsVisability(toPresent: false)
    }
    
    func didTapExpandDatePicker() {
        if isDatePickerOpen {
            delegate?.changeDatePickerVisability(toPresent: false)
        } else {
            delegate?.changeDatePickerVisability(toPresent: true)
        }
        isDatePickerOpen = !isDatePickerOpen
    }
    
    func handleDatePresentation(with date: Date) {
        dateFormatter.locale = Locale(identifier: "He")
        dateFormatter.dateFormat = "EEEE, d MMMM, yyyy"
        let stringDate = dateFormatter.string(from: date)
        delegate?.updatePresentedDayLabel(with: stringDate)
    }
    
    func didPickNewDeal(newDeal: Deal) {
        self.store.requestAccess(to: .event) { [weak self] succes, error in
            guard let self = self else {return}
                    if succes, error == nil {
                        DispatchQueue.main.async {
                            let newEvent = EKEvent(eventStore: self.store)
                            newEvent.title = newDeal.name
                            newEvent.location = newDeal.location
                            newEvent.startDate = newDeal.startDate
                            newEvent.endDate = newDeal.endDate
                            newEvent.notes = newDeal.notes
                            newEvent.calendar = self.store.defaultCalendarForNewEvents
                            do {
                                try self.store.save(newEvent, span: .thisEvent, commit: true)
                            } catch {
                                self.delegate?.presentErrorAlert(message: "נוצרה בעיה מול השרת בשמירת העסקה, אנא נסה שנית ")
                                return
                            }
                        }
                    }
                }
        guard let userId = Auth.auth().currentUser?.uid else {return}
        eventsManager.saveDeal(deal: newDeal, userName: userId) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.events.append(Event.deal(viewModel: DealTableViewCellViewModel(deal: newDeal)))
                    self.delegate?.reloadData()
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "נוצרה בעיה מול השרת בשמירת העסקה, אנא נסה שנית ")
                }
            }
        }
    }
    
    private func updateEventID() {
        if let eventID = UserDefaults.standard.value(forKey: "eventID") as? Int {
            self.eventID = eventID
        } else {
            var allEventIds = [Int]()
            for event in events {
                switch event {
                case .deal(viewModel: let viewModel):
                    allEventIds.append(viewModel.dealID)
                case .mission:
                    break
                }
            }
            if let maxID = allEventIds.max() {
                eventID = maxID
            }
        }
    }
}

enum Event {
    case deal(viewModel: DealTableViewCellViewModel)
    case mission
}
