//
//  CalendarViewModel.swift
//  Independent
//
//  Created by Idan Levi on 15/11/2021.
//

import Foundation
import EventKit
import EventKitUI

protocol CalendarViewModelDelegate: AnyObject {
    func changeDatePickerVisability(toPresent: Bool)
    func updatePresentedDayLabel(with date: String)
}

class CalendarViewModel {
    
    private var dateFormatter = DateFormatter()
    private let store = EKEventStore()

    weak var delegate: CalendarViewModelDelegate?
    var isDatePickerOpen: Bool = false
    
    init(delegate: CalendarViewModelDelegate?) {
        self.delegate = delegate
    }
    
    func getCellViewModel(at indexPath: IndexPath)-> EventTableViewCellViewModel {
        return EventTableViewCellViewModel()
    }
    
    func didTapAddEvent() {

    }
    
  
    func didTapExpandDatePicker() {
        if isDatePickerOpen {
            delegate?.changeDatePickerVisability(toPresent: false)
        } else {
            delegate?.changeDatePickerVisability(toPresent: true)
        }
        isDatePickerOpen = !isDatePickerOpen
    }
    
    func updateCurrentPresentedDate(date: Date) {
        dateFormatter.locale = Locale(identifier: "He")
        dateFormatter.dateFormat = "EEEE, d MMMM, yyyy"
        let stringDate = dateFormatter.string(from: date)
        delegate?.updatePresentedDayLabel(with: stringDate)
    }
}
