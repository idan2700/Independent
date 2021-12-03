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
    func removeCell(at indexPath: IndexPath)
    func moveToCreateDealVC(with allEvents: [Event], allLeads: [Lead], currentDate: Date, isNewDeal: Bool, existingDeal: Event?)
    func moveToCreateMissionVC(with allEvents: [Event], currentDate: Date, isNewMission: Bool, existingMission: Event?)
    func presentErrorAlert(message: String)
    func setNoEventsLabelState(isHidden: Bool)
    func changeLastDayButtonVisability(isHidden: Bool)
}

class CalendarViewModel {
    
    private var dateFormatter = DateFormatter()
    private let store = EKEventStore()
    private var isAddButtonSelected: Bool = false
    private var eventsManager: EventsManager
    private var allLeads: [Lead]
    private var deals: [Deal]
    private var missions: [Mission]
    private var currentPresentedDate: Date = Date()
    private var error: Error?
    private var existingEvent: Event?
    
    private var allEvents = [Event]() {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "allEventsChanged"), object: allEvents)
        }
    }
    private var currentPresentedDayEvents = [Event]() {
        didSet {
            checkIfEventsAreEmpty()
        }
    }

    weak var delegate: CalendarViewModelDelegate?
    var isDatePickerOpen: Bool = false
    
    init(delegate: CalendarViewModelDelegate?, eventsManager: EventsManager, allLeads: [Lead], deals: [Deal], missions: [Mission]) {
        self.delegate = delegate
        self.eventsManager = eventsManager
        self.allLeads = allLeads
        self.deals = deals
        self.missions = missions
        NotificationCenter.default.addObserver(self, selector: #selector(allLeadsChanged(notification:)), name: Notification.Name(rawValue: "allLeadsChanged"), object: nil)
        appendEventsToAllEvents()
    }
    
    var numberOfRows: Int {
        return currentPresentedDayEvents.count
    }
    
    func start() {
        self.checkIfEventsAreEqualToCurrentPresentedDay(currentPresentedDay: Date())
        self.delegate?.reloadData()
    }
    
    func getEvent(at indexPath: IndexPath)-> Event {
        return currentPresentedDayEvents[indexPath.row]
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
        delegate?.moveToCreateDealVC(with: allEvents, allLeads: allLeads, currentDate: currentPresentedDate, isNewDeal: true, existingDeal: nil)
        delegate?.changeCreateButtonsVisability(toPresent: false)
    }
    
    func didTapAddMission() {
        delegate?.moveToCreateMissionVC(with: allEvents, currentDate: currentPresentedDate, isNewMission: true, existingMission: nil)
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
    
    func didSelectDate(date: Date) {
        self.currentPresentedDate = date
        checkIfEventsAreEqualToCurrentPresentedDay(currentPresentedDay: date)
        handleDatePresentation(with: date)
        delegate?.reloadData()
    }
    
    func handleDatePresentation(with date: Date) {
        dateFormatter.locale = Locale(identifier: "He")
        dateFormatter.dateFormat = "EEEE, d MMMM, yyyy"
        let stringDate = dateFormatter.string(from: date)
        if stringDate == dateFormatter.string(from: Date()) {
            dateFormatter.dateFormat = "היום, d MMMM, yyyy"
            let todayStringDate = dateFormatter.string(from: date)
            delegate?.updatePresentedDayLabel(with: todayStringDate)
        }else {
            delegate?.updatePresentedDayLabel(with: stringDate)
        }
    }
    
    func didSwipeLeft() {
        self.dateFormatter.dateFormat = "d, MMMM, yyyy"
        self.dateFormatter.locale = Locale(identifier: "He")
        let currentDay = self.dateFormatter.string(from: currentPresentedDate)
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        if currentDay == self.dateFormatter.string(from: nextDay) {
            self.delegate?.changeLastDayButtonVisability(isHidden: true)
        }
        if currentDay == self.dateFormatter.string(from: Date()) {
            return
        }
        self.currentPresentedDate = Calendar.current.date(byAdding: .day, value: -1, to: currentPresentedDate) ?? Date()
        checkIfEventsAreEqualToCurrentPresentedDay(currentPresentedDay: currentPresentedDate)
        handleDatePresentation(with: currentPresentedDate)
        delegate?.reloadData()
    }
    
    func didSwipeRight() {
        self.currentPresentedDate = Calendar.current.date(byAdding: .day, value: 1, to: currentPresentedDate) ?? Date()
        checkIfEventsAreEqualToCurrentPresentedDay(currentPresentedDay: currentPresentedDate)
        handleDatePresentation(with: currentPresentedDate)
        delegate?.changeLastDayButtonVisability(isHidden: false)
        delegate?.reloadData()
    }
    
    func didPickNewDeal(newDeal: Deal) {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        eventsManager.saveDeal(deal: newDeal, userName: userId) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.handleDatePresentation(with: self.currentPresentedDate)
                    self.allEvents.append(Event.deal(viewModel: DealTableViewCellViewModel(deal: newDeal)))
                    self.sortEvents()
                    self.checkIfEventsAreEqualToCurrentPresentedDay(currentPresentedDay: self.currentPresentedDate)
                    self.delegate?.reloadData()
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "נוצרה בעיה מול השרת בשמירת העסקה, אנא נסה שנית ")
                }
            }
        }
    }
    
    func didPickNewMission(newMission: Mission) {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        eventsManager.saveMission(mission: newMission, userName: userId) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.handleDatePresentation(with: self.currentPresentedDate)
                    self.allEvents.append(Event.mission(viewModel: MissionTableViewCellViewModel(mission: newMission)))
                    self.sortEvents()
                    self.checkIfEventsAreEqualToCurrentPresentedDay(currentPresentedDay: self.currentPresentedDate)
                    self.delegate?.reloadData()
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "נוצרה בעיה מול השרת בשמירת העסקה, אנא נסה שנית ")
                }
            }
        }
    }
    
    func didPickEditedDeal(deal: Deal) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        eventsManager.editDeal(deal: deal, userName: currentUserID) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success():
                    guard let dealIndex = self.deals.firstIndex(where: {$0.eventStoreID == deal.eventStoreID}) else {return}
                    self.deals.remove(at: dealIndex)
                    self.deals.append(deal)
                    self.allEvents = []
                    self.appendEventsToAllEvents()
                    self.checkIfEventsAreEqualToCurrentPresentedDay(currentPresentedDay: self.currentPresentedDate)
                    self.delegate?.reloadData()
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "נוצרה בעיה בפניה לשרת לצורך העריכה, אנא נסה שנית")
                }
            }
        }
    }
    
    func didPickEditedMission(mission: Mission) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        eventsManager.editMission(mission: mission, userName: currentUserID) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success():
                    guard let missionIndex = self.missions.firstIndex(where: {$0.eventStoreID == mission.eventStoreID}) else {return}
                    self.missions.remove(at: missionIndex)
                    self.missions.append(mission)
                    self.allEvents = []
                    self.appendEventsToAllEvents()
                    self.checkIfEventsAreEqualToCurrentPresentedDay(currentPresentedDay: self.currentPresentedDate)
                    self.delegate?.reloadData()
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "נוצרה בעיה בפניה לשרת לצורך העריכה, אנא נסה שנית")
                }
            }
        }
    }
    
    func didTapDelete(at indexPath: IndexPath) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        let currentEvent = currentPresentedDayEvents[indexPath.row]
        var eventID = 0
        var eventStoreID = ""
        var collection = ""
        switch currentEvent {
        case .deal(viewModel: let viewModel):
            eventID = viewModel.dealID
            eventStoreID = viewModel.deal.eventStoreID
            collection = "deal"
        case .mission(viewModel: let viewModel):
            eventID = viewModel.missionID
            eventStoreID = viewModel.mission.eventStoreID
            collection = "mission"
        }
        eventsManager.deleteEvent(eventStoreID: eventStoreID, Id: String(eventID), userID: currentUserID, collection: collection) { [weak self] result in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        self.removeEventFromAllEvents(currentEvent: self.currentPresentedDayEvents[indexPath.row])
                        self.currentPresentedDayEvents.remove(at: indexPath.row)
                        self.delegate?.removeCell(at: indexPath)
                        self.delegate?.reloadData()
                    case .failure(_):
                        self.delegate?.presentErrorAlert(message: "נוצרה בעיה בפניה לשרת לצורך המחיקה, אנא נסה שנית")
                    }
                }
            }
    }
    
    func didTapCancelDeal(at indexPath: IndexPath, phone: String) {
        didTapDelete(at: indexPath)
        if let index = allLeads.firstIndex(where: {$0.phoneNumber == phone}) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "dealWasCanceled"), object: index)
        }
    }
    
    func didTapSendWhatsapp(at indexPath: IndexPath, phone: String) {
        guard let url  = URL(string: "https://wa.me/972\(phone)") else {return}
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url as URL, options: [:]) { (success) in
                       if success {
                           print("WhatsApp accessed successfully")
                       } else {
                           self.delegate?.presentErrorAlert(message: "אני לא מוצא את הווטסאפ, בטוח שהוא מותקן על המכשיר?")
                       }
                   }
           }
    }
    
    func didTapCall(at indexPath: IndexPath, phone: String) {
        guard let phoneCallURL = URL(string: "tel://\(phone)") else { return }
        if UIApplication.shared.canOpenURL(phoneCallURL) {
            UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
        }
    }
    
    func didTapEditDeal(at indexPath: IndexPath) {
        let exisitingDeal = currentPresentedDayEvents[indexPath.row]
        self.existingEvent = exisitingDeal
        self.delegate?.moveToCreateDealVC(with: allEvents, allLeads: allLeads, currentDate: currentPresentedDate, isNewDeal: false, existingDeal: exisitingDeal)
    }
    
    func didTapEditMission(at indexPath: IndexPath) {
        let exisitingMission = currentPresentedDayEvents[indexPath.row]
        self.existingEvent = exisitingMission
        self.delegate?.moveToCreateMissionVC(with: allEvents, currentDate: currentPresentedDate, isNewMission: false, existingMission: exisitingMission)
    }
    
    private func removeEventFromAllEvents(currentEvent: Event) {
        switch currentEvent {
        case .deal(let viewModel):
            deals.removeAll(where: {$0.eventStoreID == viewModel.deal.eventStoreID})
        case .mission(let viewModel):
            missions.removeAll(where: {$0.eventStoreID == viewModel.mission.eventStoreID})
        }
        self.appendEventsToAllEvents()
    }
    
    private func appendEventsToAllEvents() {
        allEvents = []
        for deal in deals {
            allEvents.append(Event.deal(viewModel: DealTableViewCellViewModel(deal: deal)))
        }
        for mission in missions {
            allEvents.append(Event.mission(viewModel: MissionTableViewCellViewModel(mission: mission)))
        }
        sortEvents()
    }
    
    private func sortEvents() {
        allEvents.sort(by: {$0 < $1})
    }
    
    
    private func checkIfEventsAreEmpty() {
        if currentPresentedDayEvents.isEmpty {
            self.delegate?.setNoEventsLabelState(isHidden: false)
        } else {
            self.delegate?.setNoEventsLabelState(isHidden: true)
        }
    }
    
    private func checkIfEventsAreEqualToCurrentPresentedDay(currentPresentedDay: Date) {
        currentPresentedDayEvents = []
        self.dateFormatter.dateFormat = "d, MMMM, yyyy"
        self.dateFormatter.locale = Locale(identifier: "He")
        let currentDay = self.dateFormatter.string(from: currentPresentedDay)
        for event in allEvents {
            switch event {
            case .deal(viewModel: let viewModel):
                if self.dateFormatter.string(from: viewModel.deal.startDate) == currentDay {
                    self.currentPresentedDayEvents.append(.deal(viewModel: viewModel))
                }
            case .mission(viewModel: let viewModel):
                if self.dateFormatter.string(from: viewModel.mission.startDate) == currentDay {
                    self.currentPresentedDayEvents.append(.mission(viewModel: viewModel)
                    )
                }
            }
        }
    }
    
    @objc private func allLeadsChanged(notification: Notification) {
        guard let allLeads = notification.object as? [Lead] else {return}
        self.allLeads = allLeads
    }
}



