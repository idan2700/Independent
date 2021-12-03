//
//  Event.swift
//  Independent
//
//  Created by Idan Levi on 28/11/2021.
//

import Foundation

enum Event: Comparable {
    case deal(viewModel: DealTableViewCellViewModel)
    case mission(viewModel: MissionTableViewCellViewModel)
    
    static func < (lhs: Event, rhs: Event) -> Bool {
        switch (lhs, rhs) {
        case (.deal(viewModel: let viewModel), .mission(viewModel: let viewModel2)):
            return viewModel.deal.startDate < viewModel2.mission.startDate
        case (.mission(viewModel: let viewModel), .mission(viewModel: let viewModel2)):
            return viewModel.mission.startDate < viewModel2.mission.startDate
        case (.deal(viewModel: let viewModel), .deal(viewModel: let viewModel2)):
            return viewModel.deal.startDate < viewModel2.deal.startDate
        case (.mission(viewModel: let viewModel), .deal(viewModel: let viewModel2)):
            return viewModel.mission.startDate < viewModel2.deal.startDate
        }
    }
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        switch (lhs, rhs) {
        case (.deal(viewModel: let viewModel), .mission(viewModel: let viewModel2)):
            return viewModel.deal.startDate == viewModel2.mission.startDate
        case (.mission(viewModel: let viewModel), .mission(viewModel: let viewModel2)):
            return viewModel.mission.startDate == viewModel2.mission.startDate
        case (.deal(viewModel: let viewModel), .deal(viewModel: let viewModel2)):
            return viewModel.deal.startDate == viewModel2.deal.startDate
        case (.mission(viewModel: let viewModel), .deal(viewModel: let viewModel2)):
            return viewModel.mission.startDate == viewModel2.deal.startDate
        }
    }
}
