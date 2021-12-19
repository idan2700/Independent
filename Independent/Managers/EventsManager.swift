//
//  EventsManager.swift
//  Independent
//
//  Created by Idan Levi on 18/11/2021.
//

import Foundation
import Firebase
import EventKit

class EventsManager {
    
    var allEvents = [Event]() {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "allEventsChanged"), object: nil)
        }
    }
    var allMissions = [Mission]()
    var allDeals = [Deal]()
    static let shared = EventsManager()
    private var eventID: Int = 0
    private let db = Firestore.firestore()
    private let store = EKEventStore()
    private var storeEvents = [EKEvent]()

    private init() {
        updateEventID()
    }
    
    func saveDeal(deal: Deal, userName: String, complition: @escaping (Result<Void, Error>)-> Void) {
        db.collection("Events").document(userName).collection("deal").document(String(deal.dealID)).setData(["name": deal.name, "phone": deal.phone, "location": deal.location, "startDate": deal.startDate, "endDate": deal.endDate, "price": deal.price, "notes": deal.notes, "eventStoreID": deal.eventStoreID, "reminder": deal.reminder]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    complition(.failure(error))
                } else {
                    complition(.success(()))
                }
            }
        }
    }
    
    func saveMission(mission: Mission, userName: String, complition: @escaping (Result<Void, Error>)-> Void) {
        db.collection("Events").document(userName).collection("mission").document(String(mission.missionID)).setData(["name": mission.name, "location": mission.location, "startDate": mission.startDate, "endDate": mission.endDate, "notes": mission.notes, "eventStoreID": mission.eventStoreID, "reminder": mission.reminder]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    complition(.failure(error))
                } else {
                    complition(.success(()))
                }
            }
        }
    }
    
    func editDeal(deal: Deal, userName: String, complition: @escaping (Result<Void, Error>)-> Void) {
        db.collection("Events").document(userName).collection("deal").document(String(deal.dealID)).updateData(["name": deal.name, "phone": deal.phone, "location": deal.location, "startDate": deal.startDate, "endDate": deal.endDate, "price": deal.price, "notes": deal.notes, "eventStoreID": deal.eventStoreID, "reminder": deal.reminder]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    complition(.failure(error))
                } else {
                    complition(.success(()))
                }
            }
        }
    }
    
    func editMission(mission: Mission, userName: String, complition: @escaping (Result<Void, Error>)-> Void) {
        db.collection("Events").document(userName).collection("mission").document(String(mission.missionID)).updateData(["name": mission.name, "location": mission.location, "startDate": mission.startDate, "endDate": mission.endDate, "notes": mission.notes, "eventStoreID": mission.eventStoreID, "reminder": mission.reminder]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    complition(.failure(error))
                } else {
                    complition(.success(()))
                }
            }
        }
    }
    
    func loadEventsFromStore(complition: ()->()) {
        let calendars = store.calendars(for: .event)
                for calendar in calendars {
                    guard calendar.allowsContentModifications else {
                        continue
                    }
                    let start = Date()
                    guard let end = Calendar.current.date(byAdding: .year, value: 2, to: start) else {return}
                    let predicate = store.predicateForEvents(withStart: start, end: end, calendars: [calendar])
                    let events = store.events(matching: predicate)
                    for event in events {
                        storeEvents.append(event)
                    }
                }
        complition()
    }
    
    func saveEventToStore(name: String, location: String, start: Date, end: Date, notes: String, reminder: Int?, complition: @escaping (Result<String, Error>)-> Void) {
        self.store.requestAccess(to: .event) { [weak self] succes, error in
            guard let self = self else {return}
                    if succes, error == nil {
                        DispatchQueue.main.async {
                            let newEvent = EKEvent(eventStore: self.store)
                            newEvent.title = name
                            newEvent.location = location
                            newEvent.startDate = start
                            newEvent.endDate = end
                            newEvent.notes = notes
                            if let reminderTime = reminder {
                            guard let alarmTime = Calendar.current.date(byAdding: .minute, value: -reminderTime, to: newEvent.startDate) else {return}
                            let alarm = EKAlarm(absoluteDate: alarmTime)
                            newEvent.addAlarm(alarm)
                            }
                            newEvent.calendar = self.store.defaultCalendarForNewEvents
                            do {
                                try self.store.save(newEvent, span: .thisEvent, commit: true)
                                complition(.success(newEvent.eventIdentifier))
                            } catch {
                                complition(.failure(error))
                                return
                            }
                        }
                    }
                }
    }
    
    func updateDealToStore(deal: Deal, name: String, location: String, start: Date, end: Date, notes: String, reminder: Int?, complition: @escaping (Result<String, Error>)-> Void) {
            guard let event = store.event(withIdentifier: deal.eventStoreID) else {return}
            event.title = name
            event.location = location
            event.startDate = start
            event.endDate = end
            event.notes = notes
        if let reminder = reminder {
            if let eventAlarms = event.alarms {
                guard let alarmTime = Calendar.current.date(byAdding: .minute, value: -reminder, to: event.startDate) else {return}
                let alarm = EKAlarm(absoluteDate: alarmTime)
                for alarm in eventAlarms {
                    event.removeAlarm(alarm)
                }
                event.addAlarm(alarm)
            }
        } else {
            if let eventAlarms = event.alarms {
                for alarm in eventAlarms {
                    event.removeAlarm(alarm)
                }
            }
        }
            event.calendar = self.store.defaultCalendarForNewEvents
            do {
                try self.store.save(event, span: .thisEvent, commit: true)
                complition(.success(event.eventIdentifier))
            } catch {
                complition(.failure(error))
                return
            }
        }
    
    func updateMissionToStore(mission: Mission, name: String, location: String, start: Date, end: Date, notes: String, reminder: Int?, complition: @escaping (Result<String, Error>)-> Void) {
        guard let event = store.event(withIdentifier: mission.eventStoreID) else {return}
        event.title = name
        event.location = location
        event.startDate = start
        event.endDate = end
        event.notes = notes
        if let reminder = reminder {
            if let eventAlarms = event.alarms {
                guard let alarmTime = Calendar.current.date(byAdding: .minute, value: -reminder, to: event.startDate) else {return}
                let alarm = EKAlarm(absoluteDate: alarmTime)
                for alarm in eventAlarms {
                    event.removeAlarm(alarm)
                }
                event.addAlarm(alarm)
            }
        } else {
            if let eventAlarms = event.alarms {
                for alarm in eventAlarms {
                    event.removeAlarm(alarm)
                }
            }
        }
        event.calendar = self.store.defaultCalendarForNewEvents
        do {
            try self.store.save(event, span: .thisEvent, commit: true)
            complition(.success(event.eventIdentifier))
        } catch {
            complition(.failure(error))
            return
        }
    }
        
    func loadDeals(userId: String, complition: @escaping (Result<Void, Error>)-> Void) {
        db.collection("Events").document(userId).collection("deal").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                if let error = error {
                    complition(.failure(error))
                    return
                }
                if let query = querySnapshot {
                    for document in query.documents {
                        let dealID = document.documentID
                        if let name = document.get("name") as? String,
                           let phone = document.get("phone") as? String,
                           let location = document.get("location") as? String,
                           let price = document.get("price") as? String,
                           let notes = document.get("notes") as? String,
                           let eventStoreID = document.get("eventStoreID") as? String,
                           let reminder = document.get("reminder") as? String,
                           let startTimeStamp = document.get("startDate") as? Timestamp,
                           let endTimeStamp = document.get("endDate") as? Timestamp {
                           let startDate = startTimeStamp.dateValue()
                            let endDate = endTimeStamp.dateValue()
                            let newDeal = Deal(name: name, phone: phone, location: location, startDate: startDate, endDate: endDate, price: price, notes: notes, dealID: Int(dealID) ?? 0, eventStoreID: eventStoreID, reminder: reminder)
                            if newDeal.endDate < Date() {
                                self.storeEvents.removeAll(where: {$0.eventIdentifier == newDeal.eventStoreID})
                                self.deleteEvent(eventStoreID: newDeal.eventStoreID, Id: String(newDeal.dealID), userID: userId, collection: "deal") { result in
                                    switch result {
                                    case .success():
                                        print("success")
                                    case .failure(_):
                                        print("failure")
                                    }
                                }
                            } else {
                                self.allDeals.append(newDeal)
                            }
                        }
                    }
                }
                complition(.success(()))
            }
        }
    }
    
    func loadMissions(userId: String, complition: @escaping (Result<Void, Error>)-> Void) {
        var missions = [Mission]()
        db.collection("Events").document(userId).collection("mission").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                if let error = error {
                    complition(.failure(error))
                    return
                }
                if let query = querySnapshot {
                    for document in query.documents {
                        let missionID = document.documentID
                        let location = document.get("location") as? String
                        let notes = document.get("notes") as? String
                        if let name = document.get("name") as? String,
                           let eventStoreID = document.get("eventStoreID") as? String,
                           let reminder = document.get("reminder") as? String,
                           let startTimeStamp = document.get("startDate") as? Timestamp,
                           let endTimeStamp = document.get("endDate") as? Timestamp {
                           let startDate = startTimeStamp.dateValue()
                            let endDate = endTimeStamp.dateValue()
                            let newMission = Mission(name: name, location: location, startDate: startDate, endDate: endDate, notes: notes, missionID: Int(missionID) ?? 0, eventStoreID: eventStoreID, reminder: reminder)
                            if newMission.endDate < Date() {
                                self.storeEvents.removeAll(where: {$0.eventIdentifier == newMission.eventStoreID})
                                self.deleteEvent(eventStoreID: newMission.eventStoreID, Id: String(newMission.missionID), userID: userId, collection: "mission") { result in
                                    switch result {
                                    case .success():
                                        print("success")
                                    case .failure(_):
                                        print("failure")
                                    }
                                }
                            } else {
                            missions.append(newMission)
                            }
                        }
                    }
                }
                let finalMissions = self.checkIfThereIsUnknownEventInStore(missions: missions, deals: self.allDeals, userID: userId)
                self.allMissions = finalMissions
                complition(.success(()))
            }
        }
    }
    
    func deleteEvent(eventStoreID: String, Id: String, userID: String, collection: String, complition: @escaping (Result<Void, Error>)-> Void) {
        guard let storeEvent = store.event(withIdentifier: eventStoreID) else {return}
        do {
            try self.store.remove(storeEvent, span: .thisEvent, commit: true)
            db.collection("Events").document(userID).collection(collection).document(Id).delete() { error in
                if let error = error {
                    complition(.failure(error))
                } else {
                    complition(.success(()))
                }
            }
        } catch {
            complition(.failure(error))
            return
        }
    }
    
    
    private func generateID(missions: [Mission]) -> Int {
        var id = [Int]()
        for mission in missions {
            id.append(mission.missionID)
        }
        if let maxId = id.max() {
            return maxId + 1
        }
        return 0
    }
    
    private func checkIfThereIsUnknownEventInStore(missions: [Mission], deals: [Deal], userID: String)-> [Mission] {
        var updatedMissions = missions
        var newMissionsToDb = [Mission]()
        var missionsToDelete = [Mission]()
        var storeEventsIdentifiers = [String]()
        var identifiers = [String]()
        for event in self.storeEvents {
            storeEventsIdentifiers.append(event.eventIdentifier)
        }
        for mission in missions {
            identifiers.append(mission.eventStoreID)
        }
        for deal in deals {
            identifiers.append(deal.eventStoreID)
        }
        for identifier in identifiers {
            if !storeEventsIdentifiers.contains(identifier) {
                if let mission = updatedMissions.first(where: {$0.eventStoreID == identifier}) {
                    updatedMissions.removeAll(where: {$0.eventStoreID == identifier})
                    missionsToDelete.append(mission)
                }
            }
        }
        for identifier in storeEventsIdentifiers {
            if !identifiers.contains(identifier) {
                guard let event = self.store.event(withIdentifier: identifier) else {return updatedMissions}
                let reminder = getReminderTitleFromEvent(event: event, startDate: event.startDate)
                let newMission = Mission(name: event.title,
                                         location: event.location,
                                         startDate: event.startDate,
                                         endDate: event.endDate,
                                         notes: event.notes,
                                         missionID: self.generateID(missions: updatedMissions),
                                         eventStoreID: event.eventIdentifier,
                                         reminder: reminder)
                updatedMissions.append(newMission)
                newMissionsToDb.append(newMission)
            }
        }
        for mission in newMissionsToDb {
            self.saveMission(mission: mission, userName: userID) { result in
                switch result {
                case .success():
                    print("saved")
                case .failure(_):
                    print("failed to save event to db")
                }
            }
        }
        for mission in missionsToDelete {
            db.collection("Events").document(userID).collection("mission").document(String(mission.missionID)).delete() { error in
                if let _ = error {
                    print("failed to delete event from db")
                } else {
                    print("deleted")
                }
            }
        }
        return updatedMissions
    }
    
    func appendEventsToAllEvents() {
        allEvents = []
        for deal in allDeals {
            allEvents.append(Event.deal(viewModel: DealTableViewCellViewModel(deal: deal)))
        }
        for mission in allMissions {
            allEvents.append(Event.mission(viewModel: MissionTableViewCellViewModel(mission: mission)))
        }
        sortEvents()
    }
    
    func sortEvents() {
        allEvents.sort(by: {$0 < $1})
    }
    
    private func getReminderTitleFromEvent(event: EKEvent, startDate: Date)-> String {
        if let eventAlarms = event.alarms {
            let alarmDate = eventAlarms[0].relativeOffset
            let minutes = Int(alarmDate / 60 * -1)
            let stringMinutes = String(minutes)
            switch minutes {
            case 0:
                return "בתחילת המשימה"
            case 15 :
                return "רבע שעה לפני"
            case 30 :
                return "חצי שעה לפני"
            case 60 :
                return "שעה לפני"
            case 120 :
                return "שעתיים לפני"
            case 1440 :
                return "יום לפני"
            case 2880 :
                return "יומיים לפני"
            case 10080 :
                return "שבוע לפני"
            default :
                return "\(stringMinutes) דקות לפני"
            }
        }
        return "ללא"
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
    
    func genrateEventID()-> Int {
        let newId = eventID + 1
        eventID = newId
        UserDefaults.standard.set(newId, forKey: "eventID")
        return eventID
    }
}
