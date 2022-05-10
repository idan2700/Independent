//
//  CdealViewModel.swift
//  Independent
//
//  Created by Idan Levi on 03/05/2022.
//

import Foundation
import Firebase

enum EventType {
    case deal
    case mission
}

protocol CreateEventViewModelDelegate: AnyObject {
    func changeStartDatePickerVisability(isHidden: Bool, fromDate: Bool)
    func changeEndDatePickerVisability(isHidden: Bool, fromDate: Bool)
    func changeTimeButtonsVisability(isHidden: Bool)
    func setStartDatePicker(toDate: Bool)
    func setEndDatePicker(toDate: Bool)
    func updateStartButtonsTitle(date: String, time: String)
    func updateEndButtonsTitle(date: String, time: String)
    func updateReminderButtonTitle(title: String)
    func moveToReminderVC()
    func presentAlertThatLeadIsExist()
    func changeAddButtonAvailability(isEnabled: Bool)
    func moveToLocationVC()
    func updateLoactionToTextField(location: String)
    func updateExisitingEvent(event: Event)
    func presentAlert(message: String)
    func sendDealToCalendar(deal: Deal, isNewDeal: Bool)
    func sendMissionToCalendar(mission: Mission, isNewMission: Bool)
    func returnToPrevious()
    func updateUItoMission(isEdit: Bool)
    func updateUItoDeal()
}

class CreateEventViewModel {
    
    private var isNewEvent: Bool
    private var eventType: EventType
    var isLaunchedFromLead: Bool
    private var dateFormatter = DateFormatter()
    private var currentDate: Date
    private var isStartDatePickerPresented = false
    private var isEndDatePickerPresented = false
    private var isStartTimePickerPresented = false
    private var isEndTimePickerPresented = false
    private var reminder: Int?
    private var reminderTitle = "ללא"
    private var isAllDay: Bool = false
    var existingLead: Lead?
    var existingEvent: Event?
    var name: String?
    var phone: String?
    
    private var Validated: Bool = false {
        didSet {
            self.delegate?.changeAddButtonAvailability(isEnabled: Validated)
        }
    }
    
    private var validatedFields = [String: Bool]() {
        didSet {
            switch eventType {
            case .deal:
                if validatedFields["name"] == true && validatedFields["price"] == true && validatedFields["phone"] == true {
                    self.Validated = true
                } else {
                    self.Validated = false
                }
                if isLaunchedFromLead && validatedFields["price"] == true {
                    self.Validated = true
                }
            case .mission:
                if validatedFields["name"] == true {
                    self.Validated = true
                } else {
                    self.Validated = false
                }
            }
        }
    }
    
    weak var delegate: CreateEventViewModelDelegate?
    
    init(delegate: CreateEventViewModelDelegate?, isLaunchedFromLead: Bool = false, isNewEvent: Bool, currentDate: Date, eventType: EventType) {
        self.delegate = delegate
        self.isLaunchedFromLead = isLaunchedFromLead
        self.isNewEvent = isNewEvent
        self.currentDate = currentDate
        self.eventType = eventType
        dateFormatter.locale = Locale(identifier: "He")
    }
    
    func start() {
        var isEdit = false
        if existingEvent != nil {
            isEdit = true
        }
        switch eventType {
        case .deal:
            if isEdit {
                self.delegate?.updateUItoDeal()
            } else {
                break
            }
        case .mission:
            self.delegate?.updateUItoMission(isEdit: isEdit)
        }
    }
    
    var startDate: String {
        dateFormatter.dateFormat = "EEEE, d MMMM"
        return dateFormatter.string(from: currentDate)
    }
    
    var endDate: String {
        dateFormatter.dateFormat = "EEEE, d MMMM"
        return dateFormatter.string(from: Calendar.current.date(byAdding: .hour, value: 1, to: currentDate) ?? Date())
    }
    
    var startTime: String {
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: currentDate)
    }
    
    var endTime: String {
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: Calendar.current.date(byAdding: .hour, value: 1, to: currentDate) ?? Date())
    }
    
    func didTapStart(fromDate: Bool) {
        delegate?.setStartDatePicker(toDate: fromDate)
        switch fromDate {
        case true:
            if !isStartDatePickerPresented && !isStartTimePickerPresented {
                isStartDatePickerPresented = true
                delegate?.changeStartDatePickerVisability(isHidden: false, fromDate: true)
                delegate?.changeEndDatePickerVisability(isHidden: true, fromDate: true)
            } else if isStartDatePickerPresented {
                isStartDatePickerPresented = false
                delegate?.changeStartDatePickerVisability(isHidden: true, fromDate: true)
            } else if isStartTimePickerPresented {
                isStartTimePickerPresented = false
                isStartDatePickerPresented = true
                delegate?.changeStartDatePickerVisability(isHidden: false, fromDate: true)
                delegate?.changeEndDatePickerVisability(isHidden: true, fromDate: true)
            }
        case false:
            if !isStartDatePickerPresented && !isStartTimePickerPresented {
                isStartTimePickerPresented = true
                delegate?.changeStartDatePickerVisability(isHidden: false, fromDate: false)
                delegate?.changeEndDatePickerVisability(isHidden: true, fromDate: false)
            } else if isStartTimePickerPresented {
                isStartTimePickerPresented = false
                delegate?.changeStartDatePickerVisability(isHidden: true, fromDate: false)
            } else if isStartDatePickerPresented {
                isStartTimePickerPresented = true
                isStartDatePickerPresented = false
                delegate?.changeStartDatePickerVisability(isHidden: false, fromDate: false)
                delegate?.changeEndDatePickerVisability(isHidden: true, fromDate: false)
            }
        }
    }
    
    func didTapEnd(fromDate: Bool) {
        delegate?.setEndDatePicker(toDate: fromDate)
        switch fromDate {
        case true:
            if !isEndDatePickerPresented && !isEndTimePickerPresented {
                isEndDatePickerPresented = true
                delegate?.changeEndDatePickerVisability(isHidden: false, fromDate: true)
                delegate?.changeStartDatePickerVisability(isHidden: true, fromDate: true)
            } else if isEndDatePickerPresented {
                isEndDatePickerPresented = false
                delegate?.changeEndDatePickerVisability(isHidden: true, fromDate: true)
            } else if isEndTimePickerPresented {
                isEndTimePickerPresented = false
                isEndDatePickerPresented = true
                delegate?.changeEndDatePickerVisability(isHidden: false, fromDate: true)
                delegate?.changeStartDatePickerVisability(isHidden: true, fromDate: true)
            }
        case false:
            if !isEndDatePickerPresented && !isEndTimePickerPresented {
                isEndTimePickerPresented = true
                delegate?.changeEndDatePickerVisability(isHidden: false, fromDate: false)
                delegate?.changeStartDatePickerVisability(isHidden: true, fromDate: false)
            } else if isEndTimePickerPresented {
                isEndTimePickerPresented = false
                delegate?.changeEndDatePickerVisability(isHidden: true, fromDate: false)
            } else if isEndDatePickerPresented {
                isEndTimePickerPresented = true
                isEndDatePickerPresented = false
                delegate?.changeEndDatePickerVisability(isHidden: false, fromDate: false)
                delegate?.changeStartDatePickerVisability(isHidden: true, fromDate: false)
            }
        }
    }
    
    func didSelectStartDate(date: Date) {
        dateFormatter.dateFormat = "EEEE, d MMMM"
        let stringDate = dateFormatter.string(from: date)
        let endDate =  dateFormatter.string(from: Calendar.current.date(byAdding: .hour, value: 1, to: date) ?? Date())
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.string(from: date)
        let endTime = dateFormatter.string(from: Calendar.current.date(byAdding: .hour, value: 1, to: date) ?? Date())
        delegate?.updateStartButtonsTitle(date: stringDate, time: time)
        delegate?.updateEndButtonsTitle(date: endDate, time: endTime)
    }
    
    func didSelectEndDate(date: Date) {
        dateFormatter.dateFormat = "EEEE, d MMMM"
        let stringDate = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.string(from: date)
        delegate?.updateEndButtonsTitle(date: stringDate, time: time)
    }
    
    func didToggleSwitcher(isOn: Bool) {
        delegate?.changeTimeButtonsVisability(isHidden: isOn)
        self.isAllDay = isOn
    }
    
    func didTapReminder() {
        delegate?.moveToReminderVC()
    }
    
    func didEditName(name: String) {
        if name.isEmpty {
            validatedFields["name"] = false
            return
        } else {
            validatedFields["name"] = true
            return
        }
    }
    
    func didEditPrice(price: String) {
        if price.isEmpty {
            validatedFields["price"] = false
            return
        } else {
            validatedFields["price"] = true
            return
        }
    }
    
    func didEditPhone(phone: String) {
        if let lead = LeadManager.shared.allLeads.first(where: {$0.phoneNumber == phone}) {
            self.delegate?.presentAlertThatLeadIsExist()
            self.existingLead = lead
        } else {
            self.existingLead = nil
        }
        if phone.isEmpty {
            validatedFields["phone"] = false
        } else if phone.count > 10 || phone.count < 9 {
            validatedFields["phone"] = false
        } else {
            validatedFields["phone"] = true
        }
    }
    
    func didTapLocation() {
        delegate?.moveToLocationVC()
    }
    
    func checkForExisitingEvent() {
        if let exisitingEvent = existingEvent {
            delegate?.updateExisitingEvent(event: exisitingEvent)
        }
    }
    
    func didTapAdd(name: String, phone: String, location: String, startDate: Date, endDate: Date, price: String, notes: String) {
        if let exisitingEvent = existingEvent {
            switch exisitingEvent {
            case .deal(viewModel: let viewModel):
                EventsManager.shared.updateDealToStore(deal: viewModel.deal, name: name, location: location, start: startDate, end: endDate, isAllDay: isAllDay, notes: notes, reminder: self.reminder) { [weak self] result in
                    guard let self = self else {return}
                    DispatchQueue.main.async {
                        switch result {
                        case .success(_):
                            let deal = Deal(name: name, phone: phone, location: location, startDate: startDate, endDate: endDate, price: price, notes: notes, dealID: viewModel.deal.dealID, eventStoreID: viewModel.deal.eventStoreID, reminder: self.reminderTitle, isAllDay: self.isAllDay)
                            self.didPickNewDeal(deal: deal)
                        case .failure(_):
                            self.delegate?.presentAlert(message: "נוצרה בעיה מול השרת בשמירת העסקה, אנא נסה שנית ")
                        }
                    }
                }
            case .mission(viewModel: let viewModel):
                EventsManager.shared.updateMissionToStore(mission: viewModel.mission, name: name, location: location, start: startDate, end: endDate, notes: notes, reminder: self.reminder) { [weak self] result in
                    guard let self = self else {return}
                    DispatchQueue.main.async {
                        switch result {
                        case .success(_):
                            let mission = Mission(name: name, location: location, startDate: startDate, endDate: endDate, notes: notes, missionID: viewModel.mission.missionID, eventStoreID: viewModel.mission.eventStoreID, reminder: self.reminderTitle)
                            self.didPickNewMission(mission: mission)
                        case .failure(_):
                            self.delegate?.presentAlert(message: "נוצרה בעיה מול השרת בשמירת המשימה, אנא נסה שנית ")
                        }
                    }
                }
            }
        } else {
            switch eventType {
            case .deal:
                EventsManager.shared.saveEventToStore(name: name, location: location, start: startDate, end: endDate, notes: notes, isAllDay: isAllDay, reminder: self.reminder) { [weak self] result in
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
                                            dealID: UUID().uuidString,
                                            eventStoreID: eventID,
                                            reminder: self.reminderTitle,
                                            isAllDay: self.isAllDay)
                            if let lead = self.existingLead  {
                                self.updateExistingLeadStatus(lead: lead)
                                self.existingLead = nil
                            }
                            self.didPickNewDeal(deal: deal)
                        case .failure(_):
                            self.delegate?.presentAlert(message: "נוצרה בעיה מול השרת בשמירת העסקה, אנא נסה שנית ")
                        }
                    }
                }
            case .mission:
                EventsManager.shared.saveEventToStore(name: name, location: location, start: startDate, end: endDate, notes: notes, isAllDay: false, reminder: self.reminder) { [weak self] result in
                    guard let self = self else {return}
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let eventID):
                            let mission = Mission(name: name,
                                                  location: location,
                                                  startDate: startDate,
                                                  endDate: endDate,
                                                  notes: notes,
                                                  missionID: UUID().uuidString,
                                                  eventStoreID: eventID,
                                                  reminder: self.reminderTitle)
                            self.didPickNewMission(mission: mission)
                        case .failure(_):
                            self.delegate?.presentAlert(message: "נוצרה בעיה מול השרת בשמירת המשימה, אנא נסה שנית ")
                        }
                    }
                }
            }
        }
    }
    
    private func updateExistingLeadStatus(lead: Lead) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        if let index = LeadManager.shared.allLeads.firstIndex(where: {$0.phoneNumber == lead.phoneNumber}) {
            LeadManager.shared.allLeads[index].status = .deal
            LeadManager.shared.updateLeadStatus(lead: LeadManager.shared.allLeads[index], userName: currentUserID, status: LeadManager.shared.allLeads[index].status.statusString) {  result in
                switch result {
                case .success():
                    print("success")
                case .failure(_):
                    print("failed to change status")
                }
            }
        }
    }
    
    func didPickNewDeal(deal: Deal) {
        if isLaunchedFromLead {
            self.saveDeal(deal: deal)
        } else {
            delegate?.sendDealToCalendar(deal: deal, isNewDeal: isNewEvent)
        }
    }
    
    func didPickNewMission(mission: Mission) {
        delegate?.sendMissionToCalendar(mission: mission, isNewMission: isNewEvent)
    }
    
    private func saveDeal(deal: Deal) {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        EventsManager.shared.saveDeal(deal: deal, userName: userId) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success():
                    EventsManager.shared.allEvents.append(Event.deal(viewModel: DealTableViewCellViewModel(deal: deal)))
                    EventsManager.shared.sortEvents()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "newDealAddedFromLeads"), object: nil)
                    self.createNewIncome(deal: deal)
                case .failure(_):
                    self.delegate?.presentAlert(message: "נוצרה בעיה מול השרת בשמירת העסקה, אנא נסה שנית ")
                }
            }
        }
    }
    
    private func createNewIncome(deal: Deal) {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        var dates = [Date]()
        dates.append(deal.startDate)
        guard let amount = Int(deal.price) else { return }
        let id = UUID().uuidString
        let income = Income(amount: amount, dates: dates, name: deal.name, id: id, isDeal: true, eventStoreId: deal.eventStoreID, type: .oneTime, numberOfPayments: nil)
        FinanceManager.shared.saveIncome(income: income, userName: userId) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success():
                    FinanceManager.shared.allIncomes.append(income)
                    self.delegate?.returnToPrevious()
                case .failure(_):
                    self.delegate?.presentAlert(message: "נוצרה בעיה מול השרת בשמירת הכנסה, אנא נסה שנית")
                }
            }
        }
    }
}

extension CreateEventViewModel: ReminderViewControllerDelegate {
    func didPick(timeOfReminder: Int?, reminderTitle: String) {
        self.reminder = timeOfReminder
        self.reminderTitle = reminderTitle
        self.delegate?.updateReminderButtonTitle(title: reminderTitle)
    }
}

extension CreateEventViewModel: LocationViewControllerDelegate {
    func didPickLocation(location: String) {
        delegate?.updateLoactionToTextField(location: location)
    }
}
