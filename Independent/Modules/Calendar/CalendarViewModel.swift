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
    func updatePresentedDayLabel(with date: String)
    func reloadData()
    func removeCell(at indexPath: IndexPath)
    func moveToCreateDealVC(currentDate: Date, isNewDeal: Bool, existingDeal: Event?)
    func moveToCreateMissionVC(currentDate: Date, isNewMission: Bool, existingMission: Event?)
    func presentErrorAlert(message: String)
    func setNoEventsLabelState(isHidden: Bool)
    func changeEventsButtonVisability(toPresent: Bool)
    func changeCalendarVisability(toPresent: Bool)
    func selectDateInCalendar(date: Date)
}

class CalendarViewModel {
    
    private var dateFormatter = DateFormatter()
    private let store = EKEventStore()
    private var isAddButtonSelected: Bool = false
    private var currentPresentedDate: Date = Date()
    private var error: Error?
    private var existingEvent: Event?
    
  
    private var currentPresentedDayEvents = [Event]() {
        didSet {
            checkIfEventsAreEmpty()
        }
    }

    weak var delegate: CalendarViewModelDelegate?
    var isDatePickerOpen: Bool = false
    
    init(delegate: CalendarViewModelDelegate?) {
        self.delegate = delegate
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
    
    func calendarEventsColor(date: Date)-> [UIColor] {
        dateFormatter.dateFormat = "DD/MM/YY"
        var colors = [UIColor]()
        var dealDates = [String]()
        var missionDates = [String]()
        for event in EventsManager.shared.allEvents {
            switch event {
            case .deal(let viewModel):
                if dateFormatter.string(from: viewModel.deal.startDate) == dateFormatter.string(from: date) {
                    dealDates.append(dateFormatter.string(from: viewModel.deal.startDate))
                }
            case .mission(let viewModel):
                if dateFormatter.string(from: viewModel.mission.startDate) == dateFormatter.string(from: date) {
                    missionDates.append(dateFormatter.string(from: viewModel.mission.startDate))
                }
            }
        }
        colors = Array(repeating: UIColor(named: "deal")!, count: dealDates.count) + Array(repeating: UIColor(named: "mission")!, count: missionDates.count)
        return colors
    }
    
    func calendarNumberOfEvents(date: Date)-> Int {
        dateFormatter.dateFormat = "DD/MM/YY"
        var counter = 0
        for event in EventsManager.shared.allEvents {
            switch event {
            case .deal(let viewModel):
                if dateFormatter.string(from: viewModel.deal.startDate) == dateFormatter.string(from: date) {
                    counter += 1
                }
            case .mission(let viewModel):
                if dateFormatter.string(from: viewModel.mission.startDate) == dateFormatter.string(from: date) {
                    counter += 1
                }
            }
        }
      return counter
    }
    
    func didTapAdd() {
        delegate?.changeEventsButtonVisability(toPresent: true)
    }
    
    func didTapCloseEventsButtons() {
        delegate?.changeEventsButtonVisability(toPresent: false)
    }
    
    func didTapAddDeal() {
        delegate?.moveToCreateDealVC(currentDate: currentPresentedDate, isNewDeal: true, existingDeal: nil)
    }
    
    func didTapAddMission() {
        delegate?.moveToCreateMissionVC(currentDate: currentPresentedDate, isNewMission: true, existingMission: nil)
    }
    
    func didSwipeDown() {
        delegate?.changeCalendarVisability(toPresent: true)
        isDatePickerOpen = !isDatePickerOpen
    }
    
    func didSwipeUp() {
        delegate?.changeCalendarVisability(toPresent: false)
        isDatePickerOpen = !isDatePickerOpen
    }

    func didSelectDate(date: Date) {
        self.currentPresentedDate = date
        checkIfEventsAreEqualToCurrentPresentedDay(currentPresentedDay: date)
        handleDatePresentation(with: date)
        delegate?.selectDateInCalendar(date: date)
        delegate?.reloadData()
    }
    
    func handleDatePresentation(with date: Date) {
        dateFormatter.locale = Locale(identifier: "He")
        dateFormatter.dateFormat = "EEEE, d MMMM"
        let stringDate = dateFormatter.string(from: date)
        if stringDate == dateFormatter.string(from: Date()) {
            dateFormatter.dateFormat = "????????, d MMMM"
            let todayStringDate = dateFormatter.string(from: date)
            delegate?.updatePresentedDayLabel(with: todayStringDate)
        }else {
            delegate?.updatePresentedDayLabel(with: stringDate)
        }
    }
    
    
    func didPickNewDeal(newDeal: Deal) {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        EventsManager.shared.saveDeal(deal: newDeal, userName: userId) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.createNewIncome(deal: newDeal)
                    self.createNewLead(deal: newDeal)
                    self.handleDatePresentation(with: self.currentPresentedDate)
                    EventsManager.shared.allEvents.append(Event.deal(viewModel: DealTableViewCellViewModel(deal: newDeal)))
                    EventsManager.shared.sortEvents()
                    self.checkIfEventsAreEqualToCurrentPresentedDay(currentPresentedDay: self.currentPresentedDate)
                    self.didSelectDate(date: newDeal.startDate)
                    self.delegate?.reloadData()
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "?????????? ???????? ?????? ???????? ???????????? ??????????, ?????? ?????? ???????? ")
                }
            }
        }
    }
    
    func didPickNewMission(newMission: Mission) {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        EventsManager.shared.saveMission(mission: newMission, userName: userId) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.handleDatePresentation(with: self.currentPresentedDate)
                    EventsManager.shared.allEvents.append(Event.mission(viewModel: MissionTableViewCellViewModel(mission: newMission)))
                    EventsManager.shared.sortEvents()
                    self.checkIfEventsAreEqualToCurrentPresentedDay(currentPresentedDay: self.currentPresentedDate)
                    self.didSelectDate(date: newMission.startDate)
                    self.delegate?.reloadData()
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "?????????? ???????? ?????? ???????? ???????????? ??????????, ?????? ?????? ???????? ")
                }
            }
        }
    }
    
    func didPickEditedDeal(deal: Deal) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        EventsManager.shared.editDeal(deal: deal, userName: currentUserID) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.editIncome(deal: deal)
                    guard let dealIndex = EventsManager.shared.allDeals.firstIndex(where: {$0.eventStoreID == deal.eventStoreID}) else {return}
                    EventsManager.shared.allDeals.remove(at: dealIndex)
                    EventsManager.shared.allDeals.append(deal)
                    EventsManager.shared.allEvents = []
                    EventsManager.shared.appendEventsToAllEvents()
                    self.checkIfEventsAreEqualToCurrentPresentedDay(currentPresentedDay: self.currentPresentedDate)
                    self.didSelectDate(date: deal.startDate)
                    self.delegate?.reloadData()
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "?????????? ???????? ?????????? ???????? ?????????? ????????????, ?????? ?????? ????????")
                }
            }
        }
    }
    
    func didPickEditedMission(mission: Mission) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        EventsManager.shared.editMission(mission: mission, userName: currentUserID) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success():
                    guard let missionIndex = EventsManager.shared.allMissions.firstIndex(where: {$0.eventStoreID == mission.eventStoreID}) else {return}
                    EventsManager.shared.allMissions.remove(at: missionIndex)
                    EventsManager.shared.allMissions.append(mission)
                    EventsManager.shared.allEvents = []
                    EventsManager.shared.appendEventsToAllEvents()
                    self.checkIfEventsAreEqualToCurrentPresentedDay(currentPresentedDay: self.currentPresentedDate)
                    self.didSelectDate(date: mission.startDate)
                    self.delegate?.reloadData()
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "?????????? ???????? ?????????? ???????? ?????????? ????????????, ?????? ?????? ????????")
                }
            }
        }
    }
    
    func didTapDelete(at indexPath: IndexPath) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        let currentEvent = currentPresentedDayEvents[indexPath.row]
        var eventID = ""
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
        EventsManager.shared.deleteEvent(eventStoreID: eventStoreID, Id: eventID, userID: currentUserID, collection: collection) { [weak self] result in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        self.removeIncome(eventStoreId: eventStoreID)
                        self.removeEventFromAllEvents(currentEvent: self.currentPresentedDayEvents[indexPath.row])
                        self.currentPresentedDayEvents.remove(at: indexPath.row)
                        self.delegate?.removeCell(at: indexPath)
                        self.delegate?.reloadData()
                    case .failure(_):
                        self.delegate?.presentErrorAlert(message: "?????????? ???????? ?????????? ???????? ?????????? ????????????, ?????? ?????? ????????")
                    }
                }
            }
    }
    
    func didTapCancelDeal(at indexPath: IndexPath, phone: String) {
        didTapDelete(at: indexPath)
        if let index = LeadManager.shared.allLeads.firstIndex(where: {$0.phoneNumber == phone}) {
            LeadManager.shared.allLeads[index].status = .closed
            guard let currentUserID = Auth.auth().currentUser?.uid else {return}
            LeadManager.shared.updateLeadStatus(lead: LeadManager.shared.allLeads[index], userName: currentUserID, status: LeadManager.shared.allLeads[index].status.statusString) { [weak self] result in
                guard let self = self else {return}
                switch result {
                case .success():
                    print("statusChanged")
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "?????????? ???????? ?????? ???????? ???????????? ?????????? ????????, ?????????? ???????? ???? ??????????")
                }
            }
        }
    }
    
    func didTapSendWhatsapp(at indexPath: IndexPath, phone: String) {
        guard let url  = URL(string: "https://wa.me/972\(phone)") else {return}
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url as URL, options: [:]) { (success) in
                       if success {
                           print("WhatsApp accessed successfully")
                       } else {
                           self.delegate?.presentErrorAlert(message: "?????? ???? ???????? ???? ??????????????, ???????? ???????? ?????????? ???? ?????????????")
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
        self.delegate?.moveToCreateDealVC(currentDate: currentPresentedDate, isNewDeal: false, existingDeal: exisitingDeal)
    }
    
    func didTapEditMission(at indexPath: IndexPath) {
        let exisitingMission = currentPresentedDayEvents[indexPath.row]
        self.existingEvent = exisitingMission
        self.delegate?.moveToCreateMissionVC(currentDate: currentPresentedDate, isNewMission: false, existingMission: exisitingMission)
    }
    
    private func removeEventFromAllEvents(currentEvent: Event) {
        switch currentEvent {
        case .deal(let viewModel):
            EventsManager.shared.allDeals.removeAll(where: {$0.eventStoreID == viewModel.deal.eventStoreID})
        case .mission(let viewModel):
            EventsManager.shared.allMissions.removeAll(where: {$0.eventStoreID == viewModel.mission.eventStoreID})
        }
        EventsManager.shared.appendEventsToAllEvents()
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
        for event in EventsManager.shared.allEvents {
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
    
    private func createNewIncome(deal: Deal) {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        guard let amount = Int(deal.price) else { return }
        var dates = [Date]()
        dates.append(deal.startDate)
        let id = UUID().uuidString
        let income = Income(amount: amount, dates: dates, name: deal.name, id: id, isDeal: true, eventStoreId: deal.eventStoreID, type: .oneTime, numberOfPayments: nil)
        FinanceManager.shared.saveIncome(income: income, userName: userId) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success():
                    FinanceManager.shared.allIncomes.append(income)
                case .failure(_):
                    self.delegate?.presentErrorAlert(message: "?????????? ???????? ?????? ???????? ???????????? ??????????, ?????? ?????? ????????")
                }
            }
        }
    }
    
    private func removeIncome(eventStoreId: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        if let income = FinanceManager.shared.allIncomes.first(where: {$0.eventStoreId == eventStoreId}) {
            FinanceManager.shared.deleteIncome(incomeId: String(income.id), userID: currentUserID) { [weak self] result in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        FinanceManager.shared.allIncomes.removeAll(where: {$0.eventStoreId == eventStoreId})
                    case .failure(_):
                        self.delegate?.presentErrorAlert(message: "?????????? ???????? ?????????? ???????? ?????????? ????????????, ?????? ?????? ????????")
                    }
                }
            }
        }
    }
    
    private func editIncome(deal: Deal) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        if let income = FinanceManager.shared.allIncomes.first(where: {$0.eventStoreId == deal.eventStoreID}) {
            guard let amount = Int(deal.price) else {return}
            var dates = [Date]()
            dates.append(deal.startDate)
            let editedIncome = Income(amount: amount, dates: dates, name: deal.name, id: income.id, isDeal: income.isDeal, eventStoreId: income.eventStoreId, type: .oneTime, numberOfPayments: nil)
            FinanceManager.shared.editIncome(income: editedIncome, userName: currentUserID) { [weak self] result in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        FinanceManager.shared.allIncomes.removeAll(where: {$0.eventStoreId == income.eventStoreId})
                        FinanceManager.shared.allIncomes.append(editedIncome)
                    case .failure(_):
                        self.delegate?.presentErrorAlert(message: "?????????? ???????? ?????????? ???????? ?????????? ????????????, ?????? ?????? ????????")
                    }
                }
            }
        }
    }
    
    private func createNewLead(deal: Deal) {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        if !LeadManager.shared.allLeads.contains(where: {$0.phoneNumber == deal.phone}) {
            let newLead = Lead(fullName: deal.name, date: Date(), summary: deal.notes, phoneNumber: deal.phone, leadID: UUID().uuidString, status: .deal)
            LeadManager.shared.saveLead(lead: newLead, userName: userId) { [weak self] result in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        LeadManager.shared.allLeads.append(newLead)
                    case .failure(_):
                        self.delegate?.presentErrorAlert(message: "?????????? ???????? ?????? ???????? ???????????? ??????????, ?????? ?????? ???????? ")
                    }
                }
            }
        }
    }
}



